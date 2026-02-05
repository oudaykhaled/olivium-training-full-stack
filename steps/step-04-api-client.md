# Step 4: API Client + TanStack Query Foundation

**Duration**: 2 days  
**Complexity**: ⭐⭐ Intermediate

---

## 🎯 Objectives

By the end of this step, you will have:
- ✅ Mock API server running with seed data
- ✅ Shared API client package with Axios
- ✅ Request/response interceptors for auth and error handling
- ✅ TanStack Query (React Query) configured
- ✅ Custom hooks for data fetching (useBranches, useStations)
- ✅ Proper loading and error states in UI
- ✅ Query keys defined in a consistent structure

---

## 📐 Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                  Frontend Apps                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │         TanStack Query Provider                  │   │
│  │  ┌──────────────────────────────────────────┐   │   │
│  │  │  Custom Hooks (useBranches, etc.)        │   │   │
│  │  │  ↓                                        │   │   │
│  │  │  API Client (Axios)                      │   │   │
│  │  │  ↓                                        │   │   │
│  │  │  Interceptors (auth, errors)             │   │   │
│  │  └──────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                        ↓ HTTP
┌─────────────────────────────────────────────────────────┐
│              Mock API Server (Express)                  │
│  • GET /api/branches                                    │
│  • GET /api/stations                                    │
│  • GET /api/bookings                                    │
│  • POST /api/bookings                                   │
│  • ... (all endpoints)                                  │
└─────────────────────────────────────────────────────────┘
```

---

## 📝 Detailed Implementation

### 4.1 Create Mock API Server

```bash
mkdir -p mock-api/data
cd mock-api
npm init -y
```

Install dependencies:

```bash
npm install express cors body-parser uuid
npm install --save-dev nodemon
```

Edit **`mock-api/package.json`**:

```json
{
  "name": "arcadehub-mock-api",
  "version": "1.0.0",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "cors": "^2.8.5",
    "body-parser": "^1.20.0",
    "uuid": "^9.0.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.0"
  }
}
```

---

### 4.2 Create Seed Data

**`mock-api/data/branches.json`**:

```json
[
  {
    "id": "br-001",
    "name": "Downtown Gaming Hub",
    "address": "123 Main St, Suite 100",
    "city": "San Francisco",
    "phone": "+1-555-0100",
    "email": "downtown@arcadehub.com",
    "openingHours": {
      "monday": { "open": "10:00", "close": "23:00", "isClosed": false },
      "tuesday": { "open": "10:00", "close": "23:00", "isClosed": false },
      "wednesday": { "open": "10:00", "close": "23:00", "isClosed": false },
      "thursday": { "open": "10:00", "close": "23:00", "isClosed": false },
      "friday": { "open": "10:00", "close": "02:00", "isClosed": false },
      "saturday": { "open": "10:00", "close": "02:00", "isClosed": false },
      "sunday": { "open": "12:00", "close": "20:00", "isClosed": false }
    },
    "createdAt": "2024-01-15T08:00:00Z",
    "updatedAt": "2024-02-01T10:30:00Z"
  },
  {
    "id": "br-002",
    "name": "Westside Arena",
    "address": "456 West Ave, Floor 2",
    "city": "Los Angeles",
    "phone": "+1-555-0200",
    "email": "westside@arcadehub.com",
    "openingHours": {
      "monday": { "open": "09:00", "close": "22:00", "isClosed": false },
      "tuesday": { "open": "09:00", "close": "22:00", "isClosed": false },
      "wednesday": { "open": "09:00", "close": "22:00", "isClosed": false },
      "thursday": { "open": "09:00", "close": "22:00", "isClosed": false },
      "friday": { "open": "09:00", "close": "01:00", "isClosed": false },
      "saturday": { "open": "09:00", "close": "01:00", "isClosed": false },
      "sunday": { "open": "11:00", "close": "21:00", "isClosed": false }
    },
    "createdAt": "2024-01-20T08:00:00Z",
    "updatedAt": "2024-02-01T10:30:00Z"
  }
]
```

**`mock-api/data/stations.json`**:

```json
[
  {
    "id": "st-001",
    "branchId": "br-001",
    "name": "Gaming PC #1",
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
    "imageUrl": "https://picsum.photos/400/300?random=1",
    "createdAt": "2024-01-15T08:00:00Z",
    "updatedAt": "2024-02-05T14:20:00Z"
  },
  {
    "id": "st-002",
    "branchId": "br-001",
    "name": "PS5 Station #1",
    "type": "PS5",
    "status": "FREE",
    "pricePerHour": 1200,
    "features": ["2-controllers", "headset", "4k-tv"],
    "imageUrl": "https://picsum.photos/400/300?random=2",
    "createdAt": "2024-01-15T08:00:00Z",
    "updatedAt": "2024-02-05T14:20:00Z"
  },
  {
    "id": "st-003",
    "branchId": "br-001",
    "name": "VR Room #1",
    "type": "VR_ROOM",
    "status": "OCCUPIED",
    "pricePerHour": 2500,
    "features": ["meta-quest-3", "full-body-tracking", "private-room"],
    "imageUrl": "https://picsum.photos/400/300?random=3",
    "currentBookingId": "bk-001",
    "createdAt": "2024-01-15T08:00:00Z",
    "updatedAt": "2024-02-05T15:00:00Z"
  }
]
```

Create similar seed data for users and bookings (see DATA_MODELS.md for structure).

---

### 4.3 Create Express Server

**`mock-api/server.js`**:

```javascript
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { v4: uuidv4 } = require('uuid');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 8080;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Simple request logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Simple auth middleware (accepts any non-empty token)
const authMiddleware = (req, res, next) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      error: {
        code: 'UNAUTHORIZED',
        message: 'Missing or invalid authorization header',
        timestamp: new Date().toISOString(),
        path: req.path,
      },
    });
  }
  
  // In mock, we accept any token
  req.userId = 'usr-001'; // Mock user ID
  req.userRole = 'CUSTOMER'; // Mock role
  next();
};

// Load seed data
const loadData = (filename) => {
  const filePath = path.join(__dirname, 'data', filename);
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
};

let branches = loadData('branches.json');
let stations = loadData('stations.json');
let bookings = [];
let users = loadData('users.json');

// ============= BRANCHES =============

app.get('/api/branches', (req, res) => {
  const { city } = req.query;
  
  let filtered = branches;
  if (city) {
    filtered = branches.filter((b) => b.city.toLowerCase() === city.toLowerCase());
  }
  
  setTimeout(() => res.json(filtered), 200); // Simulate network delay
});

app.get('/api/branches/:id', (req, res) => {
  const branch = branches.find((b) => b.id === req.params.id);
  
  if (!branch) {
    return res.status(404).json({
      error: {
        code: 'NOT_FOUND',
        message: 'Branch not found',
        timestamp: new Date().toISOString(),
        path: req.path,
      },
    });
  }
  
  setTimeout(() => res.json(branch), 200);
});

// ============= STATIONS =============

app.get('/api/stations', (req, res) => {
  const { branchId, type, status } = req.query;
  
  let filtered = stations;
  
  if (branchId) {
    filtered = filtered.filter((s) => s.branchId === branchId);
  }
  
  if (type) {
    filtered = filtered.filter((s) => s.type === type);
  }
  
  if (status) {
    filtered = filtered.filter((s) => s.status === status);
  }
  
  setTimeout(() => res.json(filtered), 200);
});

app.get('/api/stations/:id', (req, res) => {
  const station = stations.find((s) => s.id === req.params.id);
  
  if (!station) {
    return res.status(404).json({
      error: {
        code: 'NOT_FOUND',
        message: 'Station not found',
        timestamp: new Date().toISOString(),
        path: req.path,
      },
    });
  }
  
  setTimeout(() => res.json(station), 200);
});

// ============= BOOKINGS =============

app.get('/api/bookings', authMiddleware, (req, res) => {
  const { userId, branchId, status, page = 1, pageSize = 20 } = req.query;
  
  let filtered = bookings;
  
  // For customers, only show their own bookings
  if (req.userRole === 'CUSTOMER') {
    filtered = filtered.filter((b) => b.userId === req.userId);
  } else if (userId) {
    filtered = filtered.filter((b) => b.userId === userId);
  }
  
  if (branchId) {
    filtered = filtered.filter((b) => b.branchId === branchId);
  }
  
  if (status) {
    filtered = filtered.filter((b) => b.status === status);
  }
  
  // Pagination
  const start = (page - 1) * pageSize;
  const end = start + parseInt(pageSize);
  const paginatedData = filtered.slice(start, end);
  
  // Enrich with relations
  const enriched = paginatedData.map((booking) => {
    const user = users.find((u) => u.id === booking.userId);
    const branch = branches.find((b) => b.id === booking.branchId);
    const station = stations.find((s) => s.id === booking.stationId);
    
    return {
      ...booking,
      user: user ? { id: user.id, name: user.name, email: user.email } : null,
      branch: branch ? { id: branch.id, name: branch.name } : null,
      station: station ? { id: station.id, name: station.name, type: station.type } : null,
    };
  });
  
  setTimeout(() => {
    res.json({
      data: enriched,
      pagination: {
        page: parseInt(page),
        pageSize: parseInt(pageSize),
        totalCount: filtered.length,
        totalPages: Math.ceil(filtered.length / pageSize),
        hasNextPage: end < filtered.length,
        hasPreviousPage: page > 1,
      },
    });
  }, 300);
});

app.post('/api/bookings', authMiddleware, (req, res) => {
  const { branchId, stationId, startTime, endTime, notes } = req.body;
  
  // Basic validation
  if (!branchId || !stationId || !startTime || !endTime) {
    return res.status(400).json({
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Missing required fields',
        details: [
          { field: 'branchId', message: 'Branch ID is required' },
          { field: 'stationId', message: 'Station ID is required' },
          { field: 'startTime', message: 'Start time is required' },
          { field: 'endTime', message: 'End time is required' },
        ],
        timestamp: new Date().toISOString(),
        path: req.path,
      },
    });
  }
  
  // Check if station exists
  const station = stations.find((s) => s.id === stationId);
  if (!station) {
    return res.status(404).json({
      error: {
        code: 'NOT_FOUND',
        message: 'Station not found',
        timestamp: new Date().toISOString(),
        path: req.path,
      },
    });
  }
  
  // Calculate price (simplified)
  const start = new Date(startTime);
  const end = new Date(endTime);
  const hours = (end - start) / (1000 * 60 * 60);
  const totalPrice = station.pricePerHour * hours;
  
  // Create booking
  const newBooking = {
    id: `bk-${uuidv4()}`,
    userId: req.userId,
    branchId,
    stationId,
    startTime,
    endTime,
    status: 'PENDING',
    totalPrice: Math.round(totalPrice),
    notes: notes || '',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
  
  bookings.push(newBooking);
  
  setTimeout(() => res.status(201).json(newBooking), 300);
});

// ============= AVAILABILITY =============

app.get('/api/availability', (req, res) => {
  const { branchId, date } = req.query;
  
  if (!branchId || !date) {
    return res.status(400).json({
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Branch ID and date are required',
        timestamp: new Date().toISOString(),
        path: req.path,
      },
    });
  }
  
  const branch = branches.find((b) => b.id === branchId);
  const branchStations = stations.filter((s) => s.branchId === branchId);
  
  // Simplified availability (all stations available for now)
  const availability = branchStations.map((station) => ({
    station: {
      id: station.id,
      name: station.name,
      type: station.type,
      pricePerHour: station.pricePerHour,
    },
    availableSlots: [
      { startTime: '09:00', endTime: '12:00', isAvailable: true },
      { startTime: '12:00', endTime: '15:00', isAvailable: true },
      { startTime: '15:00', endTime: '18:00', isAvailable: true },
      { startTime: '18:00', endTime: '21:00', isAvailable: true },
      { startTime: '21:00', endTime: '23:00', isAvailable: true },
    ],
  }));
  
  setTimeout(() => {
    res.json({
      date,
      branch: { id: branch.id, name: branch.name },
      stations: availability,
    });
  }, 300);
});

// ============= HEALTH CHECK =============

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Mock API server running on http://localhost:${PORT}`);
  console.log(`   Branches: ${branches.length}`);
  console.log(`   Stations: ${stations.length}`);
  console.log(`   Users: ${users.length}`);
});
```

---

### 4.4 Create Shared API Client Package

```bash
mkdir -p frontend/shared-api-client/src
cd frontend/shared-api-client
npm init -y
```

Edit **`frontend/shared-api-client/package.json`**:

```json
{
  "name": "shared-api-client",
  "version": "1.0.0",
  "main": "src/index.ts",
  "dependencies": {
    "axios": "^1.6.0",
    "@tanstack/react-query": "^5.17.0"
  },
  "peerDependencies": {
    "react": "^18.2.0"
  }
}
```

---

### 4.5 Create API Client

**`frontend/shared-api-client/src/api-client.ts`**:

```typescript
import axios, { AxiosError, InternalAxiosRequestConfig } from 'axios';

const BASE_URL = process.env.API_BASE_URL || 'http://localhost:8080/api';

// Create axios instance
export const apiClient = axios.create({
  baseURL: BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor - add auth token
apiClient.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = localStorage.getItem('authToken');
    
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    // Log requests in development
    if (process.env.NODE_ENV === 'development') {
      console.log(`→ ${config.method?.toUpperCase()} ${config.url}`, config.data || '');
    }
    
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor - handle errors
apiClient.interceptors.response.use(
  (response) => {
    // Log responses in development
    if (process.env.NODE_ENV === 'development') {
      console.log(`← ${response.status} ${response.config.url}`, response.data);
    }
    
    return response;
  },
  (error: AxiosError) => {
    // Log errors
    console.error(`✖ ${error.config?.url}`, error.response?.data || error.message);
    
    // Handle specific error cases
    if (error.response?.status === 401) {
      // Unauthorized - clear token and redirect to login
      localStorage.removeItem('authToken');
      // You can dispatch a logout action here if using state management
      window.location.href = '/login';
    }
    
    return Promise.reject(error);
  }
);
```

---

### 4.6 Define Query Keys

**`frontend/shared-api-client/src/query-keys.ts`**:

```typescript
export const queryKeys = {
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
  booking: (id: string) => ['bookings', id] as const,
  
  // Users
  users: ['users'] as const,
  user: (id: string) => ['users', id] as const,
  currentUser: ['users', 'current'] as const,
} as const;
```

---

### 4.7 Create Custom Hooks

**`frontend/shared-api-client/src/hooks/useBranches.ts`**:

```typescript
import { useQuery } from '@tanstack/react-query';
import { apiClient } from '../api-client';
import { queryKeys } from '../query-keys';
import type { Branch } from '../types';

export function useBranches() {
  return useQuery({
    queryKey: queryKeys.branches,
    queryFn: async () => {
      const response = await apiClient.get<Branch[]>('/branches');
      return response.data;
    },
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}

export function useBranch(id: string) {
  return useQuery({
    queryKey: queryKeys.branch(id),
    queryFn: async () => {
      const response = await apiClient.get<Branch>(`/branches/${id}`);
      return response.data;
    },
    enabled: !!id,
  });
}
```

**`frontend/shared-api-client/src/hooks/useStations.ts`**:

```typescript
import { useQuery } from '@tanstack/react-query';
import { apiClient } from '../api-client';
import { queryKeys } from '../query-keys';
import type { Station } from '../types';

interface UseStationsParams {
  branchId: string;
  type?: string;
  status?: string;
}

export function useStations({ branchId, type, status }: UseStationsParams) {
  return useQuery({
    queryKey: [...queryKeys.stationsByBranch(branchId), { type, status }],
    queryFn: async () => {
      const params = new URLSearchParams();
      params.append('branchId', branchId);
      if (type) params.append('type', type);
      if (status) params.append('status', status);
      
      const response = await apiClient.get<Station[]>(`/stations?${params}`);
      return response.data;
    },
    enabled: !!branchId,
    staleTime: 30 * 1000, // 30 seconds (stations change more frequently)
  });
}
```

---

### 4.8 Export Everything

**`frontend/shared-api-client/src/index.ts`**:

```typescript
export { apiClient } from './api-client';
export { queryKeys } from './query-keys';
export * from './hooks/useBranches';
export * from './hooks/useStations';
export * from './types';
```

---

### 4.9 Configure TanStack Query in Container Shell

**`frontend/container-shell/src/App.tsx`**:

```typescript
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { RouterProvider } from 'react-router-dom';
import { router } from './routes';

// Create a client
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
      staleTime: 60 * 1000, // 1 minute default
    },
    mutations: {
      retry: 0,
    },
  },
});

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <RouterProvider router={router} />
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  );
}

export default App;
```

---

### 4.10 Use Hooks in Components

Update **`frontend/container-shell/src/pages/BranchesPage.tsx`**:

```typescript
import { Container, Typography, Grid, Card, CardContent, CircularProgress, Alert } from '@mui/material';
import { useBranches } from 'shared-api-client';

export function BranchesPage() {
  const { data: branches, isLoading, isError, error } = useBranches();

  if (isLoading) {
    return (
      <Container sx={{ display: 'flex', justifyContent: 'center', py: 8 }}>
        <CircularProgress />
      </Container>
    );
  }

  if (isError) {
    return (
      <Container>
        <Alert severity="error">
          Failed to load branches: {error instanceof Error ? error.message : 'Unknown error'}
        </Alert>
      </Container>
    );
  }

  if (!branches || branches.length === 0) {
    return (
      <Container>
        <Typography variant="h5">No branches found</Typography>
      </Container>
    );
  }

  return (
    <Container maxWidth="lg">
      <Typography variant="h3" gutterBottom sx={{ mb: 4 }}>
        Our Branches
      </Typography>
      <Grid container spacing={3}>
        {branches.map((branch) => (
          <Grid item xs={12} md={6} key={branch.id}>
            <Card>
              <CardContent>
                <Typography variant="h5" gutterBottom>
                  {branch.name}
                </Typography>
                <Typography variant="body2" color="text.secondary" paragraph>
                  {branch.address}
                </Typography>
                <Typography variant="body2">
                  {branch.city}
                </Typography>
                <Typography variant="body2">
                  📞 {branch.phone}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>
    </Container>
  );
}
```

---

## ✅ Definition of Done

### Functionality
- [ ] Mock API server runs on port 8080
- [ ] GET /api/branches returns branches list
- [ ] GET /api/stations returns stations list
- [ ] Branches page displays branches from API
- [ ] Loading spinner shows while fetching
- [ ] Error message shows if API fails
- [ ] React Query Devtools accessible in browser

### Code Quality
- [ ] Types defined for all API responses
- [ ] Query keys defined centrally
- [ ] Error handling in API client
- [ ] Auth token interceptor configured
- [ ] TypeScript errors resolved

---

## 🧪 Testing Checklist

```bash
# Start mock API
cd mock-api
npm run dev

# Test endpoints manually
curl http://localhost:8080/health
curl http://localhost:8080/api/branches
curl http://localhost:8080/api/stations

# Start frontend
cd frontend/container-shell
npm run dev

# Visit http://localhost:3000/branches
# Should see list of branches from API

# Open React Query Devtools (floating icon)
# Should see "branches" query with data

# Test error handling:
# 1. Stop mock API server
# 2. Refresh /branches page
# 3. Should see error message

# Test loading state:
# 1. Throttle network in DevTools (Slow 3G)
# 2. Refresh page
# 3. Should see loading spinner
```

---

## 💡 Tips & Best Practices

### Query Keys
- Use arrays, not strings
- Include all query parameters in key
- Keep them hierarchical for easy invalidation

### Stale Time
- Short (30s) for frequently changing data (stations)
- Long (5min) for rarely changing data (branches)
- Tune based on your needs

### Error Handling
- Always show user-friendly errors
- Log full errors to console for debugging
- Provide retry options where appropriate

---

## ⚠️ Common Pitfalls

See [COMMON_PITFALLS.md](../COMMON_PITFALLS.md) - Section "API & TanStack Query Issues"

---

## 🎯 What's Next?

Once API integration works, move on to [Step 5: Authentication](./step-05-authentication.md) where you'll add Firebase Auth and protect routes.

---

**Estimated Time**: 12-16 hours  
**Difficulty**: Medium - API integration is fundamental
