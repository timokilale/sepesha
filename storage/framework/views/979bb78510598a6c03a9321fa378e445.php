

<?php $__env->startSection('content'); ?>
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Edit Purchase</h1>

  <div class="bg-white rounded border p-4">
    <form method="POST" action="<?php echo e(route('purchases.update.single', ['id' => $purchase->id])); ?>" class="space-y-4">
      <?php echo csrf_field(); ?>
      <?php echo method_field('PUT'); ?>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="md:col-span-2">
          <label class="block text-sm text-gray-700 mb-1">Item</label>
          <select name="item_id" id="item_id" class="w-full border rounded px-3 py-2" required>
            <option value="">-- Select item --</option>
            <?php $__currentLoopData = $items; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $item): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
              <option value="<?php echo e($item->id); ?>" data-uom-type="<?php echo e($item->uom_type); ?>" <?php if(old('item_id', $purchase->item_id)==$item->id): echo 'selected'; endif; ?>><?php echo e($item->name); ?></option>
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
          <label class="block text-sm text-gray-700 mb-1">Purchase date</label>
          <input type="date" name="purchase_date" value="<?php echo e(old('purchase_date', $purchase->purchase_date->format('Y-m-d'))); ?>" class="w-full border rounded px-3 py-2" required />
        </div>
      </div>

      <div class="border rounded p-3">
        <h2 class="text-sm font-semibold text-gray-800 mb-2">Quantity & Cost</h2>
        <!-- Carton section -->
        <div id="carton_fields" class="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label class="block text-sm text-gray-700 mb-1">Cartons</label>
            <input type="number" min="1" name="cartons" value="<?php echo e(old('cartons', $purchase->cartons)); ?>" class="w-full border rounded px-3 py-2" />
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
            <input type="number" min="1" name="units_per_carton" value="<?php echo e(old('units_per_carton', $purchase->units_per_carton)); ?>" class="w-full border rounded px-3 py-2" />
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
            <label class="block text-sm text-gray-700 mb-1">Loose bottles (optional)</label>
            <input type="number" min="0" name="loose_units" value="<?php echo e(old('loose_units', $purchase->loose_units)); ?>" class="w-full border rounded px-3 py-2" />
            <?php $__errorArgs = ['loose_units'];
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
            <input type="number" step="0.01" min="0" name="carton_cost" value="<?php echo e(old('carton_cost', $purchase->carton_cost)); ?>" class="w-full border rounded px-3 py-2" />
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
        <!-- Weight section -->
        <div id="weight_fields" class="grid grid-cols-1 md:grid-cols-4 gap-4" style="display:none">
          <div class="md:col-span-2">
            <label class="block text-sm text-gray-700 mb-1">Weight</label>
            <div class="flex gap-2">
              <input type="number" min="0.001" step="0.001" name="weight_value" value="<?php echo e(old('weight_value')); ?>" class="w-full border rounded px-3 py-2" placeholder="e.g., 5" />
              <select name="weight_unit" class="border rounded px-3 py-2">
                <option value="kg" <?php if(old('weight_unit')==='kg'): echo 'selected'; endif; ?>>kg</option>
                <option value="g" <?php if(old('weight_unit')==='g'): echo 'selected'; endif; ?>>g</option>
              </select>
            </div>
            <?php $__errorArgs = ['weight_value'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
            <?php $__errorArgs = ['weight_unit'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
          </div>
          <div class="md:col-span-2">
            <label class="block text-sm text-gray-700 mb-1">Total cost (TZS)</label>
            <input type="number" step="0.01" min="0" name="total_cost" value="<?php echo e(old('total_cost')); ?>" class="w-full border rounded px-3 py-2" placeholder="e.g., 35000" />
            <?php $__errorArgs = ['total_cost'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
          </div>
        </div>
        <p class="text-xs text-gray-500 mt-2">Carton or weight fields will be used depending on the product type.</p>
      </div>
      <div>
        <label class="block text-sm text-gray-700 mb-1">Description</label>
        <textarea name="description" class="w-full border rounded px-3 py-2" rows="3"><?php echo e(old('description', $purchase->description)); ?></textarea>
      </div>
      <div class="flex flex-col sm:flex-row gap-2 sm:gap-3">
        <button class="px-3 py-2 bg-indigo-600 text-white rounded">Update</button>
        <a href="<?php echo e(route('purchases.index')); ?>" class="px-3 py-2 bg-gray-100 rounded text-center">Cancel</a>
      </div>
    </form>
  </div>
</div>
<?php $__env->stopSection(); ?>

<?php $__env->startPush('scripts'); ?>
<script>
  (function(){
    function toggleByType(type){
      var carton = document.getElementById('carton_fields');
      var weight = document.getElementById('weight_fields');
      if(type === 'weight'){
        carton.style.display = 'none';
        weight.style.display = '';
      } else {
        carton.style.display = '';
        weight.style.display = 'none';
      }
    }
    var sel = document.getElementById('item_id');
    function onChange(){
      var opt = sel.options[sel.selectedIndex];
      var t = opt ? (opt.getAttribute('data-uom-type') || 'unit') : 'unit';
      toggleByType(t);
    }
    sel.addEventListener('change', onChange);
    onChange();
  })();
</script>
<?php $__env->stopPush(); ?>

<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\Timo Kilale\Desktop\Kashier\resources\views/purchases/edit.blade.php ENDPATH**/ ?>