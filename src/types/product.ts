export enum InventoryStatus {
  in_stock = 'in_stock',
  low_stock = 'low_stock',
  out_of_stock = 'out_of_stock',
}

export interface ProductCard {
  id: number;
  name: string;
  price: number;
  inventory_status: InventoryStatus;
}
