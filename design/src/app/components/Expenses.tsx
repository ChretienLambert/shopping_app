import { useState, useMemo } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { db, type Expense } from '../lib/db';
import { Plus, Receipt, X, Edit2, Trash2, Calendar, TrendingDown, DollarSign } from 'lucide-react';
import { useLiveQuery } from 'dexie-react-hooks';

const EXPENSE_CATEGORIES = [
  'Social Media',
  'Marketing',
  'Rent',
  'Utilities',
  'Supplies',
  'Equipment',
  'Transportation',
  'Wages',
  'Other',
];

const CATEGORY_COLORS: Record<string, string> = {
  'Social Media': 'from-blue-500 to-blue-600',
  'Marketing': 'from-purple-500 to-purple-600',
  'Rent': 'from-orange-500 to-orange-600',
  'Utilities': 'from-yellow-500 to-yellow-600',
  'Supplies': 'from-emerald-500 to-emerald-600',
  'Equipment': 'from-indigo-500 to-indigo-600',
  'Transportation': 'from-pink-500 to-pink-600',
  'Wages': 'from-rose-500 to-rose-600',
  'Other': 'from-slate-500 to-slate-600',
};

export function Expenses() {
  const expenses = useLiveQuery(() => db.expenses.orderBy('date').reverse().toArray()) || [];
  const [showModal, setShowModal] = useState(false);
  const [editingExpense, setEditingExpense] = useState<Expense | null>(null);
  const [formData, setFormData] = useState({
    category: '',
    description: '',
    amount: '',
  });

  const totalExpenses = expenses.reduce((sum, expense) => sum + expense.amount, 0);
  const avgExpense = expenses.length > 0 ? totalExpenses / expenses.length : 0;

  const todayExpenses = useMemo(() => {
    const today = new Date().toISOString().split('T')[0];
    return expenses.filter((e) => new Date(e.date).toISOString().split('T')[0] === today);
  }, [expenses]);

  const todayTotal = todayExpenses.reduce((sum, expense) => sum + expense.amount, 0);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const expenseData: Expense = {
      category: formData.category,
      description: formData.description,
      amount: parseFloat(formData.amount),
      date: new Date(),
    };

    if (editingExpense?.id) {
      await db.expenses.update(editingExpense.id, expenseData);
    } else {
      await db.expenses.add(expenseData);
    }

    setShowModal(false);
    setEditingExpense(null);
    setFormData({ category: '', description: '', amount: '' });
  };

  const handleEdit = (expense: Expense) => {
    setEditingExpense(expense);
    setFormData({
      category: expense.category,
      description: expense.description,
      amount: expense.amount.toString(),
    });
    setShowModal(true);
  };

  const handleDelete = async (id: number) => {
    if (confirm('Delete this expense?')) {
      await db.expenses.delete(id);
    }
  };

  const totalByCategory = expenses.reduce((acc, expense) => {
    acc[expense.category] = (acc[expense.category] || 0) + expense.amount;
    return acc;
  }, {} as Record<string, number>);

  return (
    <div className="h-full overflow-y-auto bg-slate-50">
      <div className="p-4 lg:p-8 space-y-6">
        {/* Stats Row */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-200">
            <div className="flex items-center gap-2 mb-2">
              <div className="w-10 h-10 rounded-xl bg-rose-50 flex items-center justify-center">
                <DollarSign className="w-5 h-5 text-rose-600" />
              </div>
            </div>
            <div className="text-2xl font-bold text-slate-900">${totalExpenses.toFixed(0)}</div>
            <div className="text-sm text-slate-500">Total Expenses</div>
          </div>

          <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-200">
            <div className="flex items-center gap-2 mb-2">
              <div className="w-10 h-10 rounded-xl bg-purple-50 flex items-center justify-center">
                <Receipt className="w-5 h-5 text-purple-600" />
              </div>
            </div>
            <div className="text-2xl font-bold text-slate-900">{expenses.length}</div>
            <div className="text-sm text-slate-500">Total Records</div>
          </div>

          <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-200">
            <div className="flex items-center gap-2 mb-2">
              <div className="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center">
                <TrendingDown className="w-5 h-5 text-blue-600" />
              </div>
            </div>
            <div className="text-2xl font-bold text-slate-900">${avgExpense.toFixed(0)}</div>
            <div className="text-sm text-slate-500">Avg. Expense</div>
          </div>

          <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-200">
            <div className="flex items-center gap-2 mb-2">
              <div className="w-10 h-10 rounded-xl bg-orange-50 flex items-center justify-center">
                <Calendar className="w-5 h-5 text-orange-600" />
              </div>
            </div>
            <div className="text-2xl font-bold text-slate-900">${todayTotal.toFixed(0)}</div>
            <div className="text-sm text-slate-500">Today's Expenses</div>
          </div>
        </div>

        {/* Category Breakdown */}
        {Object.keys(totalByCategory).length > 0 && (
          <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200">
            <h3 className="font-bold text-slate-900 mb-4">By Category</h3>
            <div className="grid grid-cols-2 lg:grid-cols-3 gap-3">
              {Object.entries(totalByCategory)
                .sort((a, b) => b[1] - a[1])
                .map(([category, total], index) => (
                  <motion.div
                    key={category}
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: index * 0.05 }}
                    className={`bg-gradient-to-br ${CATEGORY_COLORS[category]} rounded-xl p-4 text-white shadow-lg`}
                  >
                    <div className="text-sm opacity-90 mb-1">{category}</div>
                    <div className="text-2xl font-bold">${total.toFixed(0)}</div>
                  </motion.div>
                ))}
            </div>
          </div>
        )}

        {/* Expenses List */}
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200">
          <h3 className="font-bold text-slate-900 mb-4">All Expenses</h3>
          {expenses.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-16 text-center">
              <div className="w-16 h-16 rounded-full bg-slate-100 flex items-center justify-center mb-4">
                <Receipt className="w-8 h-8 text-slate-400" />
              </div>
              <h3 className="font-semibold text-slate-900 mb-1">No expenses yet</h3>
              <p className="text-sm text-slate-500">Track your first expense to get started</p>
            </div>
          ) : (
            <div className="space-y-3">
              {expenses.map((expense, index) => (
                <motion.div
                  key={expense.id}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: index * 0.03 }}
                  className="flex items-start justify-between p-4 bg-slate-50 rounded-xl hover:bg-slate-100 transition-colors"
                >
                  <div className="flex items-start gap-4 flex-1">
                    <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${CATEGORY_COLORS[expense.category]} flex items-center justify-center text-white text-xs font-bold shadow-lg flex-shrink-0`}>
                      {expense.category.split(' ').map(w => w[0]).join('')}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <span className="text-xs font-semibold text-blue-600 bg-blue-50 px-2 py-1 rounded-lg">
                          {expense.category}
                        </span>
                      </div>
                      <h4 className="font-semibold text-slate-900 mb-1">{expense.description}</h4>
                      <div className="flex items-center gap-2 text-xs text-slate-400">
                        <Calendar className="w-3 h-3" />
                        <span>{new Date(expense.date).toLocaleDateString()}</span>
                        <span className="mx-1">•</span>
                        <span>{new Date(expense.date).toLocaleTimeString()}</span>
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <div className="text-right">
                      <div className="text-xl font-bold text-rose-600">-${expense.amount.toFixed(2)}</div>
                    </div>
                    <div className="flex gap-2">
                      <button
                        onClick={() => handleEdit(expense)}
                        className="w-9 h-9 rounded-lg bg-blue-50 hover:bg-blue-100 flex items-center justify-center transition-colors"
                      >
                        <Edit2 className="w-4 h-4 text-blue-600" />
                      </button>
                      <button
                        onClick={() => expense.id && handleDelete(expense.id)}
                        className="w-9 h-9 rounded-lg bg-rose-50 hover:bg-rose-100 flex items-center justify-center transition-colors"
                      >
                        <Trash2 className="w-4 h-4 text-rose-600" />
                      </button>
                    </div>
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
          setEditingExpense(null);
          setFormData({ category: '', description: '', amount: '' });
          setShowModal(true);
        }}
        className="fixed bottom-6 right-6 lg:bottom-8 lg:right-8 w-14 h-14 rounded-full bg-gradient-to-r from-rose-600 to-rose-500 text-white shadow-xl hover:shadow-2xl hover:scale-110 transition-all flex items-center justify-center"
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
                <h2 className="font-bold text-slate-900">
                  {editingExpense ? 'Edit Expense' : 'Add Expense'}
                </h2>
                <button
                  onClick={() => setShowModal(false)}
                  className="w-10 h-10 rounded-xl bg-slate-100 hover:bg-slate-200 flex items-center justify-center transition-colors"
                >
                  <X className="w-5 h-5 text-slate-600" />
                </button>
              </div>

              <form onSubmit={handleSubmit} className="p-6 space-y-5">
                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-2">Category</label>
                  <select
                    required
                    value={formData.category}
                    onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border border-slate-300 focus:outline-none focus:ring-2 focus:ring-rose-500 bg-white"
                  >
                    <option value="">Select a category</option>
                    {EXPENSE_CATEGORIES.map((category) => (
                      <option key={category} value={category}>
                        {category}
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-2">Description</label>
                  <textarea
                    required
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border border-slate-300 focus:outline-none focus:ring-2 focus:ring-rose-500"
                    placeholder="Enter description"
                    rows={3}
                  />
                </div>

                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-2">Amount ($)</label>
                  <input
                    type="number"
                    step="0.01"
                    required
                    value={formData.amount}
                    onChange={(e) => setFormData({ ...formData, amount: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border border-slate-300 focus:outline-none focus:ring-2 focus:ring-rose-500"
                    placeholder="0.00"
                  />
                </div>

                <button
                  type="submit"
                  className="w-full bg-gradient-to-r from-rose-600 to-rose-500 text-white py-3 rounded-xl font-semibold hover:shadow-lg hover:shadow-rose-500/30 transition-all"
                >
                  {editingExpense ? 'Update Expense' : 'Add Expense'}
                </button>
              </form>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
