# Tips & Tricks - Pro Techniques for ArcadeHub

## Overview
These are battle-tested patterns, shortcuts, and techniques that will make your development faster and your code better.

---

## 🚀 Development Speed Tips

### Use Code Snippets

Create VS Code snippets for common patterns:

**File**: `.vscode/react.code-snippets`
```json
{
  "React Function Component": {
    "prefix": "rfc",
    "body": [
      "interface ${1:ComponentName}Props {",
      "  $2",
      "}",
      "",
      "export function ${1:ComponentName}({ $3 }: ${1:ComponentName}Props) {",
      "  return (",
      "    <div>",
      "      $0",
      "    </div>",
      "  );",
      "}"
    ]
  },
  "TanStack Query Hook": {
    "prefix": "usequery",
    "body": [
      "export function use${1:ResourceName}() {",
      "  return useQuery({",
      "    queryKey: ['${2:key}'],",
      "    queryFn: ${3:fetchFunction},",
      "  });",
      "}"
    ]
  }
}
```

Type `rfc` + Tab → instant component template!

---

### Hot Reload Pro Tips

```typescript
// Preserve state during hot reload
if (import.meta.hot) {
  import.meta.hot.accept();
}

// Or use React Fast Refresh (auto-enabled in Webpack 5)
```

---

### Parallel Development Trick

Run multiple apps simultaneously:

```json
// package.json
"scripts": {
  "dev:all": "concurrently \"npm run dev -w container-shell\" \"npm run dev -w bookings-app\" \"npm run dev -w stations-app\"",
}
```

```bash
npm install -D concurrently
npm run dev:all
```

---

## 🎨 UI/UX Pro Patterns

### Loading States Pattern

Don't repeat yourself - create a reusable component:

```typescript
// shared-ui-lib/src/components/QueryWrapper.tsx
interface QueryWrapperProps<T> {
  query: UseQueryResult<T>;
  children: (data: T) => React.ReactNode;
  loadingComponent?: React.ReactNode;
  errorComponent?: React.ReactNode;
}

export function QueryWrapper<T>({
  query,
  children,
  loadingComponent,
  errorComponent,
}: QueryWrapperProps<T>) {
  if (query.isLoading) {
    return loadingComponent || <CircularProgress />;
  }

  if (query.isError) {
    return errorComponent || <Alert severity="error">Failed to load data</Alert>;
  }

  if (!query.data) {
    return null;
  }

  return <>{children(query.data)}</>;
}

// Usage
<QueryWrapper query={useBookings()}>
  {(bookings) => <BookingsList bookings={bookings} />}
</QueryWrapper>
```

---

### Empty State Pattern

```typescript
// shared-ui-lib/src/components/EmptyState.tsx
interface EmptyStateProps {
  icon: React.ReactNode;
  title: string;
  description: string;
  action?: {
    label: string;
    onClick: () => void;
  };
}

export function EmptyState({ icon, title, description, action }: EmptyStateProps) {
  return (
    <Box sx={{ textAlign: 'center', py: 8 }}>
      {icon}
      <Typography variant="h5" gutterBottom sx={{ mt: 2 }}>
        {title}
      </Typography>
      <Typography variant="body2" color="text.secondary" paragraph>
        {description}
      </Typography>
      {action && (
        <Button variant="contained" onClick={action.onClick}>
          {action.label}
        </Button>
      )}
    </Box>
  );
}

// Usage
{bookings.length === 0 && (
  <EmptyState
    icon={<EventIcon sx={{ fontSize: 80, color: 'text.secondary' }} />}
    title="No Bookings Yet"
    description="You haven't made any bookings. Start by browsing our branches!"
    action={{ label: 'Browse Branches', onClick: () => navigate('/branches') }}
  />
)}
```

---

### Notification System

Create a global toast notification system:

```typescript
// container-shell/src/contexts/NotificationContext.tsx
import { createContext, useContext, useState, useCallback } from 'react';
import { Snackbar, Alert, AlertColor } from '@mui/material';

interface Notification {
  id: string;
  message: string;
  severity: AlertColor;
}

interface NotificationContextType {
  showNotification: (message: string, severity?: AlertColor) => void;
}

const NotificationContext = createContext<NotificationContextType | undefined>(undefined);

export function NotificationProvider({ children }: { children: React.ReactNode }) {
  const [notification, setNotification] = useState<Notification | null>(null);

  const showNotification = useCallback((message: string, severity: AlertColor = 'info') => {
    setNotification({
      id: Date.now().toString(),
      message,
      severity,
    });
  }, []);

  const handleClose = () => setNotification(null);

  return (
    <NotificationContext.Provider value={{ showNotification }}>
      {children}
      {notification && (
        <Snackbar
          open
          autoHideDuration={6000}
          onClose={handleClose}
          anchorOrigin={{ vertical: 'top', horizontal: 'right' }}
        >
          <Alert onClose={handleClose} severity={notification.severity}>
            {notification.message}
          </Alert>
        </Snackbar>
      )}
    </NotificationContext.Provider>
  );
}

export const useNotification = () => {
  const context = useContext(NotificationContext);
  if (!context) throw new Error('useNotification must be used within NotificationProvider');
  return context;
};

// Usage
const { showNotification } = useNotification();
showNotification('Booking created successfully!', 'success');
```

---

## 🔄 TanStack Query Pro Patterns

### Prefetch Pattern

Speed up navigation by prefetching data:

```typescript
// Prefetch on hover
const queryClient = useQueryClient();

const handleMouseEnter = () => {
  queryClient.prefetchQuery({
    queryKey: ['booking', bookingId],
    queryFn: () => fetchBooking(bookingId),
  });
};

<Card onMouseEnter={handleMouseEnter} onClick={handleClick}>
  {/* Card content */}
</Card>
```

---

### Dependent Queries Pattern

```typescript
// Fetch user, then fetch their bookings
const { data: user } = useQuery({
  queryKey: ['users', 'current'],
  queryFn: fetchCurrentUser,
});

const { data: bookings } = useQuery({
  queryKey: ['bookings', 'user', user?.id],
  queryFn: () => fetchUserBookings(user!.id),
  enabled: !!user, // Only run if user exists
});
```

---

### Infinite Scroll Pattern

```typescript
const {
  data,
  fetchNextPage,
  hasNextPage,
  isFetchingNextPage,
} = useInfiniteQuery({
  queryKey: ['bookings'],
  queryFn: ({ pageParam = 1 }) => fetchBookings({ page: pageParam }),
  getNextPageParam: (lastPage) => lastPage.nextPage,
});

// Use with Intersection Observer
const loadMoreRef = useRef<HTMLDivElement>(null);

useEffect(() => {
  const observer = new IntersectionObserver((entries) => {
    if (entries[0].isIntersecting && hasNextPage) {
      fetchNextPage();
    }
  });

  if (loadMoreRef.current) {
    observer.observe(loadMoreRef.current);
  }

  return () => observer.disconnect();
}, [hasNextPage, fetchNextPage]);
```

---

## 🔐 Auth Pro Patterns

### Token Refresh Interceptor

```typescript
// Automatically refresh expired tokens
apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        const newToken = await refreshToken();
        originalRequest.headers.Authorization = `Bearer ${newToken}`;
        return apiClient(originalRequest);
      } catch (refreshError) {
        // Refresh failed, logout user
        logout();
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);
```

---

### Protected Route Component

```typescript
// Reusable protected route wrapper
interface ProtectedRouteProps {
  children: React.ReactNode;
  allowedRoles?: UserRole[];
  redirectTo?: string;
}

function ProtectedRoute({ children, allowedRoles, redirectTo = '/login' }: ProtectedRouteProps) {
  const { user, isLoading } = useAuth();
  const location = useLocation();

  if (isLoading) {
    return <CircularProgress />;
  }

  if (!user) {
    return <Navigate to={redirectTo} state={{ from: location }} replace />;
  }

  if (allowedRoles && !allowedRoles.includes(user.role)) {
    return <Navigate to="/unauthorized" replace />;
  }

  return <>{children}</>;
}

// Usage in routes
{
  path: 'admin',
  element: (
    <ProtectedRoute allowedRoles={['ADMIN']}>
      <AdminDashboard />
    </ProtectedRoute>
  ),
}
```

---

## 🧪 Testing Pro Patterns

### Custom Render with Providers

```typescript
// test-utils.tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { BrowserRouter } from 'react-router-dom';
import { ThemeProvider } from '@mui/material';
import { render, RenderOptions } from '@testing-library/react';
import { theme } from './theme';

const AllTheProviders = ({ children }: { children: React.ReactNode }) => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });

  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <ThemeProvider theme={theme}>
          {children}
        </ThemeProvider>
      </BrowserRouter>
    </QueryClientProvider>
  );
};

const customRender = (ui: React.ReactElement, options?: RenderOptions) =>
  render(ui, { wrapper: AllTheProviders, ...options });

export * from '@testing-library/react';
export { customRender as render };
```

---

### Mock API with MSW

```typescript
// mocks/handlers.ts
import { rest } from 'msw';

export const handlers = [
  rest.get('/api/bookings', (req, res, ctx) => {
    return res(
      ctx.status(200),
      ctx.json([
        { id: '1', userId: 'user-1', /* ... */ },
      ])
    );
  }),

  rest.post('/api/bookings', async (req, res, ctx) => {
    const body = await req.json();
    return res(
      ctx.status(201),
      ctx.json({ id: 'new-id', ...body })
    );
  }),
];

// test setup
import { setupServer } from 'msw/node';
const server = setupServer(...handlers);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

---

## 🐳 Docker Pro Tips

### Multi-stage Build Optimization

```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

### Docker Compose Dev Override

Create `docker-compose.override.yml` for local dev:

```yaml
# docker-compose.override.yml (gitignored)
version: '3.8'
services:
  app:
    volumes:
      - ./src:/app/src  # Hot reload
    environment:
      - NODE_ENV=development
```

Now `docker-compose up` automatically uses the override!

---

## 🎯 Performance Pro Patterns

### Lazy Load Components

```typescript
// Lazy load heavy components
const AdminPanel = lazy(() => import('./pages/AdminPanel'));
const StationsBoard = lazy(() => import('./components/StationsBoard'));

// With loading fallback
<Suspense fallback={<CircularProgress />}>
  <AdminPanel />
</Suspense>
```

---

### Memoization Pattern

```typescript
// Expensive computation
const filteredBookings = useMemo(() => {
  return bookings.filter(b => b.status === selectedStatus);
}, [bookings, selectedStatus]);

// Expensive component
const BookingCard = memo(({ booking }: { booking: Booking }) => {
  // ...
});

// Callback stability
const handleSubmit = useCallback((data: FormData) => {
  submitBooking(data);
}, []); // Dependencies array is key
```

---

### Virtual Scrolling for Long Lists

```typescript
import { FixedSizeList } from 'react-window';

function BookingsList({ bookings }: { bookings: Booking[] }) {
  const Row = ({ index, style }: { index: number; style: React.CSSProperties }) => (
    <div style={style}>
      <BookingCard booking={bookings[index]} />
    </div>
  );

  return (
    <FixedSizeList
      height={600}
      itemCount={bookings.length}
      itemSize={100}
      width="100%"
    >
      {Row}
    </FixedSizeList>
  );
}
```

---

## 🔍 Debugging Pro Tips

### React Query Devtools

```typescript
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';

<QueryClientProvider client={queryClient}>
  <App />
  <ReactQueryDevtools initialIsOpen={false} />
</QueryClientProvider>
```

Press the flower icon in corner → inspect all queries!

---

### Redux DevTools for State

Even without Redux, you can log state changes:

```typescript
// In your context
const [state, dispatch] = useReducer(reducer, initialState);

// Log in reducer
function reducer(state, action) {
  console.log('Action:', action.type, action.payload);
  const newState = /* ... */;
  console.log('New State:', newState);
  return newState;
}
```

---

### Network Debugging

```typescript
// Log all API requests
apiClient.interceptors.request.use((config) => {
  console.log(`→ ${config.method?.toUpperCase()} ${config.url}`, config.data);
  return config;
});

apiClient.interceptors.response.use(
  (response) => {
    console.log(`← ${response.status} ${response.config.url}`, response.data);
    return response;
  },
  (error) => {
    console.error(`✖ ${error.config?.url}`, error.response?.data);
    return Promise.reject(error);
  }
);
```

---

## 📚 Learning Hacks

### Read Source Code

Best way to learn patterns:

1. Open `node_modules/@tanstack/react-query`
2. Read the TypeScript types
3. See how hooks are implemented
4. Copy patterns you like

---

### Use TypeScript IntelliSense

Hover over EVERYTHING:
- Function names → see signature
- Variables → see type
- Components → see props

Press `Ctrl+Space` to see autocomplete options.

---

### Keep a "TIL" (Today I Learned) Doc

```markdown
# TIL.md

## 2024-02-05
- Learned that `queryKey` must be stable (can't use objects directly)
- Discovered `useInfiniteQuery` for pagination
- Found out about React.lazy for code splitting

## 2024-02-06
- ...
```

Helps you remember and shows progress!

---

## 🚀 Productivity Hacks

### Terminal Aliases

```bash
# Add to ~/.zshrc or ~/.bashrc
alias dcup='docker-compose up'
alias dcdown='docker-compose down'
alias dcbuild='docker-compose up --build'
alias nr='npm run'
alias nrd='npm run dev'
```

---

### VS Code Multi-Cursor

- `Cmd/Ctrl + D` - Select next occurrence
- `Cmd/Ctrl + Shift + L` - Select all occurrences
- `Alt + Click` - Add cursor

Example: Rename variable in multiple places instantly!

---

### GitHub Copilot (if available)

Pro tips:
- Write comment describing what you want → Copilot suggests code
- Start typing pattern → Copilot completes it
- BUT: Always review and understand suggested code!

---

## 💡 Mindset Tips

### When Stuck
1. **Read the error message** (actually read it)
2. **Google the exact error** (include framework version)
3. **Check official docs** (not random blogs)
4. **Create minimal reproduction** (isolate the problem)
5. **Take a break** (seriously, works wonders)

### Code Quality Mindset
- **Make it work** → **Make it right** → **Make it fast**
- Don't optimize prematurely
- But do type properly from the start
- Refactor as you go (don't let tech debt pile up)

### Learning Mindset
- **Struggle is learning** - If it's easy, you're not growing
- **Break big problems** into tiny steps
- **Celebrate small wins** - Each feature completed matters
- **Compare to yesterday you**, not to senior devs

---

**Remember: These are tools, not rules. Use what works for you!**
