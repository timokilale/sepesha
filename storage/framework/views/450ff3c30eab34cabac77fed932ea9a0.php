<?php $__env->startSection('content'); ?>
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  <div class="flex items-center justify-between mb-4">
    <h1 class="text-lg font-semibold text-gray-800">Charts</h1>
  </div>

  <form method="GET" action="<?php echo e(route('charts.index')); ?>" class="bg-white border rounded p-4 mb-4 grid grid-cols-1 sm:grid-cols-5 gap-3">
    <div class="sm:col-span-2">
      <label class="block text-xs text-gray-600 mb-1">Start date</label>
      <input type="month" name="start_date" value="<?php echo e(substr($range['start_date'],0,7)); ?>" class="w-full border rounded px-3 py-2" />
    </div>
    <div class="sm:col-span-2">
      <label class="block text-xs text-gray-600 mb-1">End date</label>
      <input type="month" name="end_date" value="<?php echo e(substr($range['end_date'],0,7)); ?>" class="w-full border rounded px-3 py-2" />
    </div>
    <div class="sm:col-span-1 flex items-end">
      <button class="w-full sm:w-auto px-4 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700">Apply</button>
    </div>
  </form>

  <section class="border rounded p-4 bg-white">
    <h2 class="text-sm font-medium text-gray-700 mb-3">Income vs Expenses</h2>
    <canvas id="rangeChart" height="160"></canvas>
  </section>
</div>

<script>
  const ctx = document.getElementById('rangeChart').getContext('2d');
  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: <?php echo json_encode($labels, 15, 512) ?>,
      datasets: [
        { label: 'Purchases', backgroundColor: '#ef4444', data: <?php echo json_encode($purchases, 15, 512) ?> },
        { label: 'Sales', backgroundColor: '#22c55e', data: <?php echo json_encode($sales, 15, 512) ?> }
      ]
    },
    options: { responsive: true, scales: { y: { beginAtZero: true } } }
  });
</script>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\MSA WIN10 G\Desktop\CascadeProjects\windsurf-project\resources\views/charts/index.blade.php ENDPATH**/ ?>