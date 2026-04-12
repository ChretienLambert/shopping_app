import { useMemo } from 'react';
import { motion } from 'motion/react';
import { db } from '../lib/db';
import { TrendingUp, TrendingDown, DollarSign, ShoppingBag, ArrowUpRight, ArrowDownRight, Package, Users } from 'lucide-react';
import { useLiveQuery } from 'dexie-react-hooks';
import { AreaChart, Area, BarChart, Bar, PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from 'recharts';

const COLORS = ['#3b82f6', '#8b5cf6', '#ec4899', '#f59e0b', '#10b981', '#6366f1'];

export function Dashboard() {
  const sales = useLiveQuery(() => db.sales.toArray()) || [];
  const expenses = useLiveQuery(() => db.expenses.toArray()) || [];
  const products = useLiveQuery(() => db.products.toArray()) || [];
  const customers = useLiveQuery(() => db.customers.toArray()) || [];

  const totalRevenue = sales.reduce((sum, sale) => sum + sale.totalAmount, 0);
  const totalExpenses = expenses.reduce((sum, expense) => sum + expense.amount, 0);
  const netIncome = totalRevenue - totalExpenses;
  const totalStock = products.reduce((sum, product) => sum + product.stock, 0);

  // Revenue vs Expenses over time
  const financialTrend = useMemo(() => {
    const last7Days = Array.from({ length: 7 }, (_, i) => {
      const date = new Date();
      date.setDate(date.getDate() - (6 - i));
      return date.toISOString().split('T')[0];
    });

    return last7Days.map((date) => {
      const dayRevenue = sales
        .filter((s) => new Date(s.date).toISOString().split('T')[0] === date)
        .reduce((sum, s) => sum + s.totalAmount, 0);

      const dayExpenses = expenses
        .filter((e) => new Date(e.date).toISOString().split('T')[0] === date)
        .reduce((sum, e) => sum + e.amount, 0);

      return {
        date: new Date(date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
        revenue: dayRevenue,
        expenses: dayExpenses,
      };
    });
  }, [sales, expenses]);

  // Top selling products
  const topProducts = useMemo(() => {
    const productSales = sales.reduce((acc, sale) => {
      acc[sale.productId] = (acc[sale.productId] || 0) + sale.quantity;
      return acc;
    }, {} as Record<number, number>);

    return Object.entries(productSales)
      .map(([productId, quantity]) => {
        const product = products.find((p) => p.id === parseInt(productId));
        return { name: product?.name || 'Unknown', quantity };
      })
      .sort((a, b) => b.quantity - a.quantity)
      .slice(0, 5);
  }, [sales, products]);

  // Expense breakdown by category
  const expenseByCategory = useMemo(() => {
    const categoryTotals = expenses.reduce((acc, expense) => {
      acc[expense.category] = (acc[expense.category] || 0) + expense.amount;
      return acc;
    }, {} as Record<string, number>);

    return Object.entries(categoryTotals).map(([name, value]) => ({ name, value }));
  }, [expenses]);

  return (
    <div className="h-full overflow-y-auto bg-slate-50">
      <div className="p-4 lg:p-8 space-y-6">
        {/* Key Metrics */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="bg-gradient-to-br from-emerald-500 to-emerald-600 rounded-2xl p-6 text-white shadow-lg"
          >
            <div className="flex items-start justify-between mb-4">
              <div className="w-12 h-12 rounded-xl bg-white/20 backdrop-blur-sm flex items-center justify-center">
                <TrendingUp className="w-6 h-6" />
              </div>
              <div className="flex items-center gap-1 text-xs font-medium bg-white/20 px-2 py-1 rounded-lg">
                <ArrowUpRight className="w-3 h-3" />
                <span>{sales.length}</span>
              </div>
            </div>
            <div className="text-3xl font-bold mb-1">${totalRevenue.toFixed(0)}</div>
            <div className="text-emerald-100 text-sm">Total Revenue</div>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="bg-gradient-to-br from-rose-500 to-rose-600 rounded-2xl p-6 text-white shadow-lg"
          >
            <div className="flex items-start justify-between mb-4">
              <div className="w-12 h-12 rounded-xl bg-white/20 backdrop-blur-sm flex items-center justify-center">
                <TrendingDown className="w-6 h-6" />
              </div>
              <div className="flex items-center gap-1 text-xs font-medium bg-white/20 px-2 py-1 rounded-lg">
                <ArrowDownRight className="w-3 h-3" />
                <span>{expenses.length}</span>
              </div>
            </div>
            <div className="text-3xl font-bold mb-1">${totalExpenses.toFixed(0)}</div>
            <div className="text-rose-100 text-sm">Total Expenses</div>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className={`bg-gradient-to-br ${
              netIncome >= 0 ? 'from-blue-500 to-blue-600' : 'from-orange-500 to-orange-600'
            } rounded-2xl p-6 text-white shadow-lg`}
          >
            <div className="flex items-start justify-between mb-4">
              <div className="w-12 h-12 rounded-xl bg-white/20 backdrop-blur-sm flex items-center justify-center">
                <DollarSign className="w-6 h-6" />
              </div>
              <div className={`text-xs font-medium px-2 py-1 rounded-lg ${
                netIncome >= 0 ? 'bg-emerald-500/30' : 'bg-rose-500/30'
              }`}>
                {netIncome >= 0 ? 'Profit' : 'Loss'}
              </div>
            </div>
            <div className="text-3xl font-bold mb-1">${Math.abs(netIncome).toFixed(0)}</div>
            <div className={netIncome >= 0 ? 'text-blue-100' : 'text-orange-100'} text-sm>Net Income</div>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
            className="bg-gradient-to-br from-purple-500 to-purple-600 rounded-2xl p-6 text-white shadow-lg"
          >
            <div className="flex items-start justify-between mb-4">
              <div className="w-12 h-12 rounded-xl bg-white/20 backdrop-blur-sm flex items-center justify-center">
                <ShoppingBag className="w-6 h-6" />
              </div>
              <div className="flex items-center gap-1 text-xs font-medium bg-white/20 px-2 py-1 rounded-lg">
                <Package className="w-3 h-3" />
                <span>{products.length}</span>
              </div>
            </div>
            <div className="text-3xl font-bold mb-1">{totalStock}</div>
            <div className="text-purple-100 text-sm">Total Stock</div>
          </motion.div>
        </div>

        {/* Charts Row */}
        <div className="grid lg:grid-cols-2 gap-6">
          {/* Revenue vs Expenses Trend */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5 }}
            className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200"
          >
            <div className="mb-6">
              <h3 className="font-bold text-slate-900 mb-1">Financial Overview</h3>
              <p className="text-sm text-slate-500">Revenue vs Expenses (Last 7 days)</p>
            </div>
            {financialTrend.length > 0 && financialTrend.some(d => d.revenue > 0 || d.expenses > 0) ? (
              <ResponsiveContainer width="100%" height={250}>
                <AreaChart data={financialTrend}>
                  <defs>
                    <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#10b981" stopOpacity={0.3}/>
                      <stop offset="95%" stopColor="#10b981" stopOpacity={0}/>
                    </linearGradient>
                    <linearGradient id="colorExpenses" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#ef4444" stopOpacity={0.3}/>
                      <stop offset="95%" stopColor="#ef4444" stopOpacity={0}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                  <XAxis dataKey="date" stroke="#94a3b8" fontSize={12} />
                  <YAxis stroke="#94a3b8" fontSize={12} />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: 'white',
                      border: '1px solid #e2e8f0',
                      borderRadius: '8px',
                      fontSize: '12px'
                    }}
                  />
                  <Area type="monotone" dataKey="revenue" stroke="#10b981" fillOpacity={1} fill="url(#colorRevenue)" strokeWidth={2} />
                  <Area type="monotone" dataKey="expenses" stroke="#ef4444" fillOpacity={1} fill="url(#colorExpenses)" strokeWidth={2} />
                </AreaChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-[250px] flex items-center justify-center text-slate-400">
                <p>No data available yet</p>
              </div>
            )}
          </motion.div>

          {/* Expense Breakdown */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.6 }}
            className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200"
          >
            <div className="mb-6">
              <h3 className="font-bold text-slate-900 mb-1">Expense Breakdown</h3>
              <p className="text-sm text-slate-500">By category</p>
            </div>
            {expenseByCategory.length > 0 ? (
              <ResponsiveContainer width="100%" height={250}>
                <PieChart>
                  <Pie
                    data={expenseByCategory}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                    outerRadius={80}
                    fill="#8884d8"
                    dataKey="value"
                  >
                    {expenseByCategory.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip
                    contentStyle={{
                      backgroundColor: 'white',
                      border: '1px solid #e2e8f0',
                      borderRadius: '8px',
                      fontSize: '12px'
                    }}
                  />
                </PieChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-[250px] flex items-center justify-center text-slate-400">
                <p>No expense data available</p>
              </div>
            )}
          </motion.div>
        </div>

        {/* Bottom Section */}
        <div className="grid lg:grid-cols-2 gap-6">
          {/* Top Selling Products */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.7 }}
            className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200"
          >
            <div className="mb-6">
              <h3 className="font-bold text-slate-900 mb-1">Top Selling Products</h3>
              <p className="text-sm text-slate-500">Best performers by quantity sold</p>
            </div>
            {topProducts.length > 0 ? (
              <ResponsiveContainer width="100%" height={250}>
                <BarChart data={topProducts} layout="vertical">
                  <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                  <XAxis type="number" stroke="#94a3b8" fontSize={12} />
                  <YAxis dataKey="name" type="category" stroke="#94a3b8" fontSize={12} width={100} />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: 'white',
                      border: '1px solid #e2e8f0',
                      borderRadius: '8px',
                      fontSize: '12px'
                    }}
                  />
                  <Bar dataKey="quantity" fill="#3b82f6" radius={[0, 8, 8, 0]} />
                </BarChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-[250px] flex items-center justify-center text-slate-400">
                <p>No sales data available</p>
              </div>
            )}
          </motion.div>

          {/* Quick Stats */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.8 }}
            className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200"
          >
            <div className="mb-6">
              <h3 className="font-bold text-slate-900 mb-1">Quick Stats</h3>
              <p className="text-sm text-slate-500">Business overview</p>
            </div>
            <div className="space-y-4">
              <div className="flex items-center justify-between p-4 bg-slate-50 rounded-xl">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-lg bg-blue-100 flex items-center justify-center">
                    <Users className="w-5 h-5 text-blue-600" />
                  </div>
                  <div>
                    <div className="text-sm text-slate-500">Total Customers</div>
                    <div className="text-xl font-bold text-slate-900">{customers.length}</div>
                  </div>
                </div>
              </div>

              <div className="flex items-center justify-between p-4 bg-slate-50 rounded-xl">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-lg bg-purple-100 flex items-center justify-center">
                    <Package className="w-5 h-5 text-purple-600" />
                  </div>
                  <div>
                    <div className="text-sm text-slate-500">Total Products</div>
                    <div className="text-xl font-bold text-slate-900">{products.length}</div>
                  </div>
                </div>
              </div>

              <div className="flex items-center justify-between p-4 bg-slate-50 rounded-xl">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-lg bg-emerald-100 flex items-center justify-center">
                    <ShoppingCart className="w-5 h-5 text-emerald-600" />
                  </div>
                  <div>
                    <div className="text-sm text-slate-500">Total Transactions</div>
                    <div className="text-xl font-bold text-slate-900">{sales.length}</div>
                  </div>
                </div>
              </div>

              <div className="flex items-center justify-between p-4 bg-slate-50 rounded-xl">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-lg bg-rose-100 flex items-center justify-center">
                    <Receipt className="w-5 h-5 text-rose-600" />
                  </div>
                  <div>
                    <div className="text-sm text-slate-500">Total Expenses</div>
                    <div className="text-xl font-bold text-slate-900">{expenses.length}</div>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </div>
  );
}
