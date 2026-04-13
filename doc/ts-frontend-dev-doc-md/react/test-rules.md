# React 测试规则

> 所属框架：React
> 最后更新：2026-04-11

---

## 1. 工具选型

| 工具 | 用途 |
|------|------|
| Vitest | 测试运行器 |
| React Testing Library | 组件测试 |
| MSW (Mock Service Worker) | API Mock |
| Playwright / Cypress | E2E 测试 |

## 2. 测试铁律

- 【强制】测试行为，不测试实现细节
- 【强制】使用 `screen.getByRole` / `getByText` 查询元素
- 【强制】异步状态使用 `waitFor` / `findBy`
- 【推荐】关键路径覆盖率 ≥ 80%
- 【推荐】测试文件与组件同目录

## 3. 组件测试模板

```typescript
// OrderList.test.tsx
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';
import { OrderList } from './OrderList';

const mockOrders = [
  { id: '1', title: '订单1', status: 'draft' },
  { id: '2', title: '订单2', status: 'confirmed' },
];

const server = setupServer(
  http.get('/api/orders', () => HttpResponse.json(mockOrders)),
);

beforeAll(() => server.listen());
afterAll(() => server.close());

describe('OrderList', () => {
  it('renders orders after loading', async () => {
    render(<OrderList userId="user-1" />);

    expect(screen.getByRole('progressbar')).toBeInTheDocument();

    await waitFor(() => {
      expect(screen.getByText('订单1')).toBeInTheDocument();
      expect(screen.getByText('订单2')).toBeInTheDocument();
    });
  });

  it('calls onSelectOrder when clicking an order', async () => {
    const onSelect = vi.fn();
    render(<OrderList userId="user-1" onSelectOrder={onSelect} />);

    await waitFor(() => screen.getByText('订单1'));

    await userEvent.click(screen.getByText('订单1'));
    expect(onSelect).toHaveBeenCalledWith(
      expect.objectContaining({ id: '1' }),
    );
  });
});
```

## 4. Hook 测试模板

```typescript
import { renderHook, waitFor } from '@testing-library/react';
import { useOrderList } from './useOrderList';

describe('useOrderList', () => {
  it('fetches and returns orders', async () => {
    const { result } = renderHook(() => useOrderList('user-1'));

    expect(result.current.isLoading).toBe(true);

    await waitFor(() => {
      expect(result.current.isLoading).toBe(false);
      expect(result.current.orders).toHaveLength(2);
    });
  });
});
```
