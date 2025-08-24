<?php $__env->startSection('content'); ?>
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-1">Add Product</h1>
  <p class="text-xs text-gray-500 mb-3">We generate a product code (SKU) for you.</p>
  <div class="bg-white rounded border p-4">
    <form method="POST" action="<?php echo e(route('items.store')); ?>" enctype="multipart/form-data" class="space-y-4">
      <?php echo csrf_field(); ?>
      <!-- Row 1: Name | Image upload -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Name</label>
          <input name="name" value="<?php echo e(old('name')); ?>" class="w-full border rounded px-3 py-2" required />
          <?php $__errorArgs = ['name'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
        </div>
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
        </div>
      </div>

      <!-- Row 2: Unit name | Volume | Carton size -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Unit name (optional)</label>
          <input name="unit_name" value="<?php echo e(old('unit_name', 'bottle')); ?>" class="w-full border rounded px-3 py-2" />
          <?php $__errorArgs = ['unit_name'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Volume (optional)</label>
          <div class="flex gap-2">
            <input type="number" step="0.001" min="0.001" name="volume_value" value="<?php echo e(old('volume_value')); ?>" class="w-full border rounded px-3 py-2" placeholder="e.g., 500" />
            <select name="volume_unit" class="border rounded px-3 py-2">
              <option value="ml" <?php if(old('volume_unit','ml')==='ml'): echo 'selected'; endif; ?>>ml</option>
              <option value="l" <?php if(old('volume_unit')==='l'): echo 'selected'; endif; ?>>L</option>
            </select>
          </div>
          <p class="text-xs text-gray-500 mt-1">Example: 500 ml or 1 L</p>
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Carton size<span class="text-red-600">*</span></label>
          <input type="number" min="1" name="carton_size" value="<?php echo e(old('carton_size')); ?>" class="w-full border rounded px-3 py-2" placeholder="Units per carton" required />
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

      <div>
        <label class="block text-sm text-gray-700 mb-1">Notes</label>
        <textarea name="notes" class="w-full border rounded px-3 py-2" rows="3"><?php echo e(old('notes')); ?></textarea>
        <p class="text-xs text-gray-500 mt-1">Optional: any extra details about this product.</p>
        <?php $__errorArgs = ['notes'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
      </div>
      <p class="text-xs text-gray-500">Carton size is how many base units (e.g., bottles) are in one carton.</p>
      <div class="flex gap-2">
        <button class="px-3 py-2 bg-indigo-600 text-white rounded">Save</button>
        <a href="<?php echo e(route('items.index')); ?>" class="px-3 py-2 bg-gray-100 rounded">Cancel</a>
      </div>
    </form>
  </div>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\Timo Kilale\Desktop\Kashier\resources\views/items/create.blade.php ENDPATH**/ ?>