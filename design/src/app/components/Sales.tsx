import { useState, useMemo } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { db, type Sale } from '../lib/db';
import { Plus, ShoppingCart, X, Calendar, TrendingUp, DollarSign } from 'lucide-react';
import { useLiveQuery } from 'dexie-react-hooks';

export function Sales() {
  const sales = useLiveQuery(() => db.sales.orderBy('date').reverse().toArray()) || [];
  const products = useLiveQuery(() => db.products.toArray()) || [];
  const customers = useLiveQuery(() => db.customers.toArray()) || [];
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    productId: '',
    customerId: '',
    quantity: '1',
  });

  const totalRevenue = sales.reduce((sum, sale) => sum + sale.totalAmount, 0);
  const avgSaleValue = sales.length > 0 ? totalRevenue / sales.length : 0;

  const todaySales = useMemo(() => {
    const today = new Date().toISOString().split('T')[0];
    return sales.filter((s) => new Date(s.date).toISOString().split('T')[0] === today);
  }, [sales]);

  const todayRevenue = todaySales.reduce((sum, sale) => sum + sale.totalAmount, 0);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const product = products.find((p) => p.id === parseInt(formData.productId));
    if (!product) return;

    const quantity = parseInt(formData.quantity);
    if (quantity > product.stock) {
      alert('Insufficient stock!');
      return;
    }

    const saleData: Sale = {
      productId: parseInt(formData.productId),
      customerId: formData.customerId ? parseInt(formData.customerId) : undefined,
      quantity,
      totalAmount: product.price * quantity,
      date: new Date(),
    };

    await db.sales.add(saleData);
    await db.products.update(product.id!, { stock: product.stock - quantity });

    setShowModal(false);
    setFormData({ productId: '', customerId: '', quantity: '1' });
  };

  const getProductName = (productId: number) => {
    return products.find((p) => p.id === productId)?.name || 'Unknown Product';
  };

  const getCustomerName = (customerId?: number) => {
    if (!customerId) return 'Walk-in Customer';
    return customers.find((c) => c.id === customerId)?.name || 'Unknown Customer';
  };

  return (
    <div className="h-full overflow-y-auto bg-slate-50">
      <div className="p-4 lg:p-8 space-y-6">
        {/* Stats Row */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-200">
            <div className="flex items-center gap-2 mb-2">
              <div className="w-10 h-10 rounded-xl bg-emerald-50 flex items-center justify-center">
                <DollarSign className="w-5 h-5 text-emerald-600" />
              </div>
            </div>
            <div className="text-2xl font-bold text-slate-900">${totalRevenue.toFixed(0)}</div>
            <div className="text-sm text-slate-500">Total Revenue</div>
          </div>

          <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-200">
            <div className="flex items-center gap-2 mb-2">
              <div className="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center">
                <ShoppingCart className="w-5 h-5 text-blue-600" />
              </div>
            </div>
            <div className="text-2xl font-bold text-slate-900">{sales.length}</div>
            <div className="text-sm text-slate-500">Total Sales</div>
          </div>

          <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-200">
            <div className="flex items-center gap-2 mb-2">
              <div className="w-10 h-10 rounded-xl bg-purple-50 flex items-center justify-center">
                <TrendingUp className="w-5 h-5 text-purple-600" />
              </div>
            </div>
            <div className="text-2xl font-bold text-slate-900">${avgSaleValue.toFixed(0)}</div>
            <div className="text-sm text-slate-500">Avg. Sale Value</div>
          </div>

          <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-200">
            <div className="flex items-center gap-2 mb-2">
              <div className="w-10 h-10 rounded-xl bg-orange-50 flex items-center justify-center">
                <Calendar className="w-5 h-5 text-orange-600" />
              </div>
            </div>
            <div className="text-2xl font-bold text-slate-900">${todayRevenue.toFixed(0)}</div>
            <div className="text-sm text-slate-500">Today's Revenue</div>
          </div>
        </div>

        {/* Sales List */}
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200">
          <h3 className="font-bold text-slate-900 mb-4">Recent Sales</h3>
          {sales.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-16 text-center">
              <div className="w-16 h-16 rounded-full bg-slate-100 flex items-center justify-center mb-4">
                <ShoppingCart className="w-8 h-8 text-slate-400" />
              </div>
              <h3 className="font-semibold text-slate-900 mb-1">No sales yet</h3>
              <p className="text-sm text-slate-500">Record your first sale to get started</p>
            </div>
          ) : (
            <div className="space-y-3">
              {sales.map((sale, index) => (
                <motion.div
                  key={sale.id}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: index * 0.03 }}
                  className="flex items-center justify-between p-4 bg-slate-50 rounded-xl hover:bg-slate-100 transition-colors"
                >
                  <div className="flex items-center gap-4 flex-1">
                    <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-emerald-500 to-emerald-600 flex items-center justify-center text-white font-bold shadow-lg">
                      {sale.quantity}
                    </div>
                    <div className="flex-1 min-w-0">
                      <h4 className="font-semibold text-slate-900 truncate">{getProductName(sale.productId)}</h4>
                      <p className="text-sm text-slate-500 truncate">{getCustomerName(sale.customerId)}</p>
                      <div className="flex items-center gap-2 text-xs text-slate-400 mt-1">
                        <Calendar className="w-3 h-3" />
                        <span>{new Date(sale.date).toLocaleDateString()}</span>
                        <span className="mx-1">•</span>
                        <span>{new Date(sale.date).toLocaleTimeString()}</span>
                      </div>
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="text-xl font-bold text-emerald-600">+${sale.totalAmount.toFixed(2)}</div>
                    <div className="text-xs text-slate-500">${(sale.totalAmount / sale.quantity).toFixed(2)} each</div>
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Floating Action Button */}
      <button
        onClick={() => {
          setFormData({ productId: '', customerId: '', quantity: '1' });
          setShowModal(true);
        }}
        className="fixed bottom-6 right-6 lg:bottom-8 lg:right-8 w-14 h-14 rounded-full bg-gradient-to-r from-emerald-600 to-emerald-500 text-white shadow-xl hover:shadow-2xl hover:scale-110 transition-all flex items-center justify-center"
      >
        <Plus className="w-6 h-6" />
      </button>

      {/* Modal */}
      <AnimatePresence>
        {showModal && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-black/50 z-50 flex items-end sm:items-center justify-center p-4"
            onClick={() => setShowModal(false)}
          >
            <motion.div
              initial={{ y: '100%', opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              exit={{ y: '100%', opacity: 0 }}
              transition={{ type: 'spring', damping: 25, stiffness: 300 }}
              onClick={(e) => e.stopPropagation()}
              className="bg-white w-full max-w-lg sm:rounded-2xl rounded-t-3xl max-h-[90vh] overflow-y-auto"
            >
              <div className="sticky top-0 bg-white border-b border-slate-200 p-6 flex items-center justify-between">
                <h2 className="font-bold text-slate-900">Record Sale</h2>
                <button
                  onClick={() => setShowModal(false)}
                  className="w-10 h-10 rounded-xl bg-slate-100 hover:bg-slate-200 flex items-center justify-center transition-colors"
                >
                  <X className="w-5 h-5 text-slate-600" />
                </button>
              </div>

              <form onSubmit={handleSubmit} className="p-6 space-y-5">
                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-2">Product</label>
                  <select
                    required
                    value={formData.productId}
                    onChange={(e) => setFormData({ ...formData, productId: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border border-slate-300 focus:outline-none focus:ring-2 focus:ring-emerald-500 bg-white"
                  >
                    <option value="">Select a product</option>
                    {products.map((product) => (
                      <option key={product.id} value={product.id}>
                        {product.name} - ${product.price} (Stock: {product.stock})
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-2">Customer (Optional)</label>
                  <select
                    value={formData.customerId}
                    onChange={(e) => setFormData({ ...formData, customerId: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border border-slate-300 focus:outline-none focus:ring-2 focus:ring-emerald-500 bg-white"
                  >
                    <option value="">Walk-in Customer</option>
                    {customers.map((customer) => (
                      <option key={customer.id} value={customer.id}>
                        {customer.name}
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-2">Quantity</label>
                  <input
                    type="number"
                    min="1"
                    required
                    value={formData.quantity}
                    onChange={(e) => setFormData({ ...formData, quantity: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border border-slate-300 focus:outline-none focus:ring-2 focus:ring-emerald-500"
                    placeholder="Enter quantity"
                  />
                </div>

                {formData.productId && (
                  <div className="bg-gradient-to-br from-emerald-50 to-emerald-100 rounded-xl p-5">
                    <div className="flex justify-between items-center">
                      <span className="text-sm font-medium text-slate-600">Total Amount</span>
                      <span className="text-2xl font-bold text-emerald-600">
                        $
                        {(
                          (products.find((p) => p.id === parseInt(formData.productId))?.price || 0) *
                          parseInt(formData.quantity || '1')
                        ).toFixed(2)}
                      </span>
                    </div>
                  </div>
                )}

                <button
                  type="submit"
                  className="w-full bg-gradient-to-r from-emerald-600 to-emerald-500 text-white py-3 rounded-xl font-semibold hover:shadow-lg hover:shadow-emerald-500/30 transition-all"
                >
                  Record Sale
                </button>
              </form>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
