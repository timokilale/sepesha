<?php $__env->startSection('content'); ?>
<div class="max-w-4xl mx-auto px-4">
  <div class="flex items-center justify-between mb-1">
    <h1 class="text-xl font-semibold text-gray-900">Products</h1>
    <a href="<?php echo e(route('items.create')); ?>" class="px-3 py-2 bg-indigo-600 text-white rounded">Add Product</a>
  </div>
  <p class="text-xs text-gray-500 mb-3">SKU = product code. We create it for you.</p>
  <div class="bg-white rounded border">
    <table class="w-full text-sm">
      <thead>
        <tr class="text-left border-b">
          <th class="p-3">Name</th>
          <th class="p-3">SKU</th>
          <th class="p-3">Unit (e.g., bottle)</th>
          <th class="p-3"></th>
        </tr>
      </thead>
      <tbody>
        <?php $__empty_1 = true; $__currentLoopData = $items; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $item): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?>
        <tr class="border-b">
          <td class="p-3"><?php echo e($item->name); ?></td>
          <td class="p-3"><?php echo e($item->sku); ?></td>
          <td class="p-3"><?php echo e($item->unit_name); ?></td>
          <td class="p-3 text-right">
            <a class="text-indigo-600" href="<?php echo e(route('items.show.single', ['id' => $item->id])); ?>">View</a>
            <span class="mx-1">·</span>
            <a class="text-gray-700" href="<?php echo e(route('items.edit.single', ['id' => $item->id])); ?>">Edit</a>
            <span class="mx-1">·</span>
            <form action="<?php echo e(route('items.destroy.single', ['id' => $item->id])); ?>" method="POST" class="inline" onsubmit="return confirm('Delete this item?')">
              <?php echo csrf_field(); ?>
              <?php echo method_field('DELETE'); ?>
              <button class="text-red-600">Delete</button>
            </form>
          </td>
        </tr>
        <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?>
        <tr><td colspan="4" class="p-3 text-center text-gray-500">No items yet.</td></tr>
        <?php endif; ?>
      </tbody>
    </table>
  </div>
  <div class="mt-3"><?php echo e($items->links()); ?></div>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\Timo Kilale\Desktop\Kashier\resources\views/items/index.blade.php ENDPATH**/ ?>