<?php $__env->startSection('content'); ?>
<div class="max-w-2xl mx-auto px-4" x-data="{ mode: 'simple' }">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Sell Stock</h1>

  <div class="bg-white rounded border p-4">
    <form method="POST" action="<?php echo e(route('sales.store')); ?>" class="space-y-4">
      <?php echo csrf_field(); ?>
      <div class="flex items-center gap-2 text-sm">
        <button type="button" @click="mode='simple'" :class="mode==='simple' ? 'bg-indigo-600 text-white' : 'bg-gray-100 text-gray-700'" class="px-3 py-1.5 rounded">Simple</button>
        <button type="button" @click="mode='advanced'" :class="mode==='advanced' ? 'bg-indigo-600 text-white' : 'bg-gray-100 text-gray-700'" class="px-3 py-1.5 rounded">Advanced</button>
      </div>
      <div>
        <label class="block text-sm text-gray-700 mb-1">Pick stock to sell (remaining shown in bottles)</label>
        <select name="purchase_id" class="w-full border rounded px-3 py-2">
          <?php $__currentLoopData = $purchases; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $purchase): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
            <option value="<?php echo e($purchase->id); ?>" <?php if(old('purchase_id', request('purchase_id'))==$purchase->id): echo 'selected'; endif; ?>>
              <?php echo e($purchase->item?->name ?? $purchase->item_name); ?> — left: <?php echo e($purchase->remaining_quantity); ?> <?php if($purchase->item?->unit_name): ?><?php echo e($purchase->item?->unit_name); ?><?php endif; ?> @ TZS <?php echo e(number_format($purchase->unit_cost, 2)); ?>

            </option>
          <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
        </select>
        <?php $__errorArgs = ['purchase_id'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
        <p class="text-xs text-gray-500 mt-1">Tip: Choose the batch you want to sell from. Remaining bottles help you avoid overselling.</p>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Selling price</label>
          <input type="number" step="0.01" name="selling_price" value="<?php echo e(old('selling_price')); ?>" class="w-full border rounded px-3 py-2" />
          <?php $__errorArgs = ['selling_price'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Quantity</label>
          <input type="number" min="1" name="quantity_sold" value="<?php echo e(old('quantity_sold')); ?>" class="w-full border rounded px-3 py-2" />
          <?php $__errorArgs = ['quantity_sold'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Sale date</label>
          <input type="date" name="sale_date" value="<?php echo e(old('sale_date')); ?>" class="w-full border rounded px-3 py-2" required />
          <?php $__errorArgs = ['sale_date'];
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
      <div class="flex flex-col sm:flex-row gap-2 sm:gap-3">
        <button class="px-3 py-2 bg-indigo-600 text-white rounded">Save Sale</button>
        <a href="<?php echo e(route('sales.index')); ?>" class="px-3 py-2 bg-gray-100 rounded text-center">Cancel</a>
      </div>
    </form>
  </div>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\Timo Kilale\Desktop\Kashier\resources\views/sales/create.blade.php ENDPATH**/ ?>