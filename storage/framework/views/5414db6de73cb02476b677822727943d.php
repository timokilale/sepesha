<?php $__env->startSection('content'); ?>
<div class="max-w-3xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Product</h1>
  <div class="bg-white rounded border p-4 grid grid-cols-1 md:grid-cols-3 gap-4">
    <div>
      <div class="aspect-square bg-gray-50 flex items-center justify-center rounded border">
        <?php if($item->image_url): ?>
          <img src="<?php echo e($item->image_url); ?>" alt="<?php echo e($item->name); ?>" class="w-full h-full object-cover rounded" />
        <?php else: ?>
          <span class="text-gray-400 text-xs">No image</span>
        <?php endif; ?>
      </div>
    </div>
    <div class="md:col-span-2 space-y-2">
      <div><span class="text-gray-600">Name:</span> <span class="font-medium"><?php echo e($item->name); ?></span></div>
      <div><span class="text-gray-600">Category:</span> <span class="font-medium"><?php echo e($item->category ?? '—'); ?></span></div>
      <div><span class="text-gray-600">SKU:</span> <span class="font-medium"><?php echo e($item->sku ?? '—'); ?></span></div>
      <div><span class="text-gray-600">Unit:</span> <span class="font-medium"><?php echo e($item->unit_name ?? '—'); ?></span></div>
      <div><span class="text-gray-600">Carton size:</span> <span class="font-medium"><?php echo e($item->carton_size ?? '—'); ?></span></div>
      <div>
        <span class="text-gray-600">Profit/Loss:</span>
        <?php ($pl = $item->profit_loss ?? 0); ?>
        <span class="font-medium <?php echo e($pl >= 0 ? 'text-green-700' : 'text-red-700'); ?>">TZS <?php echo e(number_format($pl, 2)); ?></span>
      </div>
      <div><span class="text-gray-600">Notes:</span> <span class="font-medium"><?php echo e($item->notes ?? '—'); ?></span></div>

      <p class="text-xs text-gray-500 pt-1">Unit is the smallest piece you sell (e.g., bottle). Carton size is how many units are in one carton (e.g., 25 bottles in a carton). You can buy by cartons or by units.</p>

      <div class="pt-2 flex flex-wrap gap-2">
        <a href="<?php echo e(route('purchases.create', ['item_id' => $item->id])); ?>" class="px-3 py-2 bg-indigo-600 text-white rounded">Add Purchase</a>
        <a href="<?php echo e(route('sales.create', ['item_id' => $item->id])); ?>" class="px-3 py-2 bg-green-600 text-white rounded">Add Sale</a>
        <a href="<?php echo e(route('items.edit.single', ['id' => $item->id])); ?>" class="px-3 py-2 bg-gray-100 rounded">Edit</a>
        <a href="<?php echo e(route('items.index')); ?>" class="px-3 py-2">Back</a>
      </div>
    </div>
  </div>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\Timo Kilale\Desktop\Kashier\resources\views/items/show.blade.php ENDPATH**/ ?>