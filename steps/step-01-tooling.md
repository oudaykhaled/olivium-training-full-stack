# Step 1: Tooling + Baseline App (TypeScript-First)

**Duration**: 2 days  
**Complexity**: ⭐⭐ Intermediate

---

## 🎯 Objectives

By the end of this step, you will have:
- ✅ A properly configured TypeScript monorepo with npm workspaces
- ✅ ESLint + Prettier configured with strict rules
- ✅ TypeScript in strict mode across all packages
- ✅ Material-UI installed with a custom theme
- ✅ A running shell app displaying "Hello ArcadeHub"
- ✅ npm scripts for dev, build, lint, and type-check

---

## 📁 Target Folder Structure

```
arcadehub/
├── package.json                    # Root workspace config
├── tsconfig.json                   # Base TypeScript config
├── .eslintrc.js                    # ESLint configuration
├── .prettierrc                     # Prettier configuration
├── .gitignore
├── README.md
├── frontend/
│   ├── container-shell/
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   ├── webpack.config.js
│   │   ├── src/
│   │   │   ├── index.tsx           # Entry point
│   │   │   ├── App.tsx             # Root component
│   │   │   ├── theme.ts            # MUI theme
│   │   │   └── index.html          # HTML template
│   │   └── public/
│   ├── shared-ui-lib/
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── src/
│   │       ├── index.ts
│   │       └── components/
│   └── bookings-app/               # Empty for now
│       ├── package.json
│       └── tsconfig.json
└── mock-api/                       # We'll create this in Step 4
```

---

## 📝 Detailed Implementation

### 1.1 Initialize Root Workspace

Create the root `package.json`:

```bash
mkdir arcadehub && cd arcadehub
npm init -y
```

Edit `package.json`:

```json
{
  "name": "arcadehub-monorepo",
  "version": "1.0.0",
  "private": true,
  "workspaces": [
    "frontend/*"
  ],
  "scripts": {
    "dev": "npm run dev --workspace=container-shell",
    "build": "npm run build --workspaces --if-present",
    "lint": "eslint . --ext .ts,.tsx",
    "lint:fix": "eslint . --ext .ts,.tsx --fix",
    "type-check": "tsc --noEmit --composite false",
    "clean": "rm -rf frontend/*/dist node_modules frontend/*/node_modules"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "eslint": "^8.50.0",
    "eslint-config-prettier": "^9.0.0",
    "eslint-plugin-react": "^7.33.0",
    "eslint-plugin-react-hooks": "^4.6.0",
    "prettier": "^3.0.0",
    "typescript": "^5.2.0"
  }
}
```

---

### 1.2 Configure TypeScript (Strict Mode)

Create **`tsconfig.json`** at the root:

```json
{
  "compilerOptions": {
    // Strict Type Checking
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    
    // Additional Checks
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    
    // Module Resolution
    "module": "ESNext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    
    // Emit
    "target": "ES2020",
    "jsx": "react-jsx",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    
    // Advanced
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "exclude": ["node_modules", "dist", "build"]
}
```

**Why strict mode?** This catches bugs at compile time instead of runtime.

---

### 1.3 Configure ESLint

Create **`.eslintrc.js`**:

```javascript
module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: 'module',
    ecmaFeatures: {
      jsx: true,
    },
  },
  settings: {
    react: {
      version: 'detect',
    },
  },
  env: {
    browser: true,
    es2020: true,
    node: true,
  },
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:@typescript-eslint/recommended-requiring-type-checking',
    'plugin:react/recommended',
    'plugin:react-hooks/recommended',
    'prettier',
  ],
  plugins: ['@typescript-eslint', 'react', 'react-hooks'],
  rules: {
    // TypeScript
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/explicit-module-boundary-types': 'off',
    '@typescript-eslint/no-explicit-any': 'error',
    '@typescript-eslint/no-non-null-assertion': 'warn',
    
    // React
    'react/react-in-jsx-scope': 'off', // Not needed with React 17+
    'react/prop-types': 'off', // We use TypeScript
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': 'warn',
    
    // General
    'no-console': ['warn', { allow: ['warn', 'error'] }],
  },
};
```

Create **`.prettierrc`**:

```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "arrowParens": "always"
}
```

---

### 1.4 Create Container Shell App

```bash
mkdir -p frontend/container-shell/src
cd frontend/container-shell
npm init -y
```

Edit `frontend/container-shell/package.json`:

```json
{
  "name": "container-shell",
  "version": "1.0.0",
  "scripts": {
    "dev": "webpack serve --mode development",
    "build": "webpack --mode production",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "@emotion/react": "^11.11.0",
    "@emotion/styled": "^11.11.0",
    "@mui/material": "^5.15.0",
    "@mui/icons-material": "^5.15.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "html-webpack-plugin": "^5.5.0",
    "ts-loader": "^9.5.0",
    "webpack": "^5.89.0",
    "webpack-cli": "^5.1.0",
    "webpack-dev-server": "^4.15.0",
    "typescript": "^5.2.0"
  }
}
```

Install dependencies:

```bash
npm install
```

---

### 1.5 Configure TypeScript for Shell

Create `frontend/container-shell/tsconfig.json`:

```json
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src",
    "baseUrl": "./src"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

---

### 1.6 Configure Webpack

Create `frontend/container-shell/webpack.config.js`:

```javascript
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = (env, argv) => {
  const isDevelopment = argv.mode === 'development';

  return {
    entry: './src/index.tsx',
    output: {
      path: path.resolve(__dirname, 'dist'),
      filename: '[name].[contenthash].js',
      clean: true,
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
      new HtmlWebpackPlugin({
        template: './src/index.html',
        title: 'ArcadeHub',
      }),
    ],
    devServer: {
      port: 3000,
      hot: true,
      historyApiFallback: true,
    },
    devtool: isDevelopment ? 'eval-source-map' : 'source-map',
  };
};
```

---

### 1.7 Create Shell Source Files

**`frontend/container-shell/src/index.html`**:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ArcadeHub - Gaming Lounge Booking</title>
  <meta name="description" content="Book your gaming station at ArcadeHub">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
  <style>
    body {
      margin: 0;
      font-family: 'Roboto', sans-serif;
    }
  </style>
</head>
<body>
  <div id="root"></div>
</body>
</html>
```

**`frontend/container-shell/src/theme.ts`**:

```typescript
import { createTheme } from '@mui/material/styles';

// Custom theme for ArcadeHub
export const theme = createTheme({
  palette: {
    mode: 'dark',
    primary: {
      main: '#00e5ff', // Cyan
      light: '#6effff',
      dark: '#00b2cc',
    },
    secondary: {
      main: '#ff4081', // Pink
      light: '#ff79b0',
      dark: '#c60055',
    },
    background: {
      default: '#0a0e27',
      paper: '#1a1f3a',
    },
    text: {
      primary: '#ffffff',
      secondary: '#b0bec5',
    },
  },
  typography: {
    fontFamily: '"Roboto", "Helvetica", "Arial", sans-serif',
    h1: {
      fontWeight: 700,
      fontSize: '2.5rem',
    },
    h2: {
      fontWeight: 700,
      fontSize: '2rem',
    },
    button: {
      textTransform: 'none',
      fontWeight: 500,
    },
  },
  shape: {
    borderRadius: 12,
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 8,
          padding: '10px 24px',
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: 12,
          boxShadow: '0 4px 20px rgba(0, 0, 0, 0.5)',
        },
      },
    },
  },
});
```

**`frontend/container-shell/src/App.tsx`**:

```typescript
import { Box, Container, Typography, Button } from '@mui/material';
import RocketLaunchIcon from '@mui/icons-material/RocketLaunch';

function App() {
  return (
    <Container maxWidth="md">
      <Box
        sx={{
          minHeight: '100vh',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          textAlign: 'center',
        }}
      >
        <RocketLaunchIcon sx={{ fontSize: 80, color: 'primary.main', mb: 2 }} />
        <Typography variant="h1" gutterBottom>
          Hello ArcadeHub
        </Typography>
        <Typography variant="h6" color="text.secondary" paragraph>
          Your gaming lounge booking platform is ready for development
        </Typography>
        <Button
          variant="contained"
          size="large"
          startIcon={<RocketLaunchIcon />}
          sx={{ mt: 3 }}
        >
          Get Started
        </Button>
      </Box>
    </Container>
  );
}

export default App;
```

**`frontend/container-shell/src/index.tsx`**:

```typescript
import React from 'react';
import ReactDOM from 'react-dom/client';
import { ThemeProvider, CssBaseline } from '@mui/material';
import App from './App';
import { theme } from './theme';

const root = document.getElementById('root');

if (!root) {
  throw new Error('Root element not found');
}

ReactDOM.createRoot(root).render(
  <React.StrictMode>
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <App />
    </ThemeProvider>
  </React.StrictMode>
);
```

---

### 1.8 Create Shared UI Library (Skeleton)

```bash
mkdir -p frontend/shared-ui-lib/src/components
cd frontend/shared-ui-lib
npm init -y
```

Edit `frontend/shared-ui-lib/package.json`:

```json
{
  "name": "shared-ui-lib",
  "version": "1.0.0",
  "main": "src/index.ts",
  "dependencies": {
    "@mui/material": "^5.15.0",
    "react": "^18.2.0"
  }
}
```

Create `frontend/shared-ui-lib/src/index.ts`:

```typescript
// Export shared components here
// Example: export { default as Button } from './components/Button';

export const version = '1.0.0';
```

---

### 1.9 Create .gitignore

Create **`.gitignore`** at root:

```gitignore
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Build outputs
dist/
build/
*.tsbuildinfo

# Environment
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Testing
coverage/
.nyc_output/

# Misc
*.log
```

---

## ✅ Definition of Done

### Functionality
- [ ] `npm install` completes successfully at root
- [ ] `npm run dev` starts the shell at http://localhost:3000
- [ ] Browser shows "Hello ArcadeHub" with styling
- [ ] No console errors
- [ ] Hot reload works (edit App.tsx and see changes)

### Code Quality
- [ ] `npm run lint` passes with zero errors
- [ ] `npm run type-check` passes with zero errors
- [ ] TypeScript strict mode enabled
- [ ] All imports have proper types (no `any`)

### Project Structure
- [ ] Monorepo structure matches specification
- [ ] Workspaces configured correctly
- [ ] Each app has its own package.json and tsconfig.json
- [ ] Git repository initialized with proper .gitignore

---

## 🧪 Testing Checklist

```bash
# From root directory
cd arcadehub

# Install dependencies
npm install

# Check for vulnerabilities
npm audit

# Run linter
npm run lint

# Run type check
npm run type-check

# Start dev server
npm run dev

# In browser: http://localhost:3000
# Expected: "Hello ArcadeHub" with dark theme and cyan/pink colors

# Test hot reload
# Edit frontend/container-shell/src/App.tsx
# Change "Hello ArcadeHub" to "Hello World"
# Expected: Browser auto-refreshes with new text
```

---

## 💡 Tips & Best Practices

### TypeScript Tips
1. **Enable strict mode from day 1** - It's harder to add later
2. **Use interfaces for objects** - Better error messages
3. **Avoid `any`** - Use `unknown` if type is truly unknown
4. **Use optional chaining** - `user?.name` instead of `user && user.name`

### Tooling Tips
1. **Install VS Code extensions**:
   - ESLint
   - Prettier
   - TypeScript IntelliSense (built-in)
2. **Enable format on save** in VS Code settings
3. **Use npm ci** in CI/CD (faster, more reliable than npm install)

### Monorepo Tips
1. **Always run commands from root** unless specifically working in a package
2. **Use workspace commands**: `npm run <script> --workspace=<name>`
3. **Shared dependencies** go in root package.json
4. **Package-specific dependencies** go in package's package.json

---

## ⚠️ Common Pitfalls

### Problem: TypeScript errors about missing types
**Solution**: Install `@types/*` packages:
```bash
npm install --save-dev @types/react @types/react-dom
```

### Problem: ESLint complains about React not being in scope
**Solution**: Update .eslintrc.js to turn off `react/react-in-jsx-scope` rule (not needed in React 17+)

### Problem: Webpack dev server won't start
**Solution**: Check if port 3000 is already in use:
```bash
lsof -ti:3000 | xargs kill -9  # macOS/Linux
```

### Problem: Changes not hot-reloading
**Solution**: 
- Ensure webpack-dev-server is running
- Check browser console for errors
- Try hard refresh (Cmd+Shift+R / Ctrl+Shift+R)

### Problem: Import errors for MUI components
**Solution**: Verify Material-UI installation:
```bash
npm list @mui/material
```

---

## 📚 Additional Resources

- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
- [MUI Documentation](https://mui.com/material-ui/getting-started/)
- [Webpack Configuration](https://webpack.js.org/configuration/)
- [npm Workspaces](https://docs.npmjs.com/cli/v8/using-npm/workspaces)

---

## 🎯 What's Next?

Once this step is complete, move on to [Step 2: Routing + Layout](./step-02-routing.md) where you'll add React Router and create the application layout structure.

---

**Estimated Time**: 12-16 hours  
**Difficulty**: Medium - Lots of configuration, but straightforward

**Need Help?** Review COMMON_PITFALLS.md or ask for clarification on specific errors.
