import { InventoryStatus } from '../types/product';

export interface BadgeProps {
  label: string;
  colorClass: string;
  ariaLabel: string;
}

const BADGE_MAP: Record<InventoryStatus, BadgeProps> = {
  [InventoryStatus.in_stock]: {
    label: 'In Stock',
    colorClass: 'badge-green',
    ariaLabel: 'In stock',
  },
  [InventoryStatus.low_stock]: {
    label: 'Low Stock',
    colorClass: 'badge-yellow',
    ariaLabel: 'Low stock',
  },
  [InventoryStatus.out_of_stock]: {
    label: 'Out of Stock',
    colorClass: 'badge-red',
    ariaLabel: 'Out of stock',
  },
};

export function getInventoryBadgeProps(status: InventoryStatus): BadgeProps {
  return BADGE_MAP[status];
}
