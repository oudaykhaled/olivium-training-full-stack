# Data Models & Type Definitions

## Overview
This document defines all TypeScript types, interfaces, and DTOs used in the ArcadeHub application.

---

## 🗂️ Domain Models

### Branch
Represents a physical gaming lounge location.

```typescript
interface Branch {
  id: string;
  name: string;
  address: string;
  city: string;
  phone: string;
  email: string;
  openingHours: {
    [key: string]: { // "monday", "tuesday", etc.
      open: string;  // "09:00"
      close: string; // "23:00"
      isClosed: boolean;
    };
  };
  createdAt: string; // ISO 8601
  updatedAt: string;
}
```

**Example**:
```json
{
  "id": "br-123",
  "name": "Downtown Gaming Hub",
  "address": "123 Main St, Suite 100",
  "city": "San Francisco",
  "phone": "+1-555-0100",
  "email": "downtown@arcadehub.com",
  "openingHours": {
    "monday": { "open": "10:00", "close": "23:00", "isClosed": false },
    "tuesday": { "open": "10:00", "close": "23:00", "isClosed": false },
    "sunday": { "open": "12:00", "close": "20:00", "isClosed": false }
  },
  "createdAt": "2024-01-15T08:00:00Z",
  "updatedAt": "2024-02-01T10:30:00Z"
}
```

---

### Station
Represents a gaming station (PC, console, or room).

```typescript
type StationType = 'PC' | 'PS5' | 'XBOX' | 'SWITCH' | 'VR_ROOM' | 'PRIVATE_ROOM';
type StationStatus = 'FREE' | 'OCCUPIED' | 'RESERVED' | 'MAINTENANCE' | 'OFFLINE';

interface Station {
  id: string;
  branchId: string;
  name: string;
  type: StationType;
  status: StationStatus;
  specs?: {
    gpu?: string;
    cpu?: string;
    ram?: string;
    monitor?: string;
  };
  pricePerHour: number; // in cents (e.g., 1500 = $15.00)
  features: string[]; // ["mechanical-keyboard", "gaming-mouse", "headset"]
  imageUrl?: string;
  currentBookingId?: string; // if status is OCCUPIED or RESERVED
  createdAt: string;
  updatedAt: string;
}
```

**Example**:
```json
{
  "id": "st-456",
  "branchId": "br-123",
  "name": "Gaming PC #5",
  "type": "PC",
  "status": "FREE",
  "specs": {
    "gpu": "RTX 4080",
    "cpu": "Intel i9-13900K",
    "ram": "32GB DDR5",
    "monitor": "27\" 240Hz"
  },
  "pricePerHour": 1500,
  "features": ["mechanical-keyboard", "gaming-mouse", "rgb-lighting", "headset"],
  "imageUrl": "https://cdn.arcadehub.com/stations/pc-5.jpg",
  "createdAt": "2024-01-15T08:00:00Z",
  "updatedAt": "2024-02-05T14:20:00Z"
}
```

---

### Booking
Represents a customer reservation.

```typescript
type BookingStatus = 
  | 'PENDING'      // Created but not confirmed
  | 'CONFIRMED'    // Confirmed by system or staff
  | 'CHECKED_IN'   // Customer arrived and started session
  | 'COMPLETED'    // Session finished
  | 'CANCELLED'    // Cancelled by customer or staff
  | 'NO_SHOW';     // Customer didn't show up

interface Booking {
  id: string;
  userId: string;
  branchId: string;
  stationId: string;
  startTime: string; // ISO 8601
  endTime: string;   // ISO 8601
  status: BookingStatus;
  totalPrice: number; // in cents
  notes?: string;
  createdAt: string;
  updatedAt: string;
  checkedInAt?: string;
  completedAt?: string;
  cancelledAt?: string;
  cancellationReason?: string;
}
```

**Example**:
```json
{
  "id": "bk-789",
  "userId": "usr-001",
  "branchId": "br-123",
  "stationId": "st-456",
  "startTime": "2024-02-10T14:00:00Z",
  "endTime": "2024-02-10T17:00:00Z",
  "status": "CONFIRMED",
  "totalPrice": 4500,
  "notes": "Birthday party - need extra controller",
  "createdAt": "2024-02-05T10:00:00Z",
  "updatedAt": "2024-02-05T10:05:00Z"
}
```

---

### User
Represents a system user (customer, staff, or admin).

```typescript
type UserRole = 'CUSTOMER' | 'STAFF' | 'ADMIN';
type UserStatus = 'ACTIVE' | 'SUSPENDED' | 'DELETED';

interface User {
  id: string;
  email: string;
  name: string;
  phone?: string;
  role: UserRole;
  status: UserStatus;
  branchId?: string; // Only for STAFF (their assigned branch)
  avatar?: string;
  createdAt: string;
  updatedAt: string;
  lastLoginAt?: string;
}
```

**Example**:
```json
{
  "id": "usr-001",
  "email": "john.doe@example.com",
  "name": "John Doe",
  "phone": "+1-555-0123",
  "role": "CUSTOMER",
  "status": "ACTIVE",
  "avatar": "https://cdn.arcadehub.com/avatars/usr-001.jpg",
  "createdAt": "2024-01-10T12:00:00Z",
  "updatedAt": "2024-02-05T09:30:00Z",
  "lastLoginAt": "2024-02-05T09:30:00Z"
}
```

---

## 📤 Request DTOs

### Create Booking Request
```typescript
interface CreateBookingRequest {
  branchId: string;
  stationId: string;
  startTime: string; // ISO 8601
  endTime: string;   // ISO 8601
  notes?: string;
}
```

**Validation Rules**:
- `startTime` must be in the future
- `endTime` must be after `startTime`
- Duration must be at least 1 hour
- Duration must not exceed 8 hours
- Station must be available for the entire time slot

---

### Update Booking Request
```typescript
interface UpdateBookingRequest {
  status?: BookingStatus;
  notes?: string;
  cancellationReason?: string; // Required if status is CANCELLED
}
```

---

### Update User Request
```typescript
interface UpdateUserRequest {
  name?: string;
  phone?: string;
  role?: UserRole;
  status?: UserStatus;
  branchId?: string;
}
```

**Validation Rules**:
- Only ADMIN can change `role` or `status`
- If changing role to STAFF, `branchId` is required
- Cannot downgrade own role

---

### Station Availability Query
```typescript
interface AvailabilityQueryParams {
  branchId: string;
  date: string;        // YYYY-MM-DD
  stationType?: StationType;
}

interface AvailabilityResponse {
  date: string;
  branch: Branch;
  stations: {
    station: Station;
    availableSlots: TimeSlot[];
  }[];
}

interface TimeSlot {
  startTime: string;  // "09:00"
  endTime: string;    // "23:00"
  isAvailable: boolean;
  bookingId?: string; // If occupied
}
```

---

## 📥 Response DTOs

### Booking with Relations
Used when we need full booking details with nested objects.

```typescript
interface BookingWithRelations {
  id: string;
  user: Pick<User, 'id' | 'name' | 'email' | 'phone'>;
  branch: Pick<Branch, 'id' | 'name' | 'address'>;
  station: Pick<Station, 'id' | 'name' | 'type' | 'pricePerHour'>;
  startTime: string;
  endTime: string;
  status: BookingStatus;
  totalPrice: number;
  duration: number; // in hours
  notes?: string;
  createdAt: string;
  updatedAt: string;
}
```

---

### Paginated Response
Standard pagination wrapper.

```typescript
interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    pageSize: number;
    totalCount: number;
    totalPages: number;
    hasNextPage: boolean;
    hasPreviousPage: boolean;
  };
}
```

**Example**:
```typescript
type UserListResponse = PaginatedResponse<User>;
type BookingListResponse = PaginatedResponse<BookingWithRelations>;
```

---

### API Error Response
Standard error format.

```typescript
interface ApiError {
  error: {
    code: string;           // "VALIDATION_ERROR", "NOT_FOUND", etc.
    message: string;        // Human-readable message
    details?: {
      field: string;
      message: string;
    }[];
    timestamp: string;
    path: string;          // API endpoint
  };
}
```

**Example**:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid booking request",
    "details": [
      { "field": "startTime", "message": "Start time must be in the future" },
      { "field": "endTime", "message": "End time must be after start time" }
    ],
    "timestamp": "2024-02-05T10:30:00Z",
    "path": "/api/bookings"
  }
}
```

---

## 🔐 Authentication DTOs

### Auth Context
```typescript
interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}

interface AuthContextType extends AuthState {
  login: (email: string, password: string) => Promise<void>;
  loginWithGoogle: () => Promise<void>;
  logout: () => Promise<void>;
  refreshToken: () => Promise<void>;
}
```

### Login Request/Response
```typescript
interface LoginRequest {
  email: string;
  password: string;
}

interface LoginResponse {
  user: User;
  token: string;
  refreshToken: string;
  expiresIn: number; // seconds
}
```

---

## 📊 Dashboard DTOs

### Branch Statistics
```typescript
interface BranchStats {
  branchId: string;
  date: string; // YYYY-MM-DD
  totalBookings: number;
  activeBookings: number;
  completedBookings: number;
  cancelledBookings: number;
  revenue: number; // in cents
  occupancyRate: number; // 0-100
  popularStationType: StationType;
}
```

### Real-time Station Update (WebSocket)
```typescript
interface StationUpdateMessage {
  type: 'STATION_STATUS_CHANGED';
  stationId: string;
  branchId: string;
  oldStatus: StationStatus;
  newStatus: StationStatus;
  bookingId?: string;
  timestamp: string;
}
```

---

## 🎨 UI-Specific Types

### Table State
```typescript
interface TableState {
  page: number;
  pageSize: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
  filters?: Record<string, string | string[]>;
}
```

### Form State
```typescript
interface BookingFormState {
  step: number; // 0-3 (branch, date/time, station, confirmation)
  branchId: string | null;
  date: string | null;
  startTime: string | null;
  endTime: string | null;
  stationType: StationType | null;
  stationId: string | null;
  notes: string;
}
```

### Notification
```typescript
type NotificationType = 'success' | 'error' | 'warning' | 'info';

interface Notification {
  id: string;
  type: NotificationType;
  message: string;
  duration?: number; // milliseconds
  action?: {
    label: string;
    onClick: () => void;
  };
}
```

---

## 🔑 Query Keys (TanStack Query)

Consistent query key structure for caching.

```typescript
const queryKeys = {
  // Branches
  branches: ['branches'] as const,
  branch: (id: string) => ['branches', id] as const,
  
  // Stations
  stations: ['stations'] as const,
  stationsByBranch: (branchId: string) => ['stations', 'branch', branchId] as const,
  station: (id: string) => ['stations', id] as const,
  
  // Availability
  availability: (branchId: string, date: string) => 
    ['availability', branchId, date] as const,
  
  // Bookings
  bookings: ['bookings'] as const,
  bookingsByUser: (userId: string) => ['bookings', 'user', userId] as const,
  bookingsByBranch: (branchId: string, from: string, to: string) => 
    ['bookings', 'branch', branchId, from, to] as const,
  booking: (id: string) => ['bookings', id] as const,
  
  // Users
  users: ['users'] as const,
  user: (id: string) => ['users', id] as const,
  currentUser: ['users', 'current'] as const,
  
  // Stats
  branchStats: (branchId: string, date: string) => 
    ['stats', 'branch', branchId, date] as const,
} as const;

export default queryKeys;
```

---

## 🛠️ Utility Types

### Helper Types
```typescript
// Make all properties optional except specified keys
type PartialExcept<T, K extends keyof T> = Partial<T> & Pick<T, K>;

// Example usage
type UpdateStationRequest = PartialExcept<Station, 'id'>;

// Extract specific fields
type StationSummary = Pick<Station, 'id' | 'name' | 'type' | 'status'>;

// Make specific fields required
type RequiredField<T, K extends keyof T> = T & Required<Pick<T, K>>;
```

---

## 📝 Validation Schemas

Using a validation library (e.g., Zod, Yup), define schemas:

```typescript
import { z } from 'zod';

// Booking validation
export const createBookingSchema = z.object({
  branchId: z.string().uuid(),
  stationId: z.string().uuid(),
  startTime: z.string().datetime(),
  endTime: z.string().datetime(),
  notes: z.string().max(500).optional(),
}).refine(
  (data) => new Date(data.endTime) > new Date(data.startTime),
  { message: "End time must be after start time", path: ["endTime"] }
).refine(
  (data) => {
    const start = new Date(data.startTime);
    const end = new Date(data.endTime);
    const hours = (end.getTime() - start.getTime()) / (1000 * 60 * 60);
    return hours >= 1 && hours <= 8;
  },
  { message: "Duration must be between 1 and 8 hours", path: ["endTime"] }
);

// User validation
export const updateUserSchema = z.object({
  name: z.string().min(2).max(100).optional(),
  phone: z.string().regex(/^\+?[1-9]\d{1,14}$/).optional(),
  role: z.enum(['CUSTOMER', 'STAFF', 'ADMIN']).optional(),
  status: z.enum(['ACTIVE', 'SUSPENDED', 'DELETED']).optional(),
  branchId: z.string().uuid().optional(),
});
```

---

## 💡 Usage Tips

### Type Guards
```typescript
// Check if user is staff
export const isStaff = (user: User): user is User & { role: 'STAFF' } => {
  return user.role === 'STAFF';
};

// Check if booking can be cancelled
export const isCancellable = (booking: Booking): boolean => {
  return ['PENDING', 'CONFIRMED'].includes(booking.status);
};
```

### Type Assertions
```typescript
// Safely parse API response
const parseUser = (data: unknown): User => {
  // Use zod or similar for runtime validation
  return data as User; // Only after validation!
};
```

---

**Next**: [API Contract](./API_CONTRACT.md) to see how these types are used in API endpoints.
