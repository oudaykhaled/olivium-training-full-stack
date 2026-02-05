# API Contract - ArcadeHub

## Overview
Complete REST API specification for the ArcadeHub backend.

**Base URL**: `http://localhost:8080/api`  
**Authentication**: Bearer token in `Authorization` header  
**Content-Type**: `application/json`

---

## 🔐 Authentication Endpoints

### POST `/auth/login`
Email/password authentication.

**Request**:
```json
{
  "email": "john@example.com",
  "password": "securePassword123"
}
```

**Response** `200 OK`:
```json
{
  "user": {
    "id": "usr-001",
    "email": "john@example.com",
    "name": "John Doe",
    "role": "CUSTOMER",
    "status": "ACTIVE"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "refresh_token_here",
  "expiresIn": 3600
}
```

**Errors**:
- `401`: Invalid credentials
- `403`: Account suspended

---

### POST `/auth/register`
Create new customer account.

**Request**:
```json
{
  "email": "jane@example.com",
  "password": "securePassword123",
  "name": "Jane Smith",
  "phone": "+1-555-0199"
}
```

**Response** `201 Created`:
```json
{
  "user": { /* User object */ },
  "token": "...",
  "refreshToken": "...",
  "expiresIn": 3600
}
```

---

### POST `/auth/refresh`
Refresh access token.

**Request**:
```json
{
  "refreshToken": "refresh_token_here"
}
```

**Response** `200 OK`:
```json
{
  "token": "new_access_token",
  "expiresIn": 3600
}
```

---

### POST `/auth/logout`
Invalidate current session.

**Headers**: `Authorization: Bearer <token>`

**Response** `204 No Content`

---

## 🏢 Branch Endpoints

### GET `/branches`
List all branches.

**Query Parameters**:
- `city` (optional): Filter by city

**Response** `200 OK`:
```json
[
  {
    "id": "br-123",
    "name": "Downtown Gaming Hub",
    "address": "123 Main St, Suite 100",
    "city": "San Francisco",
    "phone": "+1-555-0100",
    "email": "downtown@arcadehub.com",
    "openingHours": { /* ... */ },
    "createdAt": "2024-01-15T08:00:00Z",
    "updatedAt": "2024-02-01T10:30:00Z"
  }
]
```

---

### GET `/branches/:id`
Get single branch details.

**Response** `200 OK`:
```json
{
  "id": "br-123",
  "name": "Downtown Gaming Hub",
  /* full branch object */
}
```

**Errors**:
- `404`: Branch not found

---

### POST `/branches`
Create new branch (ADMIN only).

**Headers**: `Authorization: Bearer <admin_token>`

**Request**:
```json
{
  "name": "Westside Arena",
  "address": "456 West St",
  "city": "Los Angeles",
  "phone": "+1-555-0200",
  "email": "westside@arcadehub.com",
  "openingHours": {
    "monday": { "open": "10:00", "close": "23:00", "isClosed": false }
    /* ... */
  }
}
```

**Response** `201 Created`:
```json
{
  "id": "br-456",
  /* full branch object */
}
```

---

## 🎮 Station Endpoints

### GET `/stations`
List all stations with optional filters.

**Query Parameters**:
- `branchId` (required): Filter by branch
- `type` (optional): Filter by type (PC, PS5, XBOX, etc.)
- `status` (optional): Filter by status (FREE, OCCUPIED, etc.)

**Response** `200 OK`:
```json
[
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
    "features": ["mechanical-keyboard", "gaming-mouse"],
    "imageUrl": "https://cdn.arcadehub.com/stations/pc-5.jpg",
    "createdAt": "2024-01-15T08:00:00Z",
    "updatedAt": "2024-02-05T14:20:00Z"
  }
]
```

---

### GET `/stations/:id`
Get single station details.

**Response** `200 OK`:
```json
{
  "id": "st-456",
  /* full station object */
}
```

---

### PATCH `/stations/:id`
Update station (STAFF/ADMIN only).

**Headers**: `Authorization: Bearer <staff_or_admin_token>`

**Request**:
```json
{
  "status": "MAINTENANCE",
  "pricePerHour": 1800
}
```

**Response** `200 OK`:
```json
{
  "id": "st-456",
  /* updated station object */
}
```

---

## 📅 Availability Endpoint

### GET `/availability`
Check station availability for a specific date.

**Query Parameters**:
- `branchId` (required): Branch ID
- `date` (required): Date in YYYY-MM-DD format
- `stationType` (optional): Filter by station type

**Response** `200 OK`:
```json
{
  "date": "2024-02-10",
  "branch": {
    "id": "br-123",
    "name": "Downtown Gaming Hub"
  },
  "stations": [
    {
      "station": {
        "id": "st-456",
        "name": "Gaming PC #5",
        "type": "PC",
        "pricePerHour": 1500
      },
      "availableSlots": [
        {
          "startTime": "09:00",
          "endTime": "12:00",
          "isAvailable": true
        },
        {
          "startTime": "12:00",
          "endTime": "15:00",
          "isAvailable": false,
          "bookingId": "bk-789"
        },
        {
          "startTime": "15:00",
          "endTime": "23:00",
          "isAvailable": true
        }
      ]
    }
  ]
}
```

**Errors**:
- `400`: Invalid date format
- `404`: Branch not found

---

## 📝 Booking Endpoints

### GET `/bookings`
List bookings with filters.

**Query Parameters**:
- `userId` (optional): Filter by user (CUSTOMER sees only their own)
- `branchId` (optional): Filter by branch
- `from` (optional): Start date (YYYY-MM-DD)
- `to` (optional): End date (YYYY-MM-DD)
- `status` (optional): Filter by status
- `page` (optional): Page number (default: 1)
- `pageSize` (optional): Items per page (default: 20)

**Response** `200 OK`:
```json
{
  "data": [
    {
      "id": "bk-789",
      "user": {
        "id": "usr-001",
        "name": "John Doe",
        "email": "john@example.com",
        "phone": "+1-555-0123"
      },
      "branch": {
        "id": "br-123",
        "name": "Downtown Gaming Hub",
        "address": "123 Main St"
      },
      "station": {
        "id": "st-456",
        "name": "Gaming PC #5",
        "type": "PC",
        "pricePerHour": 1500
      },
      "startTime": "2024-02-10T14:00:00Z",
      "endTime": "2024-02-10T17:00:00Z",
      "status": "CONFIRMED",
      "totalPrice": 4500,
      "duration": 3,
      "notes": "Birthday party",
      "createdAt": "2024-02-05T10:00:00Z",
      "updatedAt": "2024-02-05T10:05:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalCount": 45,
    "totalPages": 3,
    "hasNextPage": true,
    "hasPreviousPage": false
  }
}
```

---

### GET `/bookings/:id`
Get single booking details.

**Response** `200 OK`:
```json
{
  "id": "bk-789",
  /* full booking with relations */
}
```

**Errors**:
- `404`: Booking not found
- `403`: Not authorized to view this booking

---

### POST `/bookings`
Create new booking.

**Headers**: `Authorization: Bearer <token>`

**Request**:
```json
{
  "branchId": "br-123",
  "stationId": "st-456",
  "startTime": "2024-02-10T14:00:00Z",
  "endTime": "2024-02-10T17:00:00Z",
  "notes": "Birthday party - need extra controller"
}
```

**Response** `201 Created`:
```json
{
  "id": "bk-789",
  /* full booking object */
}
```

**Errors**:
- `400`: Validation errors (invalid times, station unavailable)
- `404`: Station or branch not found
- `409`: Station already booked for this time slot

**Validation Rules**:
- `startTime` must be in the future
- `endTime` must be after `startTime`
- Duration: 1-8 hours
- Station must be available for entire slot

---

### PATCH `/bookings/:id`
Update booking status.

**Headers**: `Authorization: Bearer <token>`

**Request**:
```json
{
  "status": "CHECKED_IN"
}
```

**Valid Status Transitions**:
- PENDING → CONFIRMED, CANCELLED
- CONFIRMED → CHECKED_IN, CANCELLED, NO_SHOW
- CHECKED_IN → COMPLETED

**Response** `200 OK`:
```json
{
  "id": "bk-789",
  /* updated booking */
}
```

**Errors**:
- `400`: Invalid status transition
- `403`: Not authorized (customers can only cancel their own bookings)
- `404`: Booking not found

---

### DELETE `/bookings/:id`
Cancel booking (CUSTOMER can cancel their own, STAFF/ADMIN can cancel any).

**Headers**: `Authorization: Bearer <token>`

**Response** `204 No Content`

**Errors**:
- `400`: Cannot cancel completed or already cancelled booking
- `403`: Not authorized
- `404`: Booking not found

---

## 👥 User Endpoints

### GET `/users/me`
Get current user profile.

**Headers**: `Authorization: Bearer <token>`

**Response** `200 OK`:
```json
{
  "id": "usr-001",
  "email": "john@example.com",
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

### PATCH `/users/me`
Update own profile.

**Headers**: `Authorization: Bearer <token>`

**Request**:
```json
{
  "name": "John Smith",
  "phone": "+1-555-9999"
}
```

**Response** `200 OK`:
```json
{
  /* updated user object */
}
```

---

### GET `/users`
List all users (ADMIN only).

**Headers**: `Authorization: Bearer <admin_token>`

**Query Parameters**:
- `role` (optional): Filter by role
- `status` (optional): Filter by status
- `search` (optional): Search by name or email
- `page` (optional): Page number
- `pageSize` (optional): Items per page
- `sortBy` (optional): Field to sort by (name, email, createdAt)
- `sortOrder` (optional): asc or desc

**Response** `200 OK`:
```json
{
  "data": [
    {
      "id": "usr-001",
      /* user object */
    }
  ],
  "pagination": { /* ... */ }
}
```

---

### GET `/users/:id`
Get user details (ADMIN only, or own profile).

**Response** `200 OK`:
```json
{
  "id": "usr-001",
  /* user object */
}
```

---

### PATCH `/users/:id`
Update user (ADMIN only).

**Headers**: `Authorization: Bearer <admin_token>`

**Request**:
```json
{
  "role": "STAFF",
  "branchId": "br-123",
  "status": "ACTIVE"
}
```

**Response** `200 OK`:
```json
{
  /* updated user object */
}
```

**Errors**:
- `400`: Validation error (e.g., STAFF without branchId)
- `403`: Cannot change own role or status
- `404`: User not found

---

## 📊 Statistics Endpoints (ADMIN/STAFF)

### GET `/stats/branch/:branchId`
Get branch statistics for a specific date.

**Headers**: `Authorization: Bearer <staff_or_admin_token>`

**Query Parameters**:
- `date` (required): Date in YYYY-MM-DD format

**Response** `200 OK`:
```json
{
  "branchId": "br-123",
  "date": "2024-02-05",
  "totalBookings": 45,
  "activeBookings": 12,
  "completedBookings": 30,
  "cancelledBookings": 3,
  "revenue": 45000,
  "occupancyRate": 75.5,
  "popularStationType": "PC"
}
```

---

## 🔴 Error Responses

All errors follow this format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": [
      {
        "field": "fieldName",
        "message": "Specific field error"
      }
    ],
    "timestamp": "2024-02-05T10:30:00Z",
    "path": "/api/bookings"
  }
}
```

### Common Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `VALIDATION_ERROR` | 400 | Request validation failed |
| `UNAUTHORIZED` | 401 | Missing or invalid token |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `CONFLICT` | 409 | Resource conflict (e.g., duplicate booking) |
| `INTERNAL_ERROR` | 500 | Server error |

---

## 🔌 WebSocket API (Real-time Updates)

### Connection
```
ws://localhost:8080/ws/stations
```

**Query Parameters**:
- `token`: JWT access token
- `branchId`: Branch to subscribe to

### Message Format

**Server → Client (Station Update)**:
```json
{
  "type": "STATION_STATUS_CHANGED",
  "stationId": "st-456",
  "branchId": "br-123",
  "oldStatus": "FREE",
  "newStatus": "OCCUPIED",
  "bookingId": "bk-789",
  "timestamp": "2024-02-05T14:30:00Z"
}
```

**Client → Server (Subscribe)**:
```json
{
  "type": "SUBSCRIBE",
  "branchId": "br-123"
}
```

**Server → Client (Acknowledgment)**:
```json
{
  "type": "SUBSCRIBED",
  "branchId": "br-123"
}
```

**Client → Server (Unsubscribe)**:
```json
{
  "type": "UNSUBSCRIBE",
  "branchId": "br-123"
}
```

---

## 📦 Mock API Server

For local development, use the included mock API server:

```bash
cd mock-api
npm install
npm start
```

The mock server:
- Accepts any non-empty Bearer token
- Uses in-memory data (resets on restart)
- Includes seed data for testing
- Logs all requests
- Simulates network delays (100-500ms)

### Seed Data
- 3 branches (San Francisco, Los Angeles, New York)
- 20 stations per branch (mix of PCs, consoles, rooms)
- 50 bookings across next 30 days
- 10 users (2 admins, 3 staff, 5 customers)

### Test Credentials
```
Admin:
  email: admin@arcadehub.com
  password: admin123

Staff:
  email: staff@arcadehub.com
  password: staff123

Customer:
  email: customer@arcadehub.com
  password: customer123
```

---

## 🧪 Testing Tips

### Postman/Insomnia
Import the provided OpenAPI spec or use these collections:
- `arcadehub-api.postman_collection.json`
- Environment variables for local/dev/prod

### cURL Examples

**Login**:
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"customer@arcadehub.com","password":"customer123"}'
```

**Get Branches**:
```bash
curl http://localhost:8080/api/branches
```

**Create Booking** (with auth):
```bash
curl -X POST http://localhost:8080/api/bookings \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "branchId": "br-123",
    "stationId": "st-456",
    "startTime": "2024-02-10T14:00:00Z",
    "endTime": "2024-02-10T17:00:00Z"
  }'
```

---

## 📝 Notes

1. **Timestamps**: All timestamps are in UTC (ISO 8601 format)
2. **Prices**: All prices in cents (e.g., 1500 = $15.00)
3. **Pagination**: Default page size is 20, max is 100
4. **Rate Limiting**: 100 requests per minute per IP (in real backend)
5. **CORS**: Enabled for `http://localhost:*` in development

---

**Next**: See [Step 4 - API Client](./steps/step-04-api-client.md) for implementation guide.
