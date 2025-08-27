<?php $__env->startSection('content'); ?>
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Edit Item</h1>
  <div class="bg-white rounded border p-4">
    <form method="POST" action="<?php echo e(route('items.update.single', ['id' => $item->id])); ?>" enctype="multipart/form-data" class="space-y-4">
      <?php echo csrf_field(); ?>
      <?php echo method_field('PUT'); ?>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Name</label>
          <input name="name" value="<?php echo e(old('name', $item->name)); ?>" class="w-full border rounded px-3 py-2" required />
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">SKU</label>
          <input value="<?php echo e($item->sku); ?>" class="w-full border rounded px-3 py-2 bg-gray-50 text-gray-700" readonly />
          <p class="text-xs text-gray-500 mt-1">Auto-generated. Shown for reference.</p>
        </div>
      </div>
      <!-- Unit type selector and category -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Unit Type</label>
          <select name="uom_type" id="uom_type" class="w-full border rounded px-3 py-2">
            <?php
              $selType = old('uom_type', $item->uom_type ?? 'volume');
            ?>
            <option value="volume" <?php if($selType==='volume'): echo 'selected'; endif; ?>>Volume (L/ml)</option>
            <option value="weight" <?php if($selType==='weight'): echo 'selected'; endif; ?>>Weight (kg/g)</option>
            <option value="unit" <?php if($selType==='unit'): echo 'selected'; endif; ?>>Count (pieces)</option>
          </select>
          <?php $__errorArgs = ['uom_type'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Category (optional)</label>
          <input name="category" value="<?php echo e(old('category', $item->category)); ?>" class="w-full border rounded px-3 py-2" placeholder="e.g., beverage, meat" />
          <?php $__errorArgs = ['category'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
        </div>
      </div>

      <!-- Volume and carton fields (conditional) -->
      <?php
        $volMl = old('volume_value') ? null : ($item->volume_ml ?? null);
        $prefUnit = 'ml';
        $prefVal = '';
        if ($volMl) {
          if ($volMl >= 1000 && $volMl % 1000 === 0) {
            $prefUnit = 'l';
            $prefVal = number_format($volMl / 1000, 3, '.', '');
          } else {
            $prefUnit = 'ml';
            $prefVal = (string) $volMl;
          }
        }
      ?>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div id="volume_fields">
          <label class="block text-sm text-gray-700 mb-1">Ujazo wa chupa</label>
          <div class="flex gap-2">
            <input type="number" step="0.001" min="0.001" name="volume_value" value="<?php echo e(old('volume_value', $prefVal)); ?>" class="w-full border rounded px-3 py-2" placeholder="mfano, 500" />
            <select name="volume_unit" class="border rounded px-3 py-2">
              <option value="ml" <?php if(old('volume_unit', $prefUnit)==='ml'): echo 'selected'; endif; ?>>ml</option>
              <option value="l" <?php if(old('volume_unit', $prefUnit)==='l'): echo 'selected'; endif; ?>>L</option>
            </select>
          </div>
          <p class="text-xs text-gray-500 mt-1">Mfano: 500 ml au 1 L</p>
          <?php $__errorArgs = ['volume_value'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
          <?php $__errorArgs = ['volume_unit'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
        </div>
        <div id="carton_field">
          <label class="block text-sm text-gray-700 mb-1">Carton size</label>
          <input type="number" min="1" name="carton_size" value="<?php echo e(old('carton_size', $item->carton_size)); ?>" class="w-full border rounded px-3 py-2" placeholder="Units per carton" />
          <?php $__errorArgs = ['carton_size'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
        </div>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Product image (optional)</label>
          <input type="file" name="image" accept="image/*" class="w-full border rounded px-3 py-2" />
          <p class="text-xs text-gray-500 mt-1">Upload a photo for this product. Max 2 MB.</p>
          <?php $__errorArgs = ['image'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
          <?php if($item->image_url): ?>
            <img src="<?php echo e($item->image_url); ?>" alt="<?php echo e($item->name); ?>" class="mt-2 h-20 w-20 object-cover rounded border" />
          <?php endif; ?>
        </div>
      </div>
      <p class="text-xs text-gray-500">For beverages, carton size ni idadi ya chupa katika katoni au kreti moja. For meat, volume and carton are hidden.</p>
      <div>
        <label class="block text-sm text-gray-700 mb-1">Notes (optional)</label>
        <input name="notes" value="<?php echo e(old('notes', $item->notes)); ?>" class="w-full border rounded px-3 py-2" />
      </div>
      <div class="flex gap-2">
        <button class="px-3 py-2 bg-indigo-600 text-white rounded">Update</button>
        <a href="<?php echo e(route('items.index')); ?>" class="px-3 py-2 bg-gray-100 rounded">Cancel</a>
      </div>
    </form>
  </div>
</div>
<?php $__env->stopSection(); ?>

<?php $__env->startPush('scripts'); ?>
<script>
  (function(){
    function toggleFields() {
      var type = document.getElementById('uom_type').value;
      var vol = document.getElementById('volume_fields');
      var carton = document.getElementById('carton_field');
      if (type === 'volume') {
        vol.style.display = '';
        carton.style.display = '';
      } else if (type === 'unit') {
        vol.style.display = 'none';
        carton.style.display = '';
      } else { // weight
        vol.style.display = 'none';
        carton.style.display = 'none';
      }
    }
    document.getElementById('uom_type').addEventListener('change', toggleFields);
    toggleFields();
  })();
</script>
<?php $__env->stopPush(); ?>

<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\Timo Kilale\Desktop\Kashier\resources\views/items/edit.blade.php ENDPATH**/ ?>