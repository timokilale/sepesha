<?php $__env->startSection('content'); ?>
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Add Expense</h1>
  <div class="bg-white rounded border p-4">
    <form method="POST" action="<?php echo e(route('expenses.store')); ?>" class="space-y-4">
      <?php echo csrf_field(); ?>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Category</label>
          <select name="category" class="w-full border rounded px-3 py-2" required>
            <option value="">-- Select --</option>
            <?php $__currentLoopData = ['water','electricity','waste','salaries','taxes','rent','other']; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $cat): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
              <option value="<?php echo e($cat); ?>" <?php if(old('category')===$cat): echo 'selected'; endif; ?>><?php echo e(ucfirst($cat)); ?></option>
            <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
          </select>
          <?php $__errorArgs = ['category'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Amount</label>
          <input type="number" min="0" step="0.01" name="amount" value="<?php echo e(old('amount')); ?>" class="w-full border rounded px-3 py-2" required />
          <?php $__errorArgs = ['amount'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Date</label>
          <input type="date" name="expense_date" value="<?php echo e(old('expense_date')); ?>" class="w-full border rounded px-3 py-2" required />
          <?php $__errorArgs = ['expense_date'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
        </div>
      </div>
      <div>
        <label class="block text-sm text-gray-700 mb-1">Notes</label>
        <textarea name="notes" class="w-full border rounded px-3 py-2" rows="3"><?php echo e(old('notes')); ?></textarea>
      </div>
      <div class="flex gap-2">
        <button class="px-3 py-2 bg-indigo-600 text-white rounded">Save</button>
        <a href="<?php echo e(route('expenses.index')); ?>" class="px-3 py-2 bg-gray-100 rounded">Cancel</a>
      </div>
    </form>
  </div>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\Timo Kilale\Desktop\Olomitu\resources\views/expenses/create.blade.php ENDPATH**/ ?>