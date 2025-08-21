<?php $__env->startSection('content'); ?>
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6 mb-6">
    <div class="bg-white overflow-hidden shadow-sm rounded-lg p-6">
      <div class="text-gray-500 text-sm">Total Purchases</div>
      <div class="text-2xl font-bold text-gray-800 mt-2">$<?php echo e(number_format($totalPurchases, 2)); ?></div>
    </div>
    <div class="bg-white overflow-hidden shadow-sm rounded-lg p-6">
      <div class="text-gray-500 text-sm">Total Sales</div>
      <div class="text-2xl font-bold text-gray-800 mt-2">$<?php echo e(number_format($totalSales, 2)); ?></div>
    </div>
    <div class="bg-white overflow-hidden shadow-sm rounded-lg p-6">
      <div class="text-gray-500 text-sm">Profit / Loss</div>
      <div class="text-2xl font-bold mt-2 <?php echo e($totalProfit >= 0 ? 'text-green-600' : 'text-red-600'); ?>">
        $<?php echo e(number_format($totalProfit, 2)); ?>

      </div>
    </div>
  </div>

  <div class="grid grid-cols-1 lg:grid-cols-3 gap-4 lg:gap-6">
    <div class="bg-white overflow-hidden shadow-sm rounded-lg p-6 lg:col-span-2">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-lg font-semibold text-gray-800">Income vs Expenses (Last 6 months)</h2>
      </div>
      <canvas id="incomeExpenseChart" height="110"></canvas>
    </div>

    <div class="bg-white overflow-hidden shadow-sm rounded-lg p-6">
      <h2 class="text-lg font-semibold text-gray-800 mb-4">Quick Actions</h2>
      <div class="space-y-3">
        <a href="<?php echo e(route('purchases.create')); ?>" class="w-full inline-flex items-center justify-center px-4 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700">Add Purchase</a>
        <a href="<?php echo e(route('sales.create')); ?>" class="w-full inline-flex items-center justify-center px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700">Add Sale</a>
      </div>
    </div>
  </div>

  <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 lg:gap-6 mt-6">
    <div class="bg-white overflow-hidden shadow-sm rounded-lg p-6">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-lg font-semibold text-gray-800">Recent Purchases</h2>
      </div>
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Item</th>
              <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Cost</th>
              <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase hidden sm:table-cell">Qty</th>
              <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase hidden md:table-cell">Date</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <?php $__empty_1 = true; $__currentLoopData = $recentPurchases; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $p): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?>
            <tr>
              <td class="px-2 sm:px-4 py-2 text-gray-800">
                <div class="font-medium"><?php echo e($p->item_name); ?></div>
                <div class="text-sm text-gray-500 sm:hidden">Qty: <?php echo e($p->quantity); ?> • <?php echo e($p->purchase_date->format('M d')); ?></div>
              </td>
              <td class="px-2 sm:px-4 py-2 font-medium">$<?php echo e(number_format($p->cost_price, 2)); ?></td>
              <td class="px-2 sm:px-4 py-2 hidden sm:table-cell"><?php echo e($p->quantity); ?></td>
              <td class="px-2 sm:px-4 py-2 hidden md:table-cell"><?php echo e($p->purchase_date->format('Y-m-d')); ?></td>
            </tr>
            <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?>
            <tr><td colspan="4" class="px-2 sm:px-4 py-3 text-gray-500">No purchases yet.</td></tr>
            <?php endif; ?>
          </tbody>
        </table>
      </div>
    </div>

    <div class="bg-white overflow-hidden shadow-sm rounded-lg p-6">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-lg font-semibold text-gray-800">Recent Sales</h2>
      </div>
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Item</th>
              <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Price</th>
              <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase hidden sm:table-cell">Qty</th>
              <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase hidden md:table-cell">Date</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <?php $__empty_1 = true; $__currentLoopData = $recentSales; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $s): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?>
            <tr>
              <td class="px-2 sm:px-4 py-2 text-gray-800">
                <div class="font-medium"><?php echo e($s->purchase->item_name); ?></div>
                <div class="text-sm text-gray-500 sm:hidden">Qty: <?php echo e($s->quantity_sold); ?> • <?php echo e($s->sale_date->format('M d')); ?></div>
              </td>
              <td class="px-2 sm:px-4 py-2 font-medium">$<?php echo e(number_format($s->selling_price, 2)); ?></td>
              <td class="px-2 sm:px-4 py-2 hidden sm:table-cell"><?php echo e($s->quantity_sold); ?></td>
              <td class="px-2 sm:px-4 py-2 hidden md:table-cell"><?php echo e($s->sale_date->format('Y-m-d')); ?></td>
            </tr>
            <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?>
            <tr><td colspan="4" class="px-2 sm:px-4 py-3 text-gray-500">No sales yet.</td></tr>
            <?php endif; ?>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>

<script>
  const ctx = document.getElementById('incomeExpenseChart').getContext('2d');
  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: <?php echo json_encode($monthlyData['months'], 15, 512) ?>,
      datasets: [
        { label: 'Purchases', backgroundColor: '#ef4444', data: <?php echo json_encode($monthlyData['purchases'], 15, 512) ?> },
        { label: 'Sales', backgroundColor: '#22c55e', data: <?php echo json_encode($monthlyData['sales'], 15, 512) ?> }
      ]
    },
    options: {
      responsive: true,
      scales: { y: { beginAtZero: true } }
    }
  });
</script>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\MSA WIN10 G\Desktop\CascadeProjects\windsurf-project\resources\views/dashboard.blade.php ENDPATH**/ ?>