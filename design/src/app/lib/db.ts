import Dexie, { type EntityTable } from 'dexie';

export interface Product {
  id?: number;
  name: string;
  description: string;
  price: number;
  stock: number;
  photo?: string;
  createdAt: Date;
}

export interface Customer {
  id?: number;
  name: string;
  phone: string;
  email?: string;
  address?: string;
  createdAt: Date;
}

export interface Sale {
  id?: number;
  productId: number;
  customerId?: number;
  quantity: number;
  totalAmount: number;
  date: Date;
}

export interface Expense {
  id?: number;
  category: string;
  description: string;
  amount: number;
  date: Date;
}

const db = new Dexie('ShopDB') as Dexie & {
  products: EntityTable<Product, 'id'>;
  customers: EntityTable<Customer, 'id'>;
  sales: EntityTable<Sale, 'id'>;
  expenses: EntityTable<Expense, 'id'>;
};

db.version(1).stores({
  products: '++id, name, price, stock, createdAt',
  customers: '++id, name, phone, createdAt',
  sales: '++id, productId, customerId, date',
  expenses: '++id, category, date',
});

export { db };
