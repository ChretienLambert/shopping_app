-- Incremental schema update for latest app changes.
-- Run this in Supabase SQL editor on your existing project.

-- PRODUCTS: add stock sourcing fields
ALTER TABLE products
  ADD COLUMN IF NOT EXISTS purchase_price DECIMAL(12, 2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS product_type TEXT,
  ADD COLUMN IF NOT EXISTS quality TEXT;

-- EXPENSES: add stock-expense detail fields
ALTER TABLE expenses
  ADD COLUMN IF NOT EXISTS stock_product_name TEXT,
  ADD COLUMN IF NOT EXISTS stock_product_type TEXT,
  ADD COLUMN IF NOT EXISTS stock_quality TEXT,
  ADD COLUMN IF NOT EXISTS stock_quantity INTEGER,
  ADD COLUMN IF NOT EXISTS stock_purchase_price DECIMAL(12, 2),
  ADD COLUMN IF NOT EXISTS stock_resale_price DECIMAL(12, 2),
  ADD COLUMN IF NOT EXISTS stock_image_path TEXT;

-- Helpful index for finance reads by category/date
CREATE INDEX IF NOT EXISTS idx_expenses_category_date
  ON expenses(category, expense_date);
