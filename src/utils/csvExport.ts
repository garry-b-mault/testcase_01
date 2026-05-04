import { ProductCard } from '../types/product';

function escapeField(value: string | number): string {
  const str = String(value);
  if (str.includes(',') || str.includes('"') || str.includes('\n')) {
    return `"${str.replace(/"/g, '""')}"`;
  }
  return str;
}

export function productsToCsv(products: ProductCard[]): string {
  const header = 'id,name,price,inventory_status';
  if (products.length === 0) return header;
  const rows = products.map((p) =>
    [p.id, p.name, p.price, p.inventory_status].map(escapeField).join(',')
  );
  return [header, ...rows].join('\n');
}
