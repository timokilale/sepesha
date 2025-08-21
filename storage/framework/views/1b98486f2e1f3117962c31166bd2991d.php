<?php $__env->startSection('content'); ?>
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  <!-- Quick actions on Home -->
  <div class="mb-4 flex items-center gap-2">
    <a href="<?php echo e(route('purchases.create')); ?>" class="px-3 py-2 text-sm rounded border bg-white hover:bg-gray-50">+ Add purchase</a>
    <a href="<?php echo e(route('sales.create')); ?>" class="px-3 py-2 text-sm rounded border bg-white hover:bg-gray-50">+ Add sale</a>
  </div>

  <!-- Totals Row -->
  <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 sm:gap-6">
    <div class="border rounded p-4 bg-white">
      <div class="text-gray-500 text-xs uppercase tracking-wide">Total Purchases</div>
      <div class="text-xl font-semibold text-gray-900 mt-1">$<?php echo e(number_format($totalPurchases, 2)); ?></div>
    </div>
    <div class="border rounded p-4 bg-white">
      <div class="text-gray-500 text-xs uppercase tracking-wide">Total Sales</div>
      <div class="text-xl font-semibold text-gray-900 mt-1">$<?php echo e(number_format($totalSales, 2)); ?></div>
    </div>
    <div class="border rounded p-4 bg-white">
      <div class="text-gray-500 text-xs uppercase tracking-wide">Profit / Loss</div>
      <div class="text-xl font-semibold mt-1 <?php echo e($totalProfit >= 0 ? 'text-green-600' : 'text-red-600'); ?>">$<?php echo e(number_format($totalProfit, 2)); ?></div>
    </div>
  </div>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\MSA WIN10 G\Desktop\CascadeProjects\windsurf-project\resources\views/dashboard.blade.php ENDPATH**/ ?>