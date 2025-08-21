<?php $__env->startSection('content'); ?>
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-2xl font-bold text-gray-800 mb-4">Edit Purchase</h1>

  <div class="bg-white rounded shadow p-6">
    <form method="POST" action="<?php echo e(route('purchases.update', $purchase)); ?>" class="space-y-4">
      <?php echo csrf_field(); ?>
      <?php echo method_field('PUT'); ?>
      <div>
        <label class="block text-sm text-gray-700 mb-1">Item name</label>
        <input name="item_name" value="<?php echo e(old('item_name', $purchase->item_name)); ?>" class="w-full border rounded px-3 py-2" required />
      </div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Cost price</label>
          <input type="number" step="0.01" name="cost_price" value="<?php echo e(old('cost_price', $purchase->cost_price)); ?>" class="w-full border rounded px-3 py-2" required />
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Quantity</label>
          <input type="number" min="1" name="quantity" value="<?php echo e(old('quantity', $purchase->quantity)); ?>" class="w-full border rounded px-3 py-2" required />
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Purchase date</label>
          <input type="date" name="purchase_date" value="<?php echo e(old('purchase_date', $purchase->purchase_date->format('Y-m-d'))); ?>" class="w-full border rounded px-3 py-2" required />
        </div>
      </div>
      <div>
        <label class="block text-sm text-gray-700 mb-1">Description</label>
        <textarea name="description" class="w-full border rounded px-3 py-2" rows="3"><?php echo e(old('description', $purchase->description)); ?></textarea>
      </div>
      <div class="flex flex-col sm:flex-row gap-2 sm:gap-3">
        <button class="px-4 py-2 bg-indigo-600 text-white rounded">Update</button>
        <a href="<?php echo e(route('purchases.index')); ?>" class="px-4 py-2 bg-gray-100 rounded text-center">Cancel</a>
      </div>
    </form>
  </div>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\MSA WIN10 G\Desktop\CascadeProjects\windsurf-project\resources\views/purchases/edit.blade.php ENDPATH**/ ?>