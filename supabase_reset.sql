-- ============================================
-- SUPABASE DATABASE RESET SCRIPT
-- ============================================
-- WARNING: This script will DELETE ALL DATA
-- Run this in Supabase SQL Editor
-- ============================================

-- Drop all existing tables (in correct order due to foreign keys)
DROP TABLE IF EXISTS sale_items CASCADE;
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS expenses CASCADE;
DROP TABLE IF EXISTS weekly_checkups CASCADE;

-- ============================================
-- RECREATE TABLES
-- ============================================

-- Customers table
CREATE TABLE customers (
  id TEXT PRIMARY KEY,
  server_id UUID UNIQUE DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  is_dirty BOOLEAN DEFAULT true,
  last_synced_at TIMESTAMPTZ,
  name TEXT NOT NULL,
  phone_number TEXT,
  email TEXT,
  address TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- Products table
CREATE TABLE products (
  id TEXT PRIMARY KEY,
  server_id UUID UNIQUE DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  is_dirty BOOLEAN DEFAULT true,
  last_synced_at TIMESTAMPTZ,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL DEFAULT 0,
  purchase_price DECIMAL(10, 2) NOT NULL DEFAULT 0,
  stock_quantity INTEGER NOT NULL DEFAULT 0,
  image_path TEXT,
  product_type TEXT,
  quality TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- Sales table
CREATE TABLE sales (
  id TEXT PRIMARY KEY,
  server_id UUID UNIQUE DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  customer_id TEXT REFERENCES customers(id) ON DELETE SET NULL,
  is_dirty BOOLEAN DEFAULT true,
  last_synced_at TIMESTAMPTZ,
  total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
  sale_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  notes TEXT,
  metadata_json JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  operation_id TEXT,
  is_delivery BOOLEAN DEFAULT false,
  status TEXT DEFAULT 'Complete',
  is_paid BOOLEAN DEFAULT true,
  delivery_address TEXT
);

-- Sale Items table
CREATE TABLE sale_items (
  id TEXT PRIMARY KEY,
  server_id UUID UNIQUE DEFAULT gen_random_uuid(),
  sale_id TEXT REFERENCES sales(id) ON DELETE CASCADE,
  product_id TEXT REFERENCES products(id) ON DELETE SET NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  unit_price DECIMAL(10, 2) NOT NULL DEFAULT 0,
  total_price DECIMAL(10, 2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- Expenses table
CREATE TABLE expenses (
  id TEXT PRIMARY KEY,
  server_id UUID UNIQUE DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  is_dirty BOOLEAN DEFAULT true,
  last_synced_at TIMESTAMPTZ,
  description TEXT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
  category TEXT NOT NULL DEFAULT 'business',
  expense_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  notes TEXT,
  receipt_image_path TEXT,
  stock_product_name TEXT,
  stock_product_type TEXT,
  stock_quality TEXT,
  stock_quantity INTEGER,
  stock_purchase_price DECIMAL(10, 2),
  stock_resale_price DECIMAL(10, 2),
  stock_image_path TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  operation_id TEXT
);

-- Weekly Checkups table
CREATE TABLE weekly_checkups (
  id TEXT PRIMARY KEY,
  server_id UUID UNIQUE DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  is_dirty BOOLEAN DEFAULT true,
  last_synced_at TIMESTAMPTZ,
  week_start_date DATE NOT NULL,
  week_end_date DATE NOT NULL,
  checkup_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  total_stock_purchased DECIMAL(10, 2) DEFAULT 0,
  total_sales_revenue DECIMAL(10, 2) DEFAULT 0,
  total_business_expenses DECIMAL(10, 2) DEFAULT 0,
  total_personal_payouts DECIMAL(10, 2) DEFAULT 0,
  capital_recovered DECIMAL(10, 2) DEFAULT 0,
  capital_remaining DECIMAL(10, 2) DEFAULT 0,
  realized_profit DECIMAL(10, 2) DEFAULT 0,
  profit_payout_taken DECIMAL(10, 2) DEFAULT 0,
  profit_reinjected DECIMAL(10, 2) DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  operation_id TEXT,
  sales_count INTEGER DEFAULT 0,
  stock_items_count INTEGER DEFAULT 0,
  category_revenue JSONB,
  top_products JSONB
);

-- ============================================
-- CREATE INDEXES
-- ============================================

CREATE INDEX idx_customers_user_id ON customers(user_id);
CREATE INDEX idx_customers_server_id ON customers(server_id);
CREATE INDEX idx_customers_deleted_at ON customers(deleted_at);

CREATE INDEX idx_products_user_id ON products(user_id);
CREATE INDEX idx_products_server_id ON products(server_id);
CREATE INDEX idx_products_deleted_at ON products(deleted_at);

CREATE INDEX idx_sales_user_id ON sales(user_id);
CREATE INDEX idx_sales_server_id ON sales(server_id);
CREATE INDEX idx_sales_customer_id ON sales(customer_id);
CREATE INDEX idx_sales_sale_date ON sales(sale_date);
CREATE INDEX idx_sales_deleted_at ON sales(deleted_at);

CREATE INDEX idx_sale_items_sale_id ON sale_items(sale_id);
CREATE INDEX idx_sale_items_product_id ON sale_items(product_id);
CREATE INDEX idx_sale_items_server_id ON sale_items(server_id);

CREATE INDEX idx_expenses_user_id ON expenses(user_id);
CREATE INDEX idx_expenses_server_id ON expenses(server_id);
CREATE INDEX idx_expenses_category ON expenses(category);
CREATE INDEX idx_expenses_expense_date ON expenses(expense_date);
CREATE INDEX idx_expenses_deleted_at ON expenses(deleted_at);

CREATE INDEX idx_weekly_checkups_user_id ON weekly_checkups(user_id);
CREATE INDEX idx_weekly_checkups_server_id ON weekly_checkups(server_id);
CREATE INDEX idx_weekly_checkups_week_start ON weekly_checkups(week_start_date);

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_checkups ENABLE ROW LEVEL SECURITY;

-- Customers policies
CREATE POLICY "Users can view own customers" ON customers
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own customers" ON customers
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own customers" ON customers
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own customers" ON customers
  FOR DELETE USING (auth.uid() = user_id);

-- Products policies
CREATE POLICY "Users can view own products" ON products
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own products" ON products
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own products" ON products
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own products" ON products
  FOR DELETE USING (auth.uid() = user_id);

-- Sales policies
CREATE POLICY "Users can view own sales" ON sales
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sales" ON sales
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own sales" ON sales
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own sales" ON sales
  FOR DELETE USING (auth.uid() = user_id);

-- Sale Items policies
CREATE POLICY "Users can view own sale items" ON sale_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM sales WHERE sales.id = sale_items.sale_id AND sales.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own sale items" ON sale_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM sales WHERE sales.id = sale_items.sale_id AND sales.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own sale items" ON sale_items
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM sales WHERE sales.id = sale_items.sale_id AND sales.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own sale items" ON sale_items
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM sales WHERE sales.id = sale_items.sale_id AND sales.user_id = auth.uid()
    )
  );

-- Expenses policies
CREATE POLICY "Users can view own expenses" ON expenses
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own expenses" ON expenses
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own expenses" ON expenses
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own expenses" ON expenses
  FOR DELETE USING (auth.uid() = user_id);

-- Weekly Checkups policies
CREATE POLICY "Users can view own weekly checkups" ON weekly_checkups
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own weekly checkups" ON weekly_checkups
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own weekly checkups" ON weekly_checkups
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own weekly checkups" ON weekly_checkups
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- FUNCTIONS FOR AUTOMATIC TIMESTAMPS
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sales_updated_at BEFORE UPDATE ON sales
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sale_items_updated_at BEFORE UPDATE ON sale_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON expenses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_weekly_checkups_updated_at BEFORE UPDATE ON weekly_checkups
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- STORAGE BUCKETS
-- ============================================

-- Insert storage buckets (these need to be created via Supabase Dashboard or API)
-- The following are the SQL commands to enable storage and create policies
-- Note: Actual bucket creation must be done via Supabase Dashboard → Storage

-- Enable storage extension
-- (This is typically enabled by default in Supabase)

-- Storage bucket policies for 'products' bucket
-- CREATE POLICY "Users can view own product images" ON storage.objects
--   FOR SELECT USING (bucket_id = 'products' AND auth.uid()::text = (storage.foldername(name))[1]);

-- CREATE POLICY "Users can upload product images" ON storage.objects
--   FOR INSERT WITH CHECK (bucket_id = 'products' AND auth.uid()::text = (storage.foldername(name))[1]);

-- CREATE POLICY "Users can delete own product images" ON storage.objects
--   FOR DELETE USING (bucket_id = 'products' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Storage bucket policies for 'receipts' bucket
-- CREATE POLICY "Users can view own receipt images" ON storage.objects
--   FOR SELECT USING (bucket_id = 'receipts' AND auth.uid()::text = (storage.foldername(name))[1]);

-- CREATE POLICY "Users can upload receipt images" ON storage.objects
--   FOR INSERT WITH CHECK (bucket_id = 'receipts' AND auth.uid()::text = (storage.foldername(name))[1]);

-- CREATE POLICY "Users can delete own receipt images" ON storage.objects
--   FOR DELETE USING (bucket_id = 'receipts' AND auth.uid()::text = (storage.foldername(name))[1]);

-- ============================================
-- COMPLETION MESSAGE
-- ============================================

-- Verify tables were created
SELECT 
  table_name,
  (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public'
  AND table_name IN ('customers', 'products', 'sales', 'sale_items', 'expenses', 'weekly_checkups')
ORDER BY table_name;
