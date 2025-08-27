

<?php $__env->startSection('content'); ?>
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  <div class="flex flex-col sm:flex-row sm:items-center justify-between mb-3 gap-3">
    <h1 class="text-xl font-semibold text-gray-900">Purchases</h1>
    <a href="<?php echo e(route('purchases.create')); ?>" class="px-3 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700 text-center">Add Purchase</a>
  </div>

  <div class="bg-white rounded border overflow-hidden">
    <div class="overflow-x-auto">
      <table class="data-table min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Item</th>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Total</th>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase hidden sm:table-cell">Qty</th>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase hidden md:table-cell">Date</th>
            <th class="px-2 sm:px-4 py-2 text-right">Actions</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <?php $__empty_1 = true; $__currentLoopData = $purchases; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $p): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?>
          <tr>
            <td class="px-2 sm:px-4 py-2 text-gray-800">
              <div class="font-medium"><?php echo e($p->item_name); ?></div>
              <div class="text-sm text-gray-500 sm:hidden">
                Qty: <?php if($p->item && $p->item->uom_type === 'weight'): ?><?php echo e($p->item->formatBaseQuantity($p->quantity)); ?><?php else: ?><?php echo e($p->quantity); ?><?php endif; ?> • <?php echo e($p->purchase_date->format('M d, Y')); ?>

              </div>
            </td>
            <td class="px-2 sm:px-4 py-2">
              <div class="font-semibold">TZS <?php echo e(number_format($p->total_cost, 2)); ?></div>
              <div class="text-xs text-gray-500">
                <?php if($p->item && $p->item->uom_type === 'weight'): ?>
                  Per kg: TZS <?php echo e(number_format($p->cost_price * 1000, 1)); ?>

                <?php else: ?>
                  Chupa (derived): TZS <?php echo e(number_format($p->cost_price, 1)); ?>

                <?php endif; ?>
              </div>
            </td>
            <td class="px-2 sm:px-4 py-2 hidden sm:table-cell">
              <?php if($p->item && $p->item->uom_type === 'weight'): ?>
                <?php echo e($p->item->formatBaseQuantity($p->quantity)); ?>

              <?php else: ?>
                <?php echo e($p->quantity); ?>

              <?php endif; ?>
            </td>
            <td class="px-2 sm:px-4 py-2 hidden md:table-cell"><?php echo e($p->purchase_date->format('Y-m-d')); ?></td>
            <td class="px-2 sm:px-4 py-2 text-right">
              <div x-data="{ open: false }" class="flex flex-col items-end gap-1 justify-end">
                <button @click="open = true" class="text-gray-700 text-sm hover:text-gray-900">View</button>
                <a href="<?php echo e(route('purchases.edit.single', ['id' => $p->id])); ?>" class="text-indigo-600 text-sm hover:text-indigo-800">Edit</a>
                <form action="<?php echo e(route('purchases.destroy.single', ['id' => $p->id])); ?>" method="POST" class="inline">
                  <?php echo csrf_field(); ?>
                  <?php echo method_field('DELETE'); ?>
                  <button class="text-red-600 text-sm hover:text-red-800" onclick="return confirm('Delete this purchase?')">Delete</button>
                </form>

                <!-- Modal -->
                <div x-show="open" x-transition class="fixed inset-0 z-50 flex items-center justify-center">
                  <div class="absolute inset-0 bg-black/30" @click="open = false"></div>
                  <div class="relative bg-white w-full max-w-md rounded shadow-lg p-4 mx-4">
                    <div class="flex items-center justify-between mb-2">
                      <h3 class="text-lg font-semibold text-gray-900">Purchase Details</h3>
                      <button @click="open = false" class="text-gray-500 hover:text-gray-700">&times;</button>
                    </div>
                    <div class="space-y-2 text-sm text-gray-800">
                      <div class="flex justify-between"><span class="text-gray-500">Item</span><span class="font-medium"><?php echo e($p->item_name); ?></span></div>
                      <div class="flex justify-between">
                        <span class="text-gray-500">
                          <?php if($p->item && $p->item->uom_type === 'weight'): ?>
                            Per kg cost
                          <?php else: ?>
                            Unit cost (derived)
                          <?php endif; ?>
                        </span>
                        <span class="font-medium">
                          <?php if($p->item && $p->item->uom_type === 'weight'): ?>
                            TZS <?php echo e(number_format($p->cost_price * 1000, 1)); ?>

                          <?php else: ?>
                            TZS <?php echo e(number_format($p->cost_price, 1)); ?>

                          <?php endif; ?>
                        </span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-gray-500">Quantity</span>
                        <span class="font-medium">
                          <?php if($p->item && $p->item->uom_type === 'weight'): ?>
                            <?php echo e($p->item->formatBaseQuantity($p->quantity)); ?>

                          <?php else: ?>
                            <?php echo e($p->quantity); ?>

                          <?php endif; ?>
                        </span>
                      </div>
                      <div class="flex justify-between"><span class="text-gray-500">Total</span><span class="font-medium">TZS <?php echo e(number_format($p->total_cost,2)); ?></span></div>
                      <div class="flex justify-between"><span class="text-gray-500">Date</span><span class="font-medium"><?php echo e($p->purchase_date->format('Y-m-d')); ?></span></div>
                      <div>
                        <div class="text-gray-500">Description</div>
                        <p class="mt-1 whitespace-pre-line"><?php echo e($p->description ?? '—'); ?></p>
                      </div>
                    </div>
                    <div class="mt-4 flex justify-end">
                      <button @click="open = false" class="px-3 py-1.5 bg-gray-100 rounded hover:bg-gray-200">Close</button>
                    </div>
                  </div>
                </div>
              </div>
            </td>
          </tr>
          <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?>
          <tr><td colspan="5" class="px-2 sm:px-4 py-4 text-gray-500">No purchases yet.</td></tr>
          <?php endif; ?>
        </tbody>
      </table>
    </div>
    <div class="p-3"><?php echo e($purchases->links()); ?></div>
  </div>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\Timo Kilale\Desktop\Kashier\resources\views/purchases/index.blade.php ENDPATH**/ ?>