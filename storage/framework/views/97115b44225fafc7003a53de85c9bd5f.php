

<?php $__env->startSection('content'); ?>
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  <!-- Quick actions on Home -->
  <div class="mb-4 flex items-center gap-2">
    <a href="<?php echo e(route('items.create')); ?>" class="px-3 py-2 text-sm rounded border bg-white hover:bg-gray-50">+ Add product</a>
    <!--<a href="<?php echo e(route('purchases.create')); ?>" class="px-3 py-2 text-sm rounded border bg-white hover:bg-gray-50">+ Buy stock</a>
    <a href="<?php echo e(route('sales.create')); ?>" class="px-3 py-2 text-sm rounded border bg-white hover:bg-gray-50">+ Sell stock</a>-->
  </div>

  <!-- Totals Row -->
  <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 sm:gap-6">
    <div class="border rounded p-4 bg-white">
      <div class="text-gray-500 text-xs uppercase tracking-wide">Money Spent (Buying)</div>
      <div class="text-xl font-semibold text-gray-900 mt-1">TZS <?php echo e(number_format($totalPurchases, 2)); ?></div>
    </div>
    <div class="border rounded p-4 bg-white">
      <div class="text-gray-500 text-xs uppercase tracking-wide">Money In (Selling)</div>
      <div class="text-xl font-semibold text-gray-900 mt-1">TZS <?php echo e(number_format($totalSales, 2)); ?></div>
    </div>
    <div class="border rounded p-4 bg-white">
      <div class="text-gray-500 text-xs uppercase tracking-wide">Profit (Money In − Expenses)</div>
      <div class="text-xl font-semibold mt-1 <?php echo e($totalProfit >= 0 ? 'text-green-600' : 'text-red-600'); ?>">TZS <?php echo e(number_format($totalProfit, 2)); ?></div>
    </div>
  </div>

  <!-- Products Grid -->
  <div class="mt-6">
    <h2 class="text-sm font-semibold text-gray-700 mb-1">Products</h2>
    <p class="text-xs text-gray-500 mb-3">Tap a product to buy or sell. Stock updates automatically.</p>
    <?php if($items->isEmpty()): ?>
      <div class="border rounded p-6 bg-white text-center text-gray-600">
        No products yet. Click "Add product" to create your first product.
      </div>
    <?php else: ?>
      <div class="grid gap-4" style="grid-template-columns: repeat(4, minmax(0, 1fr));">
        <?php $__currentLoopData = $items; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $item): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
          <a href="<?php echo e(route('items.show.single', ['id' => $item->id])); ?>" class="block border rounded overflow-hidden bg-white hover:shadow">
            <div class="aspect-square bg-gray-50 flex items-center justify-center">
              <?php if($item->image_url): ?>
                <img src="<?php echo e($item->image_url); ?>" alt="<?php echo e($item->name); ?>" class="w-full h-full object-cover" />
              <?php else: ?>
                <span class="text-gray-400 text-xs">No image</span>
              <?php endif; ?>
            </div>
            <div class="p-2">
              <div class="font-medium text-sm text-gray-900 truncate"><?php echo e($item->name); ?></div>
              <div class="text-xs text-gray-600">
                <?php ($unit = $item->unit_name ?: 'unit'); ?>
                Stock: <?php echo e($item->stock_remaining); ?> <?php echo e(\Illuminate\Support\Str::plural($unit, $item->stock_remaining)); ?>

              </div>
              <?php if($item->category): ?>
                <div class="text-[11px] text-gray-500"><?php echo e(ucfirst($item->category)); ?></div>
              <?php endif; ?>
              <div class="mt-1 text-xs font-medium <?php echo e(($item->profit_loss ?? 0) >= 0 ? 'text-green-700' : 'text-red-700'); ?>">
                Profit/Loss: TZS <?php echo e(number_format($item->profit_loss ?? 0, 2)); ?>

              </div>
              <div class="mt-2 flex gap-2">
                <a href="<?php echo e(route('purchases.create', ['item_id' => $item->id])); ?>" class="text-xs px-2 py-1 border rounded">Buy</a>
                <a href="<?php echo e(route('sales.create', ['item_id' => $item->id])); ?>" class="text-xs px-2 py-1 border rounded">Sell</a>
              </div>
            </div>
          </a>
        <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
      </div>
    <?php endif; ?>
  </div>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\Timo Kilale\Desktop\Kashier\resources\views/dashboard.blade.php ENDPATH**/ ?>