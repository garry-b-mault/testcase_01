import { ProductCard } from '../types/product';
import { BadgeProps, getInventoryBadgeProps } from './InventoryStatusBadge';

export interface ProductCardDisplay {
  product: ProductCard;
  badge: BadgeProps;
}

export function assembleProductCard(product: ProductCard): ProductCardDisplay {
  return {
    product,
    badge: getInventoryBadgeProps(product.inventory_status),
  };
}
