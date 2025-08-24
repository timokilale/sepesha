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
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Unit name (optional)</label>
          <input name="unit_name" value="<?php echo e(old('unit_name', $item->unit_name)); ?>" class="w-full border rounded px-3 py-2" />
        </div>
        
      </div>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Carton size (optional)</label>
          <input type="number" min="1" name="carton_size" value="<?php echo e(old('carton_size', $item->carton_size)); ?>" class="w-full border rounded px-3 py-2" />
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
          <?php if($item->image_url): ?>
            <img src="<?php echo e($item->image_url); ?>" alt="<?php echo e($item->name); ?>" class="mt-2 h-20 w-20 object-cover rounded border" />
          <?php endif; ?>
        </div>
      </div>
      <p class="text-xs text-gray-500">Unit is the smallest piece you sell (e.g., bottle). Carton size is how many units are in one carton (e.g., 25 bottles in a carton). You can buy by cartons or by units.</p>
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

<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\Timo Kilale\Desktop\Kashier\resources\views/items/edit.blade.php ENDPATH**/ ?>