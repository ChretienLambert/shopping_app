import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { db, type Product } from '../lib/db';
import { Plus, Package, Camera, X, Edit2, Trash2, Search, DollarSign } from 'lucide-react';
import { useLiveQuery } from 'dexie-react-hooks';

export function Products() {
  const products = useLiveQuery(() => db.products.orderBy('createdAt').reverse().toArray()) || [];
  const [showModal, setShowModal] = useState(false);
  const [editingProduct, setEditingProduct] = useState<Product | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    price: '',
    stock: '',
    photo: '',
  });

  const filteredProducts = products.filter((product) =>
    product.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const productData: Product = {
      name: formData.name,
      description: formData.description,
      price: parseFloat(formData.price),
      stock: parseInt(formData.stock),
      photo: formData.photo,
      createdAt: new Date(),
    };

    if (editingProduct?.id) {
      await db.products.update(editingProduct.id, productData);
    } else {
      await db.products.add(productData);
    }

    setShowModal(false);
    setEditingProduct(null);
    setFormData({ name: '', description: '', price: '', stock: '', photo: '' });
  };

  const handleEdit = (product: Product) => {
    setEditingProduct(product);
    setFormData({
      name: product.name,
      description: product.description,
      price: product.price.toString(),
      stock: product.stock.toString(),
      photo: product.photo || '',
    });
    setShowModal(true);
  };

  const handleDelete = async (id: number) => {
    if (confirm('Delete this product?')) {
      await db.products.delete(id);
    }
  };

  const handlePhotoCapture = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setFormData({ ...formData, photo: reader.result as string });
      };
      reader.readAsDataURL(file);
    }
  };

  const totalValue = products.reduce((sum, p) => sum + p.price * p.stock, 0);

  return (
    <div className="h-full overflow-y-auto bg-slate-50">
      <div className="p-4 lg:p-8 space-y-6">
        {/* Stats Row */}
        <div className="grid grid-cols-2 lg:grid-cols-3 gap-4">
          <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-200">
            <div className="text-sm text-slate-500 mb-1">Total Products</div>
            <div className="text-2xl font-bold text-slate-900">{products.length}</div>
          </div>
          <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-200">
            <div className="text-sm text-slate-500 mb-1">Total Stock</div>
            <div className="text-2xl font-bold text-slate-900">
              {products.reduce((sum, p) => sum + p.stock, 0)}
            </div>
          </div>
          <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-200 col-span-2 lg:col-span-1">
            <div className="text-sm text-slate-500 mb-1">Inventory Value</div>
            <div className="text-2xl font-bold text-slate-900">${totalValue.toFixed(2)}</div>
          </div>
        </div>

        {/* Search Bar */}
        <div className="relative">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
          <input
            type="text"
            placeholder="Search products..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-12 pr-4 py-3 bg-white rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        {/* Products Grid */}
        {filteredProducts.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-16 text-center bg-white rounded-2xl border border-slate-200">
            <div className="w-16 h-16 rounded-full bg-slate-100 flex items-center justify-center mb-4">
              <Package className="w-8 h-8 text-slate-400" />
            </div>
            <h3 className="font-semibold text-slate-900 mb-1">No products found</h3>
            <p className="text-sm text-slate-500">
              {searchQuery ? 'Try a different search term' : 'Add your first product to get started'}
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-4">
            {filteredProducts.map((product, index) => (
              <motion.div
                key={product.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.05 }}
                className="bg-white rounded-2xl overflow-hidden shadow-sm border border-slate-200 hover:shadow-lg transition-all"
              >
                {product.photo ? (
                  <img
                    src={product.photo}
                    alt={product.name}
                    className="w-full h-48 object-cover"
                  />
                ) : (
                  <div className="w-full h-48 bg-gradient-to-br from-slate-100 to-slate-200 flex items-center justify-center">
                    <Package className="w-16 h-16 text-slate-400" />
                  </div>
                )}
                <div className="p-5">
                  <div className="mb-3">
                    <h3 className="font-bold text-slate-900 mb-1 truncate">{product.name}</h3>
                    <p className="text-sm text-slate-500 line-clamp-2">{product.description}</p>
                  </div>
                  <div className="flex items-center gap-4 mb-4">
                    <div className="flex items-center gap-1 text-blue-600">
                      <DollarSign className="w-4 h-4" />
                      <span className="font-bold">{product.price}</span>
                    </div>
                    <div className="text-sm">
                      <span className="text-slate-500">Stock:</span>
                      <span className={`ml-1 font-semibold ${product.stock < 10 ? 'text-rose-600' : 'text-slate-900'}`}>
                        {product.stock}
                      </span>
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <button
                      onClick={() => handleEdit(product)}
                      className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-blue-50 text-blue-600 rounded-xl hover:bg-blue-100 transition-colors"
                    >
                      <Edit2 className="w-4 h-4" />
                      <span className="text-sm font-medium">Edit</span>
                    </button>
                    <button
                      onClick={() => product.id && handleDelete(product.id)}
                      className="px-4 py-2 bg-rose-50 text-rose-600 rounded-xl hover:bg-rose-100 transition-colors"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        )}
      </div>

      {/* Floating Action Button */}
      <button
        onClick={() => {
          setEditingProduct(null);
          setFormData({ name: '', description: '', price: '', stock: '', photo: '' });
          setShowModal(true);
        }}
        className="fixed bottom-6 right-6 lg:bottom-8 lg:right-8 w-14 h-14 rounded-full bg-gradient-to-r from-blue-600 to-blue-500 text-white shadow-xl hover:shadow-2xl hover:scale-110 transition-all flex items-center justify-center"
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
                  {editingProduct ? 'Edit Product' : 'Add Product'}
                </h2>
                <button
                  onClick={() => setShowModal(false)}
                  className="w-10 h-10 rounded-xl bg-slate-100 hover:bg-slate-200 flex items-center justify-center transition-colors"
                >
                  <X className="w-5 h-5 text-slate-600" />
                </button>
              </div>

              <form onSubmit={handleSubmit} className="p-6 space-y-6">
                {/* Photo Upload */}
                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-3">Product Photo</label>
                  {formData.photo ? (
                    <div className="relative">
                      <img src={formData.photo} alt="Product" className="w-full h-56 object-cover rounded-2xl" />
                      <button
                        type="button"
                        onClick={() => setFormData({ ...formData, photo: '' })}
                        className="absolute top-3 right-3 w-10 h-10 rounded-full bg-white shadow-lg flex items-center justify-center hover:bg-slate-50 transition-colors"
                      >
                        <X className="w-5 h-5 text-slate-600" />
                      </button>
                    </div>
                  ) : (
                    <label className="flex flex-col items-center justify-center w-full h-56 border-2 border-dashed border-slate-300 rounded-2xl cursor-pointer bg-slate-50 hover:bg-slate-100 transition-colors">
                      <Camera className="w-10 h-10 text-slate-400 mb-3" />
                      <span className="text-sm font-medium text-slate-600">Click to add photo</span>
                      <span className="text-xs text-slate-400 mt-1">or use camera</span>
                      <input
                        type="file"
                        accept="image/*"
                        capture="environment"
                        onChange={handlePhotoCapture}
                        className="hidden"
                      />
                    </label>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-2">Product Name</label>
                  <input
                    type="text"
                    required
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border border-slate-300 focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Enter product name"
                  />
                </div>

                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-2">Description</label>
                  <textarea
                    required
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border border-slate-300 focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Enter description"
                    rows={3}
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-semibold text-slate-700 mb-2">Price ($)</label>
                    <input
                      type="number"
                      step="0.01"
                      required
                      value={formData.price}
                      onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                      className="w-full px-4 py-3 rounded-xl border border-slate-300 focus:outline-none focus:ring-2 focus:ring-blue-500"
                      placeholder="0.00"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-semibold text-slate-700 mb-2">Stock</label>
                    <input
                      type="number"
                      required
                      value={formData.stock}
                      onChange={(e) => setFormData({ ...formData, stock: e.target.value })}
                      className="w-full px-4 py-3 rounded-xl border border-slate-300 focus:outline-none focus:ring-2 focus:ring-blue-500"
                      placeholder="0"
                    />
                  </div>
                </div>

                <button
                  type="submit"
                  className="w-full bg-gradient-to-r from-blue-600 to-blue-500 text-white py-3 rounded-xl font-semibold hover:shadow-lg hover:shadow-blue-500/30 transition-all"
                >
                  {editingProduct ? 'Update Product' : 'Add Product'}
                </button>
              </form>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
