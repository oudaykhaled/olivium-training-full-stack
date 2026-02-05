# Step 3: Module Federation Setup (Micro-Frontends)

**Duration**: 1 day  
**Complexity**: ⭐⭐⭐ Advanced

---

## 🎯 Objectives

By the end of this step, you will have:
- ✅ Webpack Module Federation configured for host and remotes
- ✅ 3 remote applications (bookings, stations, users)
- ✅ Shared dependencies (React, MUI, Router, TanStack Query) as singletons
- ✅ Each remote can run independently
- ✅ Host loads remotes at runtime
- ✅ No duplicate React instances

---

## 📐 Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│          container-shell (HOST)                     │
│  ┌──────────────────────────────────────────────┐  │
│  │  Navigation, Layout, Auth, Theme Provider    │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────┐ │
│  │ bookings-app │  │ stations-app │  │users-app │ │
│  │  (REMOTE)    │  │  (REMOTE)    │  │(REMOTE)  │ │
│  │  Port 3001   │  │  Port 3002   │  │Port 3003 │ │
│  └──────────────┘  └──────────────┘  └──────────┘ │
│          ▲               ▲               ▲          │
│          └───────────────┴───────────────┘          │
│                  Runtime Loading                    │
└─────────────────────────────────────────────────────┘

Shared Singletons:
- React + ReactDOM
- @mui/material
- react-router-dom
- @tanstack/react-query
```

---

## 📝 Detailed Implementation

### 3.1 Install Module Federation Plugin

```bash
cd frontend/container-shell
npm install --save-dev @module-federation/enhanced
```

---

### 3.2 Update Container Shell Webpack Config

Edit **`frontend/container-shell/webpack.config.js`**:

```javascript
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const { ModuleFederationPlugin } = require('webpack').container;

module.exports = (env, argv) => {
  const isDevelopment = argv.mode === 'development';
  const port = process.env.PORT || 3000;

  return {
    entry: './src/index.tsx',
    mode: argv.mode || 'development',
    output: {
      path: path.resolve(__dirname, 'dist'),
      filename: '[name].[contenthash].js',
      clean: true,
      publicPath: 'auto',
    },
    resolve: {
      extensions: ['.ts', '.tsx', '.js', '.jsx'],
    },
    module: {
      rules: [
        {
          test: /\.tsx?$/,
          use: 'ts-loader',
          exclude: /node_modules/,
        },
      ],
    },
    plugins: [
      new ModuleFederationPlugin({
        name: 'container',
        remotes: {
          bookings: `bookings@http://localhost:3001/remoteEntry.js`,
          stations: `stations@http://localhost:3002/remoteEntry.js`,
          users: `users@http://localhost:3003/remoteEntry.js`,
        },
        shared: {
          react: {
            singleton: true,
            requiredVersion: '^18.2.0',
            eager: true,
          },
          'react-dom': {
            singleton: true,
            requiredVersion: '^18.2.0',
            eager: true,
          },
          '@mui/material': {
            singleton: true,
            requiredVersion: '^5.15.0',
          },
          '@emotion/react': {
            singleton: true,
            requiredVersion: '^11.11.0',
          },
          '@emotion/styled': {
            singleton: true,
            requiredVersion: '^11.11.0',
          },
          'react-router-dom': {
            singleton: true,
            requiredVersion: '^6.21.0',
          },
          '@tanstack/react-query': {
            singleton: true,
            requiredVersion: '^5.17.0',
          },
        },
      }),
      new HtmlWebpackPlugin({
        template: './src/index.html',
        title: 'ArcadeHub',
      }),
    ],
    devServer: {
      port: port,
      hot: true,
      historyApiFallback: true,
      headers: {
        'Access-Control-Allow-Origin': '*',
      },
    },
    devtool: isDevelopment ? 'eval-source-map' : 'source-map',
  };
};
```

**Key Points**:
- `remotes`: URLs where remote apps are running
- `shared`: Shared dependencies marked as `singleton`
- `eager: true` for host (React loaded immediately)
- `publicPath: 'auto'` for dynamic loading

---

### 3.3 Create Bookings Remote App

```bash
mkdir -p frontend/bookings-app/src
cd frontend/bookings-app
npm init -y
```

Edit **`frontend/bookings-app/package.json`**:

```json
{
  "name": "bookings-app",
  "version": "1.0.0",
  "scripts": {
    "dev": "webpack serve --mode development --port 3001",
    "build": "webpack --mode production"
  },
  "peerDependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "@mui/material": "^5.15.0",
    "react-router-dom": "^6.21.0",
    "@tanstack/react-query": "^5.17.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "html-webpack-plugin": "^5.5.0",
    "ts-loader": "^9.5.0",
    "typescript": "^5.2.0",
    "webpack": "^5.89.0",
    "webpack-cli": "^5.1.0",
    "webpack-dev-server": "^4.15.0"
  }
}
```

**Important**: Use `peerDependencies`, not `dependencies` for shared libraries!

---

### 3.4 Create Bookings Webpack Config

**`frontend/bookings-app/webpack.config.js`**:

```javascript
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const { ModuleFederationPlugin } = require('webpack').container;

module.exports = (env, argv) => {
  const isDevelopment = argv.mode === 'development';

  return {
    entry: './src/index.tsx',
    mode: argv.mode || 'development',
    output: {
      path: path.resolve(__dirname, 'dist'),
      filename: '[name].[contenthash].js',
      clean: true,
      publicPath: 'auto',
    },
    resolve: {
      extensions: ['.ts', '.tsx', '.js', '.jsx'],
    },
    module: {
      rules: [
        {
          test: /\.tsx?$/,
          use: 'ts-loader',
          exclude: /node_modules/,
        },
      ],
    },
    plugins: [
      new ModuleFederationPlugin({
        name: 'bookings',
        filename: 'remoteEntry.js',
        exposes: {
          './BookingFlow': './src/BookingFlow',
          './MyBookings': './src/MyBookings',
        },
        shared: {
          react: {
            singleton: true,
            requiredVersion: '^18.2.0',
            eager: false,  // Important: false for remotes!
          },
          'react-dom': {
            singleton: true,
            requiredVersion: '^18.2.0',
            eager: false,
          },
          '@mui/material': {
            singleton: true,
          },
          '@emotion/react': {
            singleton: true,
          },
          '@emotion/styled': {
            singleton: true,
          },
          'react-router-dom': {
            singleton: true,
          },
          '@tanstack/react-query': {
            singleton: true,
          },
        },
      }),
      new HtmlWebpackPlugin({
        template: './src/index.html',
        title: 'Bookings App',
      }),
    ],
    devServer: {
      port: 3001,
      hot: true,
      historyApiFallback: true,
      headers: {
        'Access-Control-Allow-Origin': '*',
      },
    },
    devtool: isDevelopment ? 'eval-source-map' : 'source-map',
  };
};
```

**Key Differences from Host**:
- `exposes`: What this remote exports
- `eager: false`: Don't load React immediately
- Port 3001 (different from host)

---

### 3.5 Create Bookings Source Files

**`frontend/bookings-app/src/BookingFlow.tsx`**:

```typescript
import { Container, Typography, Box } from '@mui/material';

export default function BookingFlow() {
  return (
    <Container maxWidth="lg">
      <Box sx={{ py: 4 }}>
        <Typography variant="h3" gutterBottom>
          Booking Flow
        </Typography>
        <Typography variant="body1" color="text.secondary">
          This is the bookings remote app. Multi-step booking form will be implemented in Step 6.
        </Typography>
      </Box>
    </Container>
  );
}
```

**`frontend/bookings-app/src/MyBookings.tsx`**:

```typescript
import { Container, Typography } from '@mui/material';

export default function MyBookings() {
  return (
    <Container maxWidth="lg">
      <Typography variant="h3">My Bookings</Typography>
      <Typography>User's booking list will be implemented in Step 7.</Typography>
    </Container>
  );
}
```

**`frontend/bookings-app/src/bootstrap.tsx`**:

```typescript
import React from 'react';
import ReactDOM from 'react-dom/client';
import BookingFlow from './BookingFlow';

const root = document.getElementById('root');

if (root) {
  ReactDOM.createRoot(root).render(
    <React.StrictMode>
      <BookingFlow />
    </React.StrictMode>
  );
}
```

**`frontend/bookings-app/src/index.tsx`**:

```typescript
// Bootstrap file for dynamic import
import('./bootstrap');
export {};
```

**Why bootstrap?** Module Federation requires async entry point to load shared dependencies first.

**`frontend/bookings-app/src/index.html`**:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Bookings App</title>
</head>
<body>
  <div id="root"></div>
</body>
</html>
```

**`frontend/bookings-app/tsconfig.json`**:

```json
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"]
}
```

---

### 3.6 Install Bookings Dependencies

```bash
cd frontend/bookings-app
npm install

# Install peer dependencies for development
npm install --save-dev react react-dom @mui/material @emotion/react @emotion/styled react-router-dom @tanstack/react-query
```

---

### 3.7 Create Stations and Users Remotes

Repeat the same process for `stations-app` (port 3002) and `users-app` (port 3003):

**Stations App** exposes:
- `./StationsBoard` - Live station status board

**Users App** exposes:
- `./UsersTable` - Admin user management table

Copy the bookings-app structure and adjust:
- Port numbers
- Exposed components
- Package name

---

### 3.8 Load Remotes in Container Shell

Update **`frontend/container-shell/src/routes.tsx`**:

```typescript
import { lazy, Suspense } from 'react';
import { createBrowserRouter, Navigate } from 'react-router-dom';
import { CircularProgress, Box } from '@mui/material';
import { AppLayout } from './components/Layout/AppLayout';
import { HomePage } from './pages/HomePage';
// ... other local imports

// Lazy load remote components
const BookingFlow = lazy(() => import('bookings/BookingFlow'));
const MyBookings = lazy(() => import('bookings/MyBookings'));
const StationsBoard = lazy(() => import('stations/StationsBoard'));
const UsersTable = lazy(() => import('users/UsersTable'));

// Loading fallback
const LoadingFallback = () => (
  <Box
    sx={{
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      minHeight: '400px',
    }}
  >
    <CircularProgress />
  </Box>
);

export const router = createBrowserRouter([
  {
    path: '/',
    element: <AppLayout />,
    children: [
      {
        index: true,
        element: <HomePage />,
      },
      {
        path: 'book',
        element: (
          <Suspense fallback={<LoadingFallback />}>
            <BookingFlow />
          </Suspense>
        ),
      },
      {
        path: 'my-bookings',
        element: (
          <Suspense fallback={<LoadingFallback />}>
            <MyBookings />
          </Suspense>
        ),
      },
      {
        path: 'admin/users',
        element: (
          <Suspense fallback={<LoadingFallback />}>
            <UsersTable />
          </Suspense>
        ),
      },
      // ... other routes
    ],
  },
]);
```

---

### 3.9 Add TypeScript Declarations

Create **`frontend/container-shell/src/types/module-federation.d.ts`**:

```typescript
declare module 'bookings/BookingFlow' {
  const BookingFlow: React.ComponentType;
  export default BookingFlow;
}

declare module 'bookings/MyBookings' {
  const MyBookings: React.ComponentType;
  export default MyBookings;
}

declare module 'stations/StationsBoard' {
  const StationsBoard: React.ComponentType;
  export default StationsBoard;
}

declare module 'users/UsersTable' {
  const UsersTable: React.ComponentType;
  export default UsersTable;
}
```

---

## ✅ Definition of Done

### Functionality
- [ ] Container shell runs on port 3000
- [ ] Bookings app runs independently on port 3001
- [ ] Stations app runs independently on port 3002
- [ ] Users app runs independently on port 3003
- [ ] Shell loads remote components without errors
- [ ] Navigation to /book shows BookingFlow component
- [ ] No "duplicate React" errors in console

### Verification Tests

```bash
# Terminal 1: Start container
cd frontend/container-shell
npm run dev

# Terminal 2: Start bookings remote
cd frontend/bookings-app
npm run dev

# Terminal 3: Start stations remote
cd frontend/stations-app
npm run dev

# Terminal 4: Start users remote
cd frontend/users-app
npm run dev

# Browser: http://localhost:3000
# Navigate to /book → should load BookingFlow from remote

# Check console:
# ✅ No errors about duplicate React
# ✅ No errors about module loading
# ✅ See "Download the React DevTools..." only once
```

### Network Tab Check

1. Open http://localhost:3000
2. Open DevTools → Network tab
3. Navigate to /book
4. Look for: `remoteEntry.js` loaded from localhost:3001
5. Should see lazy-loaded chunks

---

## 🧪 Testing Checklist

### Test 1: Remote Independence
```bash
# Each remote should run standalone
cd frontend/bookings-app
npm run dev

# Visit http://localhost:3001
# Should see BookingFlow component
```

### Test 2: Hot Reload
```bash
# With all apps running:
# Edit bookings-app/src/BookingFlow.tsx
# Change text
# Both localhost:3001 and localhost:3000/book should update
```

### Test 3: Shared Dependencies
```bash
# In browser console:
window.React

# Should output React object
# If undefined, React not loaded correctly
```

### Test 4: No Duplicate React
```bash
# In browser console, run:
const roots = document.querySelectorAll('[data-reactroot]');
console.log('React roots:', roots.length);

# Should be 1, not multiple
```

---

## 💡 Tips & Best Practices

### Module Federation Tips

1. **Always use bootstrap pattern**
```typescript
// index.tsx
import('./bootstrap');

// bootstrap.tsx
// Your actual code here
```

2. **Eager vs Non-Eager**
- Host: `eager: true` (loads React immediately)
- Remotes: `eager: false` (waits for host's React)

3. **Singleton is Critical**
```javascript
react: {
  singleton: true,  // Only one instance across all apps
  requiredVersion: '^18.2.0',
}
```

4. **publicPath: 'auto'**
```javascript
output: {
  publicPath: 'auto',  // Dynamically determines path
}
```

### Performance Tips

1. **Lazy load remotes** - Don't import at top level
2. **Show loading states** - Use Suspense
3. **Prefetch remotes** - On hover or route change

### Development Tips

1. **Run all apps** - Container + all remotes for development
2. **Use same React version** - Across all apps
3. **Check console early** - Catch errors immediately

---

## ⚠️ Common Pitfalls

### Problem: "Uncaught Error: Shared module is not available for eager consumption"

**Cause**: Remote has `eager: true` for React

**Solution**: Set `eager: false` in remote's shared config

---

### Problem: "Cannot read properties of undefined (reading 'call')"

**Cause**: Remote entry point not accessible

**Solution**:
1. Ensure remote is running: `curl http://localhost:3001/remoteEntry.js`
2. Check CORS headers in devServer config
3. Verify URL in host's `remotes` config

---

### Problem: Invalid hook call (multiple React instances)

**Cause**: React loaded more than once

**Solution**:
1. Verify `singleton: true` in ALL apps
2. Check `npm list react` in each app
3. Use peer dependencies in remotes
4. Clear node_modules and reinstall

---

### Problem: Types not found for remote modules

**Cause**: TypeScript doesn't know about remote modules

**Solution**: Create `module-federation.d.ts` with declarations

---

### Problem: Remote works standalone but not in host

**Cause**: Shared dependency version mismatch

**Solution**: Ensure all apps use same versions in package.json

---

## 📚 Additional Resources

- [Module Federation Docs](https://webpack.js.org/concepts/module-federation/)
- [Module Federation Examples](https://github.com/module-federation/module-federation-examples)
- [MF with React Tutorial](https://www.youtube.com/watch?v=lKKsjpH09dU)

---

## 🎯 What's Next?

Once Module Federation works, move on to [Step 4: API Client + TanStack Query](./step-04-api-client.md) where you'll connect to a backend API.

---

**Estimated Time**: 6-8 hours  
**Difficulty**: High - But very rewarding once working!

**Remember**: Module Federation is tricky the first time. Don't get discouraged! Once you get it working, it's magical. 🎩✨
