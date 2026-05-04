import { productsToCsv } from '../../../src/utils/csvExport';
import { ProductCard, InventoryStatus } from '../../../src/types/product';

const HEADER = 'id,name,price,inventory_status';

describe('productsToCsv', () => {
  it('returns header only for empty array', () => {
    expect(productsToCsv([])).toBe(HEADER);
  });

  it('converts a single product to CSV', () => {
    const products: ProductCard[] = [
      { id: 1, name: 'Widget', price: 9.99, inventory_status: InventoryStatus.in_stock },
    ];
    expect(productsToCsv(products)).toBe(`${HEADER}\n1,Widget,9.99,in_stock`);
  });

  it('handles multiple rows', () => {
    const products: ProductCard[] = [
      { id: 1, name: 'Widget', price: 9.99, inventory_status: InventoryStatus.in_stock },
      { id: 2, name: 'Gadget', price: 19.99, inventory_status: InventoryStatus.low_stock },
    ];
    expect(productsToCsv(products)).toBe(
      `${HEADER}\n1,Widget,9.99,in_stock\n2,Gadget,19.99,low_stock`
    );
  });

  it('escapes commas in field values (RFC 4180)', () => {
    const products: ProductCard[] = [
      { id: 3, name: 'A, B', price: 5.0, inventory_status: InventoryStatus.out_of_stock },
    ];
    expect(productsToCsv(products)).toBe(`${HEADER}\n3,"A, B",5,out_of_stock`);
  });

  it('escapes double-quotes in field values (RFC 4180)', () => {
    const products: ProductCard[] = [
      { id: 4, name: 'Say "hello"', price: 1.0, inventory_status: InventoryStatus.in_stock },
    ];
    expect(productsToCsv(products)).toBe(`${HEADER}\n4,"Say ""hello""",1,in_stock`);
  });
});
