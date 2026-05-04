import { InventoryStatus, ProductCard } from '../../../src/types/product';

describe('InventoryStatus', () => {
  it('has in_stock value', () => {
    expect(InventoryStatus.in_stock).toBe('in_stock');
  });

  it('has low_stock value', () => {
    expect(InventoryStatus.low_stock).toBe('low_stock');
  });

  it('has out_of_stock value', () => {
    expect(InventoryStatus.out_of_stock).toBe('out_of_stock');
  });
});

describe('ProductCard', () => {
  it('accepts a valid product object', () => {
    const p: ProductCard = {
      id: 1,
      name: 'Widget',
      price: 9.99,
      inventory_status: InventoryStatus.in_stock,
    };
    expect(p.id).toBe(1);
    expect(p.name).toBe('Widget');
    expect(p.price).toBe(9.99);
    expect(p.inventory_status).toBe(InventoryStatus.in_stock);
  });

  it('accepts all three inventory statuses', () => {
    const statuses: InventoryStatus[] = [
      InventoryStatus.in_stock,
      InventoryStatus.low_stock,
      InventoryStatus.out_of_stock,
    ];
    expect(statuses).toHaveLength(3);
  });
});
