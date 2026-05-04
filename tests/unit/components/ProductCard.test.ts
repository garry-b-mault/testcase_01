import { assembleProductCard } from '../../../src/components/ProductCard';
import { InventoryStatus, ProductCard } from '../../../src/types/product';

const base: ProductCard = { id: 1, name: 'Widget', price: 9.99, inventory_status: InventoryStatus.in_stock };

describe('assembleProductCard', () => {
  it('returns in_stock badge props for in_stock product', () => {
    const result = assembleProductCard(base);
    expect(result.badge.label).toBe('In Stock');
    expect(result.badge.colorClass).toBe('badge-green');
    expect(result.badge.ariaLabel).toBe('In stock');
    expect(result.product).toEqual(base);
  });

  it('returns low_stock badge props for low_stock product', () => {
    const product: ProductCard = { ...base, inventory_status: InventoryStatus.low_stock };
    const result = assembleProductCard(product);
    expect(result.badge.label).toBe('Low Stock');
    expect(result.badge.colorClass).toBe('badge-yellow');
    expect(result.badge.ariaLabel).toBe('Low stock');
  });

  it('returns out_of_stock badge props for out_of_stock product', () => {
    const product: ProductCard = { ...base, inventory_status: InventoryStatus.out_of_stock };
    const result = assembleProductCard(product);
    expect(result.badge.label).toBe('Out of Stock');
    expect(result.badge.colorClass).toBe('badge-red');
    expect(result.badge.ariaLabel).toBe('Out of stock');
  });
});
