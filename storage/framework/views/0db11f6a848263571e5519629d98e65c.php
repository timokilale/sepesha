

<?php $__env->startSection('content'); ?>
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Edit Sale</h1>

  <div class="bg-white rounded border p-4">
    <form method="POST" action="<?php echo e(route('sales.update.single', ['id' => $sale->id])); ?>" class="space-y-4">
      <?php echo csrf_field(); ?>
      <?php echo method_field('PUT'); ?>
      <div>
        <label class="block text-sm text-gray-700 mb-1">Purchase (item)</label>
        <select name="purchase_id" class="w-full border rounded px-3 py-2" required>
          <?php $__currentLoopData = $purchases; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $purchase): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
            <option value="<?php echo e($purchase->id); ?>" <?php echo e($sale->purchase_id == $purchase->id ? 'selected' : ''); ?>>
              <?php echo e($purchase->item_name); ?>

            </option>
          <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
        </select>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Selling price</label>
          <input type="number" step="0.01" name="selling_price" value="<?php echo e(old('selling_price', $sale->selling_price)); ?>" class="w-full border rounded px-3 py-2" required />
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Quantity</label>
          <input type="number" min="1" name="quantity_sold" value="<?php echo e(old('quantity_sold', $sale->quantity_sold)); ?>" class="w-full border rounded px-3 py-2" required />
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Sale date</label>
          <input type="date" name="sale_date" value="<?php echo e(old('sale_date', $sale->sale_date->format('Y-m-d'))); ?>" class="w-full border rounded px-3 py-2" required />
        </div>
      </div>
      <div>
        <label class="block text-sm text-gray-700 mb-1">Notes</label>
        <textarea name="notes" class="w-full border rounded px-3 py-2" rows="3"><?php echo e(old('notes', $sale->notes)); ?></textarea>
      </div>
      <div class="flex flex-col sm:flex-row gap-2 sm:gap-3">
        <button class="px-3 py-2 bg-green-600 text-white rounded">Update</button>
        <a href="<?php echo e(route('sales.index')); ?>" class="px-3 py-2 bg-gray-100 rounded text-center">Cancel</a>
      </div>
    </form>
  </div>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\Timo Kilale\Desktop\Kashier\resources\views/sales/edit.blade.php ENDPATH**/ ?>