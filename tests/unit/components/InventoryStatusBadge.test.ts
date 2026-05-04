import { getInventoryBadgeProps } from '../../../src/components/InventoryStatusBadge';
import { InventoryStatus } from '../../../src/types/product';

describe('getInventoryBadgeProps', () => {
  it('returns correct badge for in_stock', () => {
    const result = getInventoryBadgeProps(InventoryStatus.in_stock);
    expect(result.label).toBe('In Stock');
    expect(result.colorClass).toBe('badge-green');
    expect(result.ariaLabel).toBe('In stock');
  });

  it('returns correct badge for low_stock', () => {
    const result = getInventoryBadgeProps(InventoryStatus.low_stock);
    expect(result.label).toBe('Low Stock');
    expect(result.colorClass).toBe('badge-yellow');
    expect(result.ariaLabel).toBe('Low stock');
  });

  it('returns correct badge for out_of_stock', () => {
    const result = getInventoryBadgeProps(InventoryStatus.out_of_stock);
    expect(result.label).toBe('Out of Stock');
    expect(result.colorClass).toBe('badge-red');
    expect(result.ariaLabel).toBe('Out of stock');
  });

  it('return value is typed BadgeProps', () => {
    const result = getInventoryBadgeProps(InventoryStatus.in_stock);
    expect(typeof result.label).toBe('string');
    expect(typeof result.colorClass).toBe('string');
    expect(typeof result.ariaLabel).toBe('string');
  });
});
