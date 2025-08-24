<?php $__env->startSection('content'); ?>
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Expense</h1>
  <div class="bg-white rounded border p-4 space-y-2">
    <div><span class="text-gray-600">Category:</span> <span class="font-medium"><?php echo e(ucfirst($expense->category)); ?></span></div>
    <div><span class="text-gray-600">Amount:</span> <span class="font-medium"><?php echo e(number_format($expense->amount, 0)); ?></span></div>
    <div><span class="text-gray-600">Date:</span> <span class="font-medium"><?php echo e($expense->expense_date?->format('Y-m-d')); ?></span></div>
    <div><span class="text-gray-600">Notes:</span> <span class="font-medium"><?php echo e($expense->notes); ?></span></div>
  </div>
  <div class="mt-3">
    <a href="<?php echo e(route('expenses.edit.single', $expense)); ?>" class="px-3 py-2 bg-gray-100 rounded">Edit</a>
    <a href="<?php echo e(route('expenses.index')); ?>" class="px-3 py-2">Back</a>
  </div>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\Timo Kilale\Desktop\Kashier\resources\views/expenses/show.blade.php ENDPATH**/ ?>