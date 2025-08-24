

<?php $__env->startSection('content'); ?>
<div class="max-w-2xl mx-auto px-4" x-data="{
  cartons: Number('<?php echo e(old('cartons', 1)); ?>') || 1,
  unitsPerCarton: Number('<?php echo e(old('units_per_carton', 12)); ?>') || 0,
  cartonCost: Number('<?php echo e(old('carton_cost', 0)); ?>') || 0,
  totalBottles(){ return Math.max(0, this.cartons * this.unitsPerCarton) },
  perBottle(){ return this.unitsPerCarton > 0 ? Math.ceil(this.cartonCost / this.unitsPerCarton) : 0 }
}">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Buy Stock</h1>

  <div class="bg-white rounded border p-4">
    <form method="POST" action="<?php echo e(route('purchases.store')); ?>" class="space-y-4">
      <?php echo csrf_field(); ?>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="md:col-span-2">
          <label class="block text-sm text-gray-700 mb-1">Pick a product</label>
          <select name="item_id" class="w-full border rounded px-3 py-2" required>
            <option value="">-- Select item --</option>
            <?php $__currentLoopData = $items; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $item): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
              <option value="<?php echo e($item->id); ?>" <?php if(old('item_id', request('item_id'))==$item->id): echo 'selected'; endif; ?>><?php echo e($item->name); ?></option>
            <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
          </select>
          <?php $__errorArgs = ['item_id'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
        </div>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">How many cartons?</label>
          <input type="number" min="1" name="cartons" x-model.number="cartons" class="w-full border rounded px-3 py-2" required />
          <?php $__errorArgs = ['cartons'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Bottles per carton</label>
          <input type="number" min="1" name="units_per_carton" x-model.number="unitsPerCarton" class="w-full border rounded px-3 py-2" required />
          <?php $__errorArgs = ['units_per_carton'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Price per carton (TZS)</label>
          <input type="number" step="0.01" min="0" name="carton_cost" x-model.number="cartonCost" class="w-full border rounded px-3 py-2" required />
          <?php $__errorArgs = ['carton_cost'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
        </div>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Purchase date</label>
          <input type="date" name="purchase_date" value="<?php echo e(old('purchase_date')); ?>" class="w-full border rounded px-3 py-2" required />
          <?php $__errorArgs = ['purchase_date'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
        </div>
      </div>

      <div class="rounded border p-3 bg-gray-50 text-sm text-gray-800">
        <div class="flex flex-wrap gap-4">
          <div>
            <div class="text-gray-500">Total bottles</div>
            <div class="font-medium" x-text="totalBottles()"></div>
          </div>
          <div>
            <div class="text-gray-500">Per-bottle cost (computed)</div>
            <div class="font-medium">TZS <span x-text="perBottle().toFixed(0)"></span></div>
          </div>
          <div>
            <div class="text-gray-500">Total purchase cost</div>
            <div class="font-medium">TZS <span x-text="(cartons * cartonCost).toFixed(2)"></span></div>
          </div>
        </div>
      </div>

      
      <div>
        <label class="block text-sm text-gray-700 mb-1">Description</label>
        <textarea name="description" class="w-full border rounded px-3 py-2" rows="3"><?php echo e(old('description')); ?></textarea>
        <?php $__errorArgs = ['description'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
      </div>
      <div class="flex flex-col sm:flex-row gap-2 sm:gap-3">
        <button class="px-3 py-2 bg-indigo-600 text-white rounded">Save Purchase</button>
        <a href="<?php echo e(route('purchases.index')); ?>" class="px-3 py-2 bg-gray-100 rounded text-center">Cancel</a>
      </div>
    </form>
  </div>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\Timo Kilale\Desktop\Kashier\resources\views/purchases/create.blade.php ENDPATH**/ ?>