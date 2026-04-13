-- Re-enable Row Level Security (RLS) with proper user isolation policies
-- Run this in Supabase SQL Editor

-- 1. ENABLE RLS ON ALL TABLES
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

-- 2. DROP EXISTING POLICIES (Clean slate)
DROP POLICY IF EXISTS "Users can manage their own products" ON products;
DROP POLICY IF EXISTS "Users can manage their own customers" ON customers;
DROP POLICY IF EXISTS "Users can manage their own sales" ON sales;
DROP POLICY IF EXISTS "Users can manage their own sale_items" ON sale_items;
DROP POLICY IF EXISTS "Users can manage their own expenses" ON expenses;

-- 3. CREATE POLICIES FOR PRODUCTS
CREATE POLICY "Users can view their own products"
  ON products FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own products"
  ON products FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own products"
  ON products FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own products"
  ON products FOR DELETE
  USING (auth.uid() = user_id);

-- 4. CREATE POLICIES FOR CUSTOMERS
CREATE POLICY "Users can view their own customers"
  ON customers FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own customers"
  ON customers FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own customers"
  ON customers FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own customers"
  ON customers FOR DELETE
  USING (auth.uid() = user_id);

-- 5. CREATE POLICIES FOR SALES
CREATE POLICY "Users can view their own sales"
  ON sales FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own sales"
  ON sales FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own sales"
  ON sales FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own sales"
  ON sales FOR DELETE
  USING (auth.uid() = user_id);

-- 6. CREATE POLICIES FOR SALE ITEMS
CREATE POLICY "Users can view their own sale_items"
  ON sale_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM sales
      WHERE sales.server_id = sale_items.sale_id
      AND sales.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert their own sale_items"
  ON sale_items FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM sales
      WHERE sales.server_id = sale_items.sale_id
      AND sales.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update their own sale_items"
  ON sale_items FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM sales
      WHERE sales.server_id = sale_items.sale_id
      AND sales.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM sales
      WHERE sales.server_id = sale_items.sale_id
      AND sales.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete their own sale_items"
  ON sale_items FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM sales
      WHERE sales.server_id = sale_items.sale_id
      AND sales.user_id = auth.uid()
    )
  );

-- 7. CREATE POLICIES FOR EXPENSES
CREATE POLICY "Users can view their own expenses"
  ON expenses FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own expenses"
  ON expenses FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own expenses"
  ON expenses FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own expenses"
  ON expenses FOR DELETE
  USING (auth.uid() = user_id);

-- 8. VERIFICATION QUERY (Optional - run to verify policies are active)
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename IN ('products', 'customers', 'sales', 'sale_items', 'expenses')
ORDER BY tablename, policyname;
