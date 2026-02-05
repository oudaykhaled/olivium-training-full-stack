# Common Pitfalls & Solutions

## Overview
This document lists common mistakes, errors, and gotchas you'll encounter while building ArcadeHub, along with proven solutions.

---

## 🔧 Module Federation Issues

### Problem: "Shared module is not available for eager consumption"
**Symptoms**: Runtime error, app doesn't load, blank screen

**Cause**: React loaded twice (once in host, once in remote)

**Solution**:
```javascript
// In webpack.config.js ModuleFederationPlugin
new ModuleFederationPlugin({
  shared: {
    react: {
      singleton: true,     // ← Must be true
      requiredVersion: false,
      eager: false,        // ← Should be false for remotes
    },
    'react-dom': {
      singleton: true,
      requiredVersion: false,
      eager: false,
    },
  },
}),
```

---

### Problem: "Cannot read properties of undefined (reading 'call')"
**Symptoms**: Remote fails to load

**Cause**: Remote entry point not accessible or incorrect path

**Solution**:
```javascript
// Ensure remotes are accessible
remotes: {
  bookings: 'bookings@http://localhost:3001/remoteEntry.js',
},

// Check CORS if loading from different origin
// In dev server:
headers: {
  'Access-Control-Allow-Origin': '*',
},
```

**Debug**: Open `http://localhost:3001/remoteEntry.js` in browser - should load JS file

---

### Problem: Duplicate React instances (hooks error)
**Symptoms**: "Invalid hook call" or "Rendered more hooks than expected"

**Cause**: Multiple React instances loaded

**Solution**:
1. Check `singleton: true` in shared config
2. Use same React version in all apps
3. Don't install React in remote apps (use peer dependencies)

```json
// In remote package.json
"peerDependencies": {
  "react": "^18.2.0",
  "react-dom": "^18.2.0"
},
"devDependencies": {
  "react": "^18.2.0",  // Only for development
  "react-dom": "^18.2.0"
}
```

---

## ⚛️ React & TypeScript Issues

### Problem: TypeScript error "Property does not exist on type"
**Symptoms**: `Property 'name' does not exist on type 'never'`

**Cause**: Type narrowing issue or incorrect type definition

**Solution**:
```typescript
// Bad
const user = null;
user.name; // Error

// Good
const user: User | null = null;
if (user) {
  user.name; // OK
}

// Or use optional chaining
user?.name;
```

---

### Problem: "React Hook useEffect has a missing dependency"
**Symptoms**: ESLint warning

**Cause**: useEffect doesn't list all dependencies

**Solution**:
```typescript
// Bad
useEffect(() => {
  fetchData(userId);
}, []); // ← Missing userId

// Good
useEffect(() => {
  fetchData(userId);
}, [userId]); // ← Include all dependencies

// Or if you really want to run once
useEffect(() => {
  const id = userId; // Capture at mount
  fetchData(id);
}, []); // eslint-disable-line react-hooks/exhaustive-deps
```

---

### Problem: Infinite loop with useEffect
**Symptoms**: Browser freezes, thousands of requests

**Cause**: Dependencies changing on every render

**Solution**:
```typescript
// Bad
useEffect(() => {
  setData({ name: 'test' }); // New object every time
}, [data]); // ← data changes → effect runs → data changes → ...

// Good
useEffect(() => {
  setData({ name: 'test' });
}, []); // Run once

// Or use specific dependency
useEffect(() => {
  setData({ name: 'test' });
}, [data.id]); // Only when ID changes
```

---

## 🔐 Authentication Issues

### Problem: Token not included in requests
**Symptoms**: API returns 401 Unauthorized

**Cause**: Interceptor not configured or token not in storage

**Solution**:
```typescript
// Add request interceptor
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});
```

---

### Problem: User logged out on page refresh
**Symptoms**: Auth state lost on refresh

**Cause**: Auth state only in memory

**Solution**:
```typescript
// Store token in localStorage
localStorage.setItem('token', token);

// Restore on app mount
useEffect(() => {
  const token = localStorage.getItem('token');
  if (token) {
    // Verify token and restore user
    verifyToken(token);
  }
}, []);
```

---

### Problem: Firebase Auth "API key not valid"
**Symptoms**: Firebase initialization error

**Cause**: Incorrect API key or missing config

**Solution**:
```typescript
// Check .env file
VITE_FIREBASE_API_KEY=your-actual-key-here

// Load config
const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  // ... other config
};

// Ensure not undefined
if (!firebaseConfig.apiKey) {
  throw new Error('Firebase API key not configured');
}
```

---

## 📡 API & TanStack Query Issues

### Problem: Data not refetching after mutation
**Symptoms**: UI shows stale data

**Cause**: Cache not invalidated

**Solution**:
```typescript
const mutation = useMutation({
  mutationFn: createBooking,
  onSuccess: () => {
    // Invalidate and refetch
    queryClient.invalidateQueries({ queryKey: ['bookings'] });
  },
});
```

---

### Problem: "Query data is undefined" but API works
**Symptoms**: `data` is undefined even after successful fetch

**Cause**: Checking data before loading completes

**Solution**:
```typescript
const { data, isLoading, isError } = useQuery({
  queryKey: ['bookings'],
  queryFn: fetchBookings,
});

// Bad
return <div>{data.map(...)}</div>; // data might be undefined

// Good
if (isLoading) return <CircularProgress />;
if (isError) return <Alert severity="error">Failed to load</Alert>;
if (!data) return null;

return <div>{data.map(...)}</div>;
```

---

### Problem: Optimistic update rolls back incorrectly
**Symptoms**: UI flickers or shows wrong data

**Cause**: Incorrect rollback logic

**Solution**:
```typescript
const mutation = useMutation({
  mutationFn: updateBooking,
  onMutate: async (newBooking) => {
    // Cancel outgoing refetches
    await queryClient.cancelQueries({ queryKey: ['bookings'] });

    // Snapshot previous value
    const previousBookings = queryClient.getQueryData(['bookings']);

    // Optimistically update
    queryClient.setQueryData(['bookings'], (old) => {
      return old.map((b) => (b.id === newBooking.id ? newBooking : b));
    });

    // Return context with snapshot
    return { previousBookings };
  },
  onError: (err, newBooking, context) => {
    // Rollback on error
    queryClient.setQueryData(['bookings'], context?.previousBookings);
  },
  onSettled: () => {
    // Always refetch after error or success
    queryClient.invalidateQueries({ queryKey: ['bookings'] });
  },
});
```

---

## 🎨 Material-UI Issues

### Problem: Theme not applied to components
**Symptoms**: Components use default blue colors

**Cause**: ThemeProvider not wrapping app

**Solution**:
```typescript
// Ensure ThemeProvider wraps entire app
<ThemeProvider theme={theme}>
  <CssBaseline />
  <App />
</ThemeProvider>
```

---

### Problem: MUI styles conflicting with custom CSS
**Symptoms**: Styles don't apply as expected

**Cause**: CSS specificity issues

**Solution**:
```typescript
// Use sx prop (highest specificity)
<Box sx={{ color: 'red' }}>Text</Box>

// Or styled components
import { styled } from '@mui/material/styles';
const StyledBox = styled(Box)(({ theme }) => ({
  color: theme.palette.primary.main,
}));
```

---

### Problem: Date picker not showing
**Symptoms**: MUI DatePicker renders but doesn't open

**Cause**: Missing @mui/x-date-pickers adapter

**Solution**:
```bash
npm install @mui/x-date-pickers dayjs
```

```typescript
import { LocalizationProvider } from '@mui/x-date-pickers';
import { AdapterDayjs } from '@mui/x-date-pickers/AdapterDayjs';

<LocalizationProvider dateAdapter={AdapterDayjs}>
  <DatePicker />
</LocalizationProvider>
```

---

## 🐳 Docker Issues

### Problem: "Cannot connect to Docker daemon"
**Symptoms**: Docker commands fail

**Cause**: Docker not running

**Solution**:
```bash
# macOS: Start Docker Desktop
# Linux: Start Docker service
sudo systemctl start docker

# Check if running
docker ps
```

---

### Problem: Container builds but app doesn't run
**Symptoms**: Container exits immediately or port not accessible

**Cause**: Missing ENTRYPOINT or CMD, or app crashes

**Solution**:
```dockerfile
# Add proper entrypoint
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Serve the built app
CMD ["npx", "serve", "-s", "dist", "-l", "3000"]

# Or for dev
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
```

**Debug**:
```bash
# Check logs
docker logs <container-id>

# Run interactively
docker run -it <image-name> /bin/sh
```

---

### Problem: "Port already in use" when running docker-compose
**Symptoms**: `Bind for 0.0.0.0:3000 failed: port is already allocated`

**Cause**: Port already used by another process

**Solution**:
```bash
# Find process using port
lsof -ti:3000  # macOS/Linux
netstat -ano | findstr :3000  # Windows

# Kill process
kill -9 <PID>  # macOS/Linux
taskkill /PID <PID> /F  # Windows

# Or change port in docker-compose.yml
ports:
  - "3001:3000"  # Map to different host port
```

---

### Problem: Changes not reflected in Docker container
**Symptoms**: Edit code but container still runs old code

**Cause**: Container not using volumes, or needs rebuild

**Solution**:
```yaml
# docker-compose.yml
services:
  app:
    build: .
    volumes:
      - ./src:/app/src  # Mount source for hot reload
      - /app/node_modules  # Don't override node_modules
```

**Or rebuild**:
```bash
docker-compose up --build
```

---

## 🧪 Testing Issues

### Problem: Playwright "page.goto: net::ERR_CONNECTION_REFUSED"
**Symptoms**: E2E tests can't connect to app

**Cause**: App not running or wrong URL

**Solution**:
```typescript
// playwright.config.ts
webServer: {
  command: 'npm run dev',
  port: 3000,
  timeout: 120000,  // Wait up to 2 minutes for server
  reuseExistingServer: !process.env.CI,
},
```

---

### Problem: Jest "Cannot use import statement outside a module"
**Symptoms**: Tests fail with syntax error

**Cause**: Jest doesn't understand ES modules

**Solution**:
```javascript
// jest.config.js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  transform: {
    '^.+\\.tsx?$': 'ts-jest',
  },
  moduleNameMapper: {
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
  },
  transformIgnorePatterns: [
    'node_modules/(?!(some-esm-package)/)',
  ],
};
```

---

### Problem: "act(...)" warning in React tests
**Symptoms**: Test passes but shows warning

**Cause**: State update not wrapped in act()

**Solution**:
```typescript
import { render, screen, waitFor } from '@testing-library/react';

// Bad
test('loads data', () => {
  render(<Component />);
  expect(screen.getByText('Loading')).toBeInTheDocument();
});

// Good
test('loads data', async () => {
  render(<Component />);
  await waitFor(() => {
    expect(screen.getByText('Data')).toBeInTheDocument();
  });
});
```

---

## 🌐 Webpack & Build Issues

### Problem: "Module not found: Can't resolve 'X'"
**Symptoms**: Build fails with missing module

**Cause**: Dependency not installed or wrong import path

**Solution**:
```bash
# Install missing dependency
npm install X

# Check import path
import { Component } from './Component';  // Relative path
import { Component } from '@/components/Component';  // If alias configured
```

---

### Problem: Build succeeds but page is blank
**Symptoms**: Production build shows blank page

**Cause**: Path issues or runtime errors

**Solution**:
1. Check browser console for errors
2. Check publicPath in webpack config:
```javascript
output: {
  publicPath: '/',  // For root deployment
  // or
  publicPath: '/app/',  // For subdirectory
},
```

---

### Problem: Hot reload not working
**Symptoms**: Changes don't reflect without manual refresh

**Cause**: Webpack dev server misconfigured

**Solution**:
```javascript
devServer: {
  hot: true,
  liveReload: true,
  watchFiles: ['src/**/*'],
},
```

---

## 🔍 Debugging Tips

### Use React DevTools
```bash
# Install browser extension
# Chrome: React Developer Tools
# Firefox: React Developer Tools

# Check component props, state, hooks
# Inspect component tree
# Profile performance
```

### Use Browser DevTools Network Tab
```
# Check API calls
# Verify headers (Authorization)
# Check response status and body
# Check CORS errors
```

### Use console.log Strategically
```typescript
// Not just values
console.log('User:', user);

// Log with context
console.log('[BookingForm] Submitting:', formData);

// Use console.table for arrays
console.table(bookings);

// Use console.trace to see call stack
console.trace('How did we get here?');
```

---

## 📚 When You're Really Stuck

1. **Read the error message carefully** - It usually tells you what's wrong
2. **Check the documentation** - Official docs are your friend
3. **Search the error** - Google/StackOverflow likely has the answer
4. **Isolate the problem** - Create minimal reproduction
5. **Take a break** - Fresh eyes see solutions
6. **Ask for help** - But show what you've tried first

---

**Remember**: Every developer encounters these issues. The key is learning to debug efficiently!
