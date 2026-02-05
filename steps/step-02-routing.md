# Step 2: Routing + Layout in the Shell

**Duration**: 2 days  
**Complexity**: ⭐⭐ Intermediate

---

## 🎯 Objectives

By the end of this step, you will have:
- ✅ React Router v6 configured with nested routes
- ✅ Responsive MUI layout with app bar and navigation drawer
- ✅ Route structure for public and protected areas
- ✅ Deep linking working correctly
- ✅ Browser back/forward buttons working
- ✅ URL refresh doesn't break navigation

---

## 📐 Target Route Structure

```
/                       → Landing page (public)
/branches               → Browse branches (public)
/login                  → Login page
/register               → Registration page

/book                   → Booking flow (protected)
/my-bookings            → User's bookings (protected)

/staff                  → Staff dashboard (protected, STAFF role)
/staff/bookings         → Manage bookings

/admin                  → Admin home (protected, ADMIN role)
/admin/users            → User management
/admin/branches         → Branch management
/admin/stations         → Station management
/admin/reports          → Analytics & reports
```

---

## 📝 Detailed Implementation

### 2.1 Install React Router

```bash
cd frontend/container-shell
npm install react-router-dom@6
npm install --save-dev @types/react-router-dom
```

---

### 2.2 Create Layout Components

Create **`frontend/container-shell/src/components/Layout/AppLayout.tsx`**:

```typescript
import { useState } from 'react';
import { Outlet } from 'react-router-dom';
import {
  Box,
  AppBar,
  Toolbar,
  IconButton,
  Typography,
  Drawer,
  useMediaQuery,
  useTheme,
} from '@mui/material';
import MenuIcon from '@mui/icons-material/Menu';
import { Navigation } from './Navigation';

const DRAWER_WIDTH = 260;

export function AppLayout() {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  const [mobileOpen, setMobileOpen] = useState(false);

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  return (
    <Box sx={{ display: 'flex', minHeight: '100vh' }}>
      {/* App Bar */}
      <AppBar
        position="fixed"
        sx={{
          zIndex: theme.zIndex.drawer + 1,
        }}
      >
        <Toolbar>
          <IconButton
            color="inherit"
            edge="start"
            onClick={handleDrawerToggle}
            sx={{ mr: 2, display: { md: 'none' } }}
          >
            <MenuIcon />
          </IconButton>
          <Typography variant="h6" noWrap component="div" sx={{ flexGrow: 1 }}>
            🎮 ArcadeHub
          </Typography>
          {/* We'll add user menu here in Step 5 (Auth) */}
        </Toolbar>
      </AppBar>

      {/* Navigation Drawer */}
      <Box
        component="nav"
        sx={{ width: { md: DRAWER_WIDTH }, flexShrink: { md: 0 } }}
      >
        {/* Mobile drawer */}
        <Drawer
          variant="temporary"
          open={mobileOpen}
          onClose={handleDrawerToggle}
          ModalProps={{ keepMounted: true }}
          sx={{
            display: { xs: 'block', md: 'none' },
            '& .MuiDrawer-paper': {
              boxSizing: 'border-box',
              width: DRAWER_WIDTH,
            },
          }}
        >
          <Toolbar /> {/* Spacer for app bar */}
          <Navigation onNavigate={() => setMobileOpen(false)} />
        </Drawer>

        {/* Desktop drawer */}
        <Drawer
          variant="permanent"
          sx={{
            display: { xs: 'none', md: 'block' },
            '& .MuiDrawer-paper': {
              boxSizing: 'border-box',
              width: DRAWER_WIDTH,
            },
          }}
          open
        >
          <Toolbar /> {/* Spacer for app bar */}
          <Navigation />
        </Drawer>
      </Box>

      {/* Main content */}
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          p: 3,
          width: { md: `calc(100% - ${DRAWER_WIDTH}px)` },
        }}
      >
        <Toolbar /> {/* Spacer for app bar */}
        <Outlet />
      </Box>
    </Box>
  );
}
```

---

Create **`frontend/container-shell/src/components/Layout/Navigation.tsx`**:

```typescript
import { useNavigate, useLocation } from 'react-router-dom';
import {
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Divider,
} from '@mui/material';
import HomeIcon from '@mui/icons-material/Home';
import EventIcon from '@mui/icons-material/Event';
import StoreIcon from '@mui/icons-material/Store';
import AdminPanelSettingsIcon from '@mui/icons-material/AdminPanelSettings';
import PeopleIcon from '@mui/icons-material/People';
import DashboardIcon from '@mui/icons-material/Dashboard';
import AssessmentIcon from '@mui/icons-material/Assessment';

interface NavigationProps {
  onNavigate?: () => void;
}

interface NavItem {
  label: string;
  path: string;
  icon: React.ReactElement;
  section?: 'public' | 'customer' | 'staff' | 'admin';
}

const navItems: NavItem[] = [
  // Public routes
  { label: 'Home', path: '/', icon: <HomeIcon />, section: 'public' },
  { label: 'Branches', path: '/branches', icon: <StoreIcon />, section: 'public' },
  
  // Customer routes (will be protected in Step 5)
  { label: 'Book Station', path: '/book', icon: <EventIcon />, section: 'customer' },
  { label: 'My Bookings', path: '/my-bookings', icon: <EventIcon />, section: 'customer' },
  
  // Staff routes (will be protected in Step 5)
  { label: 'Staff Dashboard', path: '/staff', icon: <DashboardIcon />, section: 'staff' },
  
  // Admin routes (will be protected in Step 5)
  { label: 'Admin Dashboard', path: '/admin', icon: <AdminPanelSettingsIcon />, section: 'admin' },
  { label: 'Users', path: '/admin/users', icon: <PeopleIcon />, section: 'admin' },
  { label: 'Reports', path: '/admin/reports', icon: <AssessmentIcon />, section: 'admin' },
];

export function Navigation({ onNavigate }: NavigationProps) {
  const navigate = useNavigate();
  const location = useLocation();

  const handleNavigation = (path: string) => {
    navigate(path);
    onNavigate?.();
  };

  const isActive = (path: string) => {
    if (path === '/') {
      return location.pathname === '/';
    }
    return location.pathname.startsWith(path);
  };

  const renderSection = (section: string, items: NavItem[]) => {
    const sectionItems = items.filter((item) => item.section === section);
    if (sectionItems.length === 0) return null;

    return (
      <>
        <List>
          {sectionItems.map((item) => (
            <ListItem key={item.path} disablePadding>
              <ListItemButton
                onClick={() => handleNavigation(item.path)}
                selected={isActive(item.path)}
              >
                <ListItemIcon>{item.icon}</ListItemIcon>
                <ListItemText primary={item.label} />
              </ListItemButton>
            </ListItem>
          ))}
        </List>
        <Divider />
      </>
    );
  };

  return (
    <>
      {renderSection('public', navItems)}
      {renderSection('customer', navItems)}
      {renderSection('staff', navItems)}
      {renderSection('admin', navItems)}
    </>
  );
}
```

---

### 2.3 Create Page Components (Placeholders)

Create **`frontend/container-shell/src/pages/HomePage.tsx`**:

```typescript
import { Container, Typography, Box, Button, Grid, Card, CardContent } from '@mui/material';
import { useNavigate } from 'react-router-dom';
import SportsEsportsIcon from '@mui/icons-material/SportsEsports';
import EventIcon from '@mui/icons-material/Event';
import StoreIcon from '@mui/icons-material/Store';

export function HomePage() {
  const navigate = useNavigate();

  return (
    <Container maxWidth="lg">
      <Box sx={{ textAlign: 'center', my: 8 }}>
        <Typography variant="h2" gutterBottom>
          Welcome to ArcadeHub
        </Typography>
        <Typography variant="h5" color="text.secondary" paragraph>
          The ultimate gaming lounge booking experience
        </Typography>
        <Box sx={{ mt: 4 }}>
          <Button
            variant="contained"
            size="large"
            startIcon={<EventIcon />}
            onClick={() => navigate('/book')}
            sx={{ mx: 1 }}
          >
            Book Now
          </Button>
          <Button
            variant="outlined"
            size="large"
            startIcon={<StoreIcon />}
            onClick={() => navigate('/branches')}
            sx={{ mx: 1 }}
          >
            View Branches
          </Button>
        </Box>
      </Box>

      <Grid container spacing={4} sx={{ mt: 4 }}>
        <Grid item xs={12} md={4}>
          <Card>
            <CardContent sx={{ textAlign: 'center' }}>
              <SportsEsportsIcon sx={{ fontSize: 60, color: 'primary.main' }} />
              <Typography variant="h6" gutterBottom>
                Premium Gaming PCs
              </Typography>
              <Typography variant="body2" color="text.secondary">
                RTX 4080, 240Hz monitors, mechanical keyboards
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} md={4}>
          <Card>
            <CardContent sx={{ textAlign: 'center' }}>
              <SportsEsportsIcon sx={{ fontSize: 60, color: 'primary.main' }} />
              <Typography variant="h6" gutterBottom>
                Latest Consoles
              </Typography>
              <Typography variant="body2" color="text.secondary">
                PS5, Xbox Series X, Nintendo Switch
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} md={4}>
          <Card>
            <CardContent sx={{ textAlign: 'center' }}>
              <SportsEsportsIcon sx={{ fontSize: 60, color: 'primary.main' }} />
              <Typography variant="h6" gutterBottom>
                Private Rooms
              </Typography>
              <Typography variant="body2" color="text.secondary">
                VR setups, party rooms, tournament areas
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Container>
  );
}
```

Create **`frontend/container-shell/src/pages/BranchesPage.tsx`**:

```typescript
import { Container, Typography } from '@mui/material';

export function BranchesPage() {
  return (
    <Container maxWidth="lg">
      <Typography variant="h3" gutterBottom>
        Our Branches
      </Typography>
      <Typography variant="body1" color="text.secondary">
        Branch list will be implemented in Step 4 with API integration
      </Typography>
    </Container>
  );
}
```

Create similar placeholder pages for all routes:
- `LoginPage.tsx`
- `RegisterPage.tsx`
- `BookingFlowPage.tsx`
- `MyBookingsPage.tsx`
- `StaffDashboardPage.tsx`
- `AdminDashboardPage.tsx`
- `AdminUsersPage.tsx`
- `AdminReportsPage.tsx`
- `NotFoundPage.tsx`

**Example placeholder**:

```typescript
import { Container, Typography } from '@mui/material';

export function LoginPage() {
  return (
    <Container maxWidth="sm">
      <Typography variant="h3" gutterBottom>
        Login
      </Typography>
      <Typography variant="body1" color="text.secondary">
        Authentication will be implemented in Step 5
      </Typography>
    </Container>
  );
}
```

---

### 2.4 Configure Routes

Create **`frontend/container-shell/src/routes.tsx`**:

```typescript
import { createBrowserRouter, Navigate } from 'react-router-dom';
import { AppLayout } from './components/Layout/AppLayout';
import { HomePage } from './pages/HomePage';
import { BranchesPage } from './pages/BranchesPage';
import { LoginPage } from './pages/LoginPage';
import { RegisterPage } from './pages/RegisterPage';
import { BookingFlowPage } from './pages/BookingFlowPage';
import { MyBookingsPage } from './pages/MyBookingsPage';
import { StaffDashboardPage } from './pages/StaffDashboardPage';
import { AdminDashboardPage } from './pages/AdminDashboardPage';
import { AdminUsersPage } from './pages/AdminUsersPage';
import { AdminReportsPage } from './pages/AdminReportsPage';
import { NotFoundPage } from './pages/NotFoundPage';

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
        path: 'branches',
        element: <BranchesPage />,
      },
      {
        path: 'login',
        element: <LoginPage />,
      },
      {
        path: 'register',
        element: <RegisterPage />,
      },
      {
        path: 'book',
        element: <BookingFlowPage />,
      },
      {
        path: 'my-bookings',
        element: <MyBookingsPage />,
      },
      {
        path: 'staff',
        children: [
          {
            index: true,
            element: <StaffDashboardPage />,
          },
          {
            path: 'bookings',
            element: <StaffDashboardPage />, // Reuse for now
          },
        ],
      },
      {
        path: 'admin',
        children: [
          {
            index: true,
            element: <AdminDashboardPage />,
          },
          {
            path: 'users',
            element: <AdminUsersPage />,
          },
          {
            path: 'reports',
            element: <AdminReportsPage />,
          },
        ],
      },
      {
        path: '404',
        element: <NotFoundPage />,
      },
      {
        path: '*',
        element: <Navigate to="/404" replace />,
      },
    ],
  },
]);
```

---

### 2.5 Update Main App

Update **`frontend/container-shell/src/App.tsx`**:

```typescript
import { RouterProvider } from 'react-router-dom';
import { router } from './routes';

function App() {
  return <RouterProvider router={router} />;
}

export default App;
```

---

### 2.6 Update Webpack for History Fallback

Ensure your `webpack.config.js` has:

```javascript
devServer: {
  port: 3000,
  hot: true,
  historyApiFallback: true, // ← This is crucial for routing
},
```

---

## ✅ Definition of Done

### Functionality
- [ ] All routes load without errors
- [ ] Navigation drawer works on desktop
- [ ] Mobile hamburger menu works
- [ ] Active route is highlighted in navigation
- [ ] Clicking navigation items navigates correctly
- [ ] Browser back/forward buttons work
- [ ] Refreshing page doesn't show 404
- [ ] Deep linking works (e.g., directly visiting /admin/users)
- [ ] 404 page shows for invalid routes

### UI/UX
- [ ] Responsive layout works on mobile, tablet, desktop
- [ ] Navigation drawer closes on mobile after selecting item
- [ ] AppBar is fixed at top
- [ ] Content area has proper spacing
- [ ] No layout shift when navigating

### Code Quality
- [ ] No TypeScript errors
- [ ] No ESLint warnings
- [ ] All components properly typed
- [ ] Consistent file structure

---

## 🧪 Testing Checklist

```bash
# Start dev server
npm run dev

# Test navigation
1. Click "Home" → should show HomePage
2. Click "Branches" → URL changes to /branches
3. Click browser back → returns to home
4. Click "Book Station" → navigates to /book
5. Manually type /admin/users in URL → page loads
6. Refresh page → stays on /admin/users
7. Type invalid URL /invalid → redirects to /404

# Test mobile
1. Resize browser to mobile width (<960px)
2. Hamburger menu icon appears
3. Click hamburger → drawer opens
4. Click navigation item → drawer closes
5. Drawer closes when clicking outside

# Test deep linking
1. Close browser
2. Open http://localhost:3000/admin/reports directly
3. Page loads correctly
```

---

## 💡 Tips & Best Practices

### Routing Tips
1. **Use `createBrowserRouter`** - Better than `<BrowserRouter>` (data loaders, actions)
2. **Nested routes** - Use `<Outlet />` for nested layouts
3. **404 handling** - Catch all with `path: '*'`
4. **Programmatic navigation** - Use `useNavigate()` hook, not `<Link>` for buttons
5. **Active links** - Use `useLocation()` to determine active route

### Layout Tips
1. **Responsive drawer** - Different behavior for mobile vs desktop
2. **Fixed AppBar** - Use `position="fixed"` and add `<Toolbar />` spacer
3. **Drawer width** - Store as constant for reuse
4. **Mobile-first** - Design for mobile, enhance for desktop

### Performance Tips
1. **Lazy load pages** - We'll do this in Step 9, but consider it from now
2. **Memo navigation** - If expensive computations, use `useMemo`
3. **Avoid inline functions** - In list renders (can cause re-renders)

---

## ⚠️ Common Pitfalls

### Problem: 404 on page refresh in production
**Solution**: Configure server (Nginx/Traefik) to redirect all routes to index.html
```nginx
location / {
  try_files $uri $uri/ /index.html;
}
```

### Problem: Navigation drawer doesn't close on mobile
**Solution**: Pass `onNavigate` callback and call it after navigation

### Problem: Active link not highlighted
**Solution**: Use `useLocation()` and compare `pathname`, not `===` for nested routes

### Problem: Content hidden behind AppBar
**Solution**: Add `<Toolbar />` spacer after opening `<Box component="main">`

### Problem: TypeScript error "Cannot find module react-router-dom"
**Solution**: 
```bash
npm install --save-dev @types/react-router-dom
```

---

## 📚 Additional Resources

- [React Router v6 Documentation](https://reactrouter.com/en/main)
- [MUI Drawer Component](https://mui.com/material-ui/react-drawer/)
- [Responsive Design with MUI](https://mui.com/material-ui/customization/breakpoints/)

---

## 🎯 What's Next?

Once this step is complete, move on to [Step 3: Module Federation](./step-03-module-federation.md) where you'll set up micro-frontends.

---

**Estimated Time**: 12-16 hours  
**Difficulty**: Medium - React Router is well-documented
