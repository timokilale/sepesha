<?php $__env->startSection('content'); ?>
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Record Loss</h1>

  <div class="bg-white rounded border p-4">
    <form method="POST" action="<?php echo e(route('losses.store')); ?>" class="space-y-4" id="lossForm">
      <?php echo csrf_field(); ?>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="md:col-span-2">
          <label class="block text-sm text-gray-700 mb-1">Product</label>
          <select name="item_id" id="item_id" class="w-full border rounded px-3 py-2" required>
            <option value="">-- Select item --</option>
            <?php $__currentLoopData = $items; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $it): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
              <option value="<?php echo e($it->id); ?>" data-uom-type="<?php echo e($it->uom_type); ?>" <?php if(old('item_id', $itemId)===$it->id): echo 'selected'; endif; ?>><?php echo e($it->name); ?></option>
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

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="md:col-span-2">
          <label class="block text-sm text-gray-700 mb-1">Related Purchase (optional)</label>
          <select name="purchase_id" id="purchase_id" class="w-full border rounded px-3 py-2">
            <option value="">-- None --</option>
            <?php $__currentLoopData = ($purchases ?? collect()); $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $p): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
              <option value="<?php echo e($p->id); ?>" <?php if(old('purchase_id', $purchaseId)===$p->id): echo 'selected'; endif; ?>>
                #<?php echo e($p->id); ?> — <?php echo e($p->purchase_date->format('Y-m-d')); ?> — <?php echo e(number_format($p->total_cost ?? ($p->cartons * $p->carton_cost), 0)); ?> TZS
              </option>
            <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
          </select>
          <p class="text-xs text-gray-500 mt-1" id="purchase_help">Pick an item first to see its purchases.</p>
          <?php $__errorArgs = ['purchase_id'];
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
        <div class="md:col-span-2">
          <label class="block text-sm text-gray-700 mb-1">Quantity</label>
          <div class="flex gap-2">
            <input type="number" min="0.001" step="0.001" name="quantity_value" value="<?php echo e(old('quantity_value')); ?>" class="w-full border rounded px-3 py-2" placeholder="e.g., 1.5" required />
            <select name="quantity_unit" id="quantity_unit" class="border rounded px-3 py-2">
              <option value="unit">unit</option>
            </select>
          </div>
          <?php $__errorArgs = ['quantity_value'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
          <?php $__errorArgs = ['quantity_unit'];
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
          <input type="date" name="loss_date" value="<?php echo e(old('loss_date', now()->format('Y-m-d'))); ?>" class="w-full border rounded px-3 py-2" required />
          <?php $__errorArgs = ['loss_date'];
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
        <label class="block text-sm text-gray-700 mb-1">Reason</label>
        <input type="text" name="reason" value="<?php echo e(old('reason')); ?>" class="w-full border rounded px-3 py-2" placeholder="Spoilage, expired, damaged, etc." required />
        <?php $__errorArgs = ['reason'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
      </div>

      <div>
        <label class="block text-sm text-gray-700 mb-1">Notes (optional)</label>
        <textarea name="notes" class="w-full border rounded px-3 py-2" rows="3"><?php echo e(old('notes')); ?></textarea>
        <?php $__errorArgs = ['notes'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
      </div>

      <div class="flex gap-2">
        <button class="px-3 py-2 bg-red-600 text-white rounded">Save Loss</button>
        <a href="<?php echo e(url()->previous()); ?>" class="px-3 py-2 bg-gray-100 rounded">Cancel</a>
      </div>
    </form>
  </div>
</div>
<?php $__env->stopSection(); ?>

<?php $__env->startPush('scripts'); ?>
<script>
(function(){
  var itemSel = document.getElementById('item_id');
  var unitSel = document.getElementById('quantity_unit');
  var purchaseHelp = document.getElementById('purchase_help');
  function setUnitsFor(type){
    unitSel.innerHTML = '';
    var opts = [];
    if(type === 'weight'){
      opts = [{v:'g', t:'g'}, {v:'kg', t:'kg'}];
    } else if(type === 'volume'){
      opts = [{v:'ml', t:'ml'}, {v:'l', t:'L'}];
    } else {
      opts = [{v:'unit', t:'unit'}];
    }
    opts.forEach(function(o){
      var opt = document.createElement('option');
      opt.value = o.v; opt.textContent = o.t; unitSel.appendChild(opt);
    });
  }
  function onChange(){
    var opt = itemSel.options[itemSel.selectedIndex];
    var t = opt ? (opt.getAttribute('data-uom-type') || 'unit') : 'unit';
    setUnitsFor(t);
    // if selected item differs from server-provided itemId, redirect to populate purchases
    var serverItemId = '<?php echo e((int)($itemId ?? 0)); ?>';
    if(opt && serverItemId && opt.value !== serverItemId){
      var url = new URL("<?php echo e(route('losses.create')); ?>", window.location.origin);
      url.searchParams.set('item_id', opt.value);
      window.location.href = url.toString();
    }
    // toggle purchase help visibility
    if(purchaseHelp){ purchaseHelp.style.display = opt && opt.value ? 'none' : ''; }
  }
  itemSel.addEventListener('change', onChange);
  // init from selected option
  (function init(){
    var opt = itemSel.options[itemSel.selectedIndex];
    var t = opt ? (opt.getAttribute('data-uom-type') || 'unit') : 'unit';
    setUnitsFor(t);
    if(purchaseHelp){ purchaseHelp.style.display = <?php echo e(($purchases ?? collect())->count() > 0 ? '"none"' : '""'); ?>; }
  })();
})();
</script>
<?php $__env->stopPush(); ?>

<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\Timo Kilale\Desktop\Kashier\resources\views/losses/create.blade.php ENDPATH**/ ?>