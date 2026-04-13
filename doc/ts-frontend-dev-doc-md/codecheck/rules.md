# 前端代码检查规则（ESLint + Prettier + 质量门禁）

> 适用于所有框架（React / Vue）和平台
> 最后更新：2026-04-11

---

## 一、工具矩阵

| 工具 | 检查层面 | 核心能力 |
|------|---------|---------|
| **ESLint** | 代码质量 | 逻辑错误、最佳实践、React/Vue 规则 |
| **Prettier** | 代码格式 | 缩进、引号、行宽、分号 |
| **TypeScript** | 类型检查 | 类型安全、接口约束 |
| **Stylelint** | 样式检查 | CSS 规范、属性顺序 |
| **Lighthouse** | 性能审计 | LCP、FID、CLS、a11y |
| **knip** | 死代码检测 | 未使用的导出、类型、文件 |

---

## 二、ESLint 核心配置（Flat Config）

```javascript
// eslint.config.mjs
import tseslint from 'typescript-eslint';
import reactPlugin from 'eslint-plugin-react';
import reactHooksPlugin from 'eslint-plugin-react-hooks';
import reactRefreshPlugin from 'eslint-plugin-react-refresh';
import jsxA11yPlugin from 'eslint-plugin-jsx-a11y';
import importPlugin from 'eslint-plugin-import';

export default tseslint.config(
  // 全局忽略
  {
    ignores: ['dist/', 'node_modules/', '*.js', '*.mjs'],
  },

  // 基础 TypeScript 规则
  ...tseslint.configs.recommended,

  // React 规则
  {
    files: ['**/*.{ts,tsx}'],
    plugins: {
      react: reactPlugin,
      'react-hooks': reactHooksPlugin,
      'react-refresh': reactRefreshPlugin,
      'jsx-a11y': jsxA11yPlugin,
      import: importPlugin,
    },
    settings: {
      react: { version: 'detect' },
    },
    rules: {
      // React 规则
      'react/react-in-jsx-scope': 'off', // React 17+ 不需要
      'react/prop-types': 'off',          // 使用 TypeScript
      'react/jsx-no-bind': ['warn', { allowArrowFunctions: true }],
      'react/no-array-index-key': 'warn',
      'react/self-closing-comp': 'error',
      'react/jsx-curly-brace-presence': ['error', {
        props: 'never',
        children: 'never',
      }],

      // React Hooks 规则
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn',

      // a11y 规则
      'jsx-a11y/alt-text': 'error',
      'jsx-a11y/click-events-have-key-events': 'warn',

      // Import 规则
      'import/order': ['error', {
        groups: ['builtin', 'external', 'internal', 'parent', 'sibling', 'index'],
        'newlines-between': 'never',
        alphabetize: { order: 'asc' },
      }],

      // TypeScript 规则
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-unused-vars': ['error', {
        argsIgnorePattern: '^_',
        varsIgnorePattern: '^_',
      }],
      '@typescript-eslint/explicit-function-return-type': 'off',
      '@typescript-eslint/consistent-type-imports': ['error', {
        prefer: 'type-imports',
      }],
      '@typescript-eslint/no-non-null-assertion': 'warn',
      '@typescript-eslint/prefer-nullish-coalescing': 'error',
      '@typescript-eslint/prefer-optional-chain': 'error',
    },
  },
);
```

---

## 三、Prettier 配置

```json
// .prettierrc
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 2,
  "bracketSpacing": true,
  "arrowParens": "always",
  "endOfLine": "lf",
  "jsxSingleQuote": false
}
```

---

## 四、Vue ESLint 配置补充

```javascript
// Vue 项目额外配置
import vuePlugin from 'eslint-plugin-vue';

export default [
  ...vuePlugin.configs['flat/recommended'],
  {
    files: ['**/*.vue'],
    rules: {
      'vue/multi-word-component-names': 'error',
      'vue/no-v-html': 'error',
      'vue/require-default-prop': 'off',
      'vue/require-explicit-emits': 'error',
      'vue/no-unused-refs': 'error',
      'vue/block-lang': ['error', {
        script: { lang: 'ts' },
      }],
    },
  },
];
```

---

## 五、Stylelint 配置

```json
// .stylelintrc.json
{
  "extends": [
    "stylelint-config-standard",
    "stylelint-config-css-modules"
  ],
  "rules": {
    "selector-class-pattern": null,
    "no-important": true,
    "max-nesting-depth": 3
  }
}
```

---

## 六、tsconfig.json 规范

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "esModuleInterop": true,
    "jsx": "react-jsx",
    "skipLibCheck": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

---

## 七、质量门禁阈值

| 指标 | 阻塞 | 告警 |
|------|------|------|
| ESLint 错误 | 0 | 0 |
| TypeScript 错误 | 0 | 0 |
| `any` 类型使用 | 0 | > 0 |
| 未使用的变量/导入 | 0 | 0 |
| Lighthouse Performance | ≥ 80 | < 60 |
| Lighthouse Accessibility | ≥ 90 | < 80 |
| 测试覆盖率 | ≥ 80% | < 70% |
| Bundle Size 增长 | < 10% | > 20% |

---

## 八、CI 集成模板

```yaml
# GitHub Actions
name: Frontend CI
on: [push, pull_request]

jobs:
  lint-and-type:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      - run: npm ci
      - name: ESLint
        run: npx eslint . --max-warnings=0
      - name: TypeScript
        run: npx tsc --noEmit
      - name: Prettier
        run: npx prettier --check .

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      - run: npm ci
      - name: Unit tests
        run: npx vitest run --coverage
      - name: Check coverage
        run: npx coverage-istanbul --threshold 80

  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      - run: npm ci
      - name: Build
        run: npm run build
      - name: Analyze bundle
        run: npx size-limit
```

> 来源：[ESLint Flat Config Guide](https://advancedfrontends.com/eslint-flat-config-typescript-javascript/), [Linting and Formatting TypeScript 2025](https://finnnannestad.com/blog/linting-and-formatting), [React Linting Best Practices](https://propelius.tech/blogs/best-practices-for-linting-react-code/)
