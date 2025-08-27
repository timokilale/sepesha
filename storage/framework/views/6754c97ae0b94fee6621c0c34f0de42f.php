<?php $__env->startSection('content'); ?>
<div class="max-w-4xl mx-auto px-4">
  <div class="flex items-center justify-between mb-1">
    <h1 class="text-xl font-semibold text-gray-900">Products</h1>
    <div class="flex gap-2">
      <a href="<?php echo e(route('items.create')); ?>" class="px-3 py-2 bg-indigo-600 text-white rounded">Add Kinywaji</a>
      <a href="<?php echo e(route('meat.create')); ?>" class="px-3 py-2 bg-red-600 text-white rounded">Add Meat</a>
    </div>
  </div>
  <p class="text-xs text-gray-500 mb-3">SKU = product code. We create it for you.</p>

  <?php if($items->count() === 0): ?>
    <div class="bg-white rounded border p-6 text-center text-gray-500">No items yet.</div>
  <?php else: ?>
    <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
      <?php $__currentLoopData = $items; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $item): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
        <div class="bg-white rounded border p-3 flex gap-3 <?php echo e($item->is_active ? '' : 'opacity-50'); ?>">
          <?php if($item->image_url): ?>
            <img src="<?php echo e($item->image_url); ?>" alt="<?php echo e($item->name); ?>" class="h-16 w-16 object-cover rounded border" />
          <?php else: ?>
            <div class="h-16 w-16 rounded border flex items-center justify-center text-xs text-gray-500">No Image</div>
          <?php endif; ?>
          <div class="flex-1 min-w-0">
            <div class="flex items-start justify-between">
              <div class="font-medium text-gray-900 truncate flex items-center gap-2">
                <span><?php echo e($item->name); ?></span>
                <?php if (! ($item->is_active)): ?>
                  <span class="text-xs px-1.5 py-0.5 rounded bg-gray-200 text-gray-700">Inactive</span>
                <?php endif; ?>
              </div>
              <div class="text-xs text-gray-500 ml-2"><?php echo e($item->sku); ?></div>
            </div>
            <div class="text-xs text-gray-600 mt-0.5">
              <?php
                $uom = $item->uom_type ?? 'unit';
                $vol = $item->volume_ml;
                $volText = $vol ? ($vol >= 1000 && $vol % 1000 === 0 ? ($vol/1000).' L' : $vol.' ml') : null;
              ?>
              <span class="px-1.5 py-0.5 rounded bg-gray-100 text-gray-700"><?php echo e(ucfirst($uom)); ?></span>
              <?php if($uom !== 'weight'): ?>
                <?php if($volText): ?>
                  <span class="mx-1">·</span>
                  <span><?php echo e($volText); ?></span>
                <?php endif; ?>
                <?php if($item->unit_name): ?>
                  <span class="mx-1">·</span>
                  <span><?php echo e($item->unit_name); ?></span>
                <?php endif; ?>
                <?php if($item->carton_size): ?>
                  <span class="mx-1">·</span>
                  <span>Carton: <?php echo e($item->carton_size); ?></span>
                <?php endif; ?>
              <?php endif; ?>
            </div>
            <div class="mt-2 text-sm flex items-center gap-2 flex-wrap">
              <a class="text-indigo-600" href="<?php echo e(route('items.show.single', ['id' => $item->id])); ?>">View</a>
              <span class="mx-1">·</span>
              <a class="text-gray-700" href="<?php echo e(route('items.edit.single', ['id' => $item->id])); ?>">Edit</a>
              <span class="mx-1">·</span>
              <?php if($item->is_active): ?>
                <form action="<?php echo e(route('items.disable.single', ['id' => $item->id])); ?>" method="POST" class="inline" onsubmit="return confirm('Disable this product? It will be hidden and grayed out until enabled again.')">
                  <?php echo csrf_field(); ?>
                  <button class="text-gray-600">Disable</button>
                </form>
              <?php else: ?>
                <form action="<?php echo e(route('items.enable.single', ['id' => $item->id])); ?>" method="POST" class="inline">
                  <?php echo csrf_field(); ?>
                  <button class="text-green-700">Enable</button>
                </form>
              <?php endif; ?>
            </div>
          </div>
        </div>
      <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
    </div>
  <?php endif; ?>

  <div class="mt-3"><?php echo e($items->links()); ?></div>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\Timo Kilale\Desktop\Kashier\resources\views/items/index.blade.php ENDPATH**/ ?>