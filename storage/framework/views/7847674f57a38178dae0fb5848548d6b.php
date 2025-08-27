<?php $__env->startSection('content'); ?>
<div class="max-w-2xl mx-auto px-4" x-data="{
  mode: 'simple',
  productType: '<?php echo e(old('product_type', 'beverage')); ?>',
  weight: Number('<?php echo e(old('weight_sold', 0)); ?>') || 0,
  pricePerKg: Number('<?php echo e(old('price_per_kg_sale', 0)); ?>') || 0,
  totalMeatCost(){ return this.weight * this.pricePerKg }
}"
     x-init="
       (() => {
         const sel = $refs.purchaseSelect;
         if (sel && sel.selectedIndex > 0) {
           const opt = sel.options[sel.selectedIndex];
           const t = opt?.dataset?.uomType;
           productType = (t === 'weight') ? 'meat' : 'beverage';
         }
       })()
     ">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Sell Stock for <span x-text="productType === 'meat' ? 'Meat' : 'Beverage'"></span> Products</h1>

  <div class="bg-white rounded border p-4">
    <form method="POST" action="<?php echo e(route('sales.store')); ?>" class="space-y-4">
      <?php echo csrf_field(); ?>
      <!-- Product Type Selection -->
      <div>
        <label class="block text-sm text-gray-700 mb-1">Product Type</label>
        <select name="product_type" x-model="productType" class="w-full border rounded px-3 py-2" required>
          <option value="beverage" <?php if(old('product_type', 'beverage')==='beverage'): echo 'selected'; endif; ?>>Beverage</option>
          <option value="meat" <?php if(old('product_type')==='meat'): echo 'selected'; endif; ?>>Meat</option>
        </select>
        <?php $__errorArgs = ['product_type'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
      </div>
      
      <div class="flex items-center gap-2 text-sm">
        <button type="button" @click="mode='simple'" :class="mode==='simple' ? 'bg-indigo-600 text-white' : 'bg-gray-100 text-gray-700'" class="px-3 py-1.5 rounded">Simple</button>
        <button type="button" @click="mode='advanced'" :class="mode==='advanced' ? 'bg-indigo-600 text-white' : 'bg-gray-100 text-gray-700'" class="px-3 py-1.5 rounded">Advanced</button>
      </div>
      
      <div>
        <label class="block text-sm text-gray-700 mb-1">
          <span x-show="productType === 'beverage'">Pick stock to sell (remaining shown in bottles)</span>
          <span x-show="productType === 'meat'">Pick meat stock to sell (remaining shown in kg)</span>
        </label>
        <select name="purchase_id" class="w-full border rounded px-3 py-2" required
                x-ref="purchaseSelect"
                @change="
                  const opt = $refs.purchaseSelect.options[$refs.purchaseSelect.selectedIndex];
                  const t = opt?.dataset?.uomType;
                  productType = (t === 'weight') ? 'meat' : 'beverage';
                ">
          <option value="">-- Select stock --</option>
          <?php $__currentLoopData = $purchases; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $purchase): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
            <option value="<?php echo e($purchase->id); ?>" <?php if(old('purchase_id', request('purchase_id'))==$purchase->id): echo 'selected'; endif; ?> data-uom-type="<?php echo e($purchase->item?->uom_type); ?>">
              <?php echo e($purchase->item?->name ?? $purchase->item_name); ?> — zimebaki: 
              <?php if($purchase->item?->uom_type === 'weight'): ?>
                <?php echo e($purchase->item?->formatBaseQuantity($purchase->remaining_quantity)); ?>

              <?php else: ?>
                <?php echo e($purchase->remaining_quantity); ?> <?php if($purchase->item?->unit_name): ?><?php echo e($purchase->item?->unit_name); ?><?php endif; ?>
              <?php endif; ?>
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
        <p class="text-xs text-gray-500 mt-1">
          <span x-show="productType === 'beverage'">Tip: Choose the batch you want to sell from. Remaining bottles help you avoid overselling.</span>
          <span x-show="productType === 'meat'">Tip: Choose the meat batch you want to sell from. Remaining weight helps you avoid overselling.</span>
        </p>
      </div>

      <!-- Sale Date - Single field for both product types -->
      <div>
        <label class="block text-sm text-gray-700 mb-1">Tarehe uliyouza</label>
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

      <!-- Beverage Sales Fields -->
      <div x-show="productType === 'beverage'">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-sm text-gray-700 mb-1">Chupa zilizouzwa</label>
            <input type="number" min="1" name="quantity_sold" value="<?php echo e(old('quantity_sold')); ?>" class="w-full border rounded px-3 py-2"
                   :required="productType === 'beverage'" :disabled="productType !== 'beverage'" />
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
            <label class="block text-sm text-gray-700 mb-1">Bei ya kila chupa</label>
            <input type="number" step="0.01" name="selling_price" value="<?php echo e(old('selling_price')); ?>" class="w-full border rounded px-3 py-2"
                   :required="productType === 'beverage'" :disabled="productType !== 'beverage'" />
            <?php $__errorArgs = ['selling_price'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
          </div>
        </div>
      </div>

      <!-- Meat Sales Fields -->
      <div x-show="productType === 'meat'">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-sm text-gray-700 mb-1">Uzito uliouzwa (kg)</label>
            <input type="number" min="0.1" step="0.1" name="weight_sold" x-model.number="weight" class="w-full border rounded px-3 py-2" placeholder="e.g., 2.5"
                   :required="productType === 'meat'" :disabled="productType !== 'meat'" />
            <?php $__errorArgs = ['weight_sold'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
          </div>
          <div>
            <label class="block text-sm text-gray-700 mb-1">Bei ya kila kg (TZS)</label>
            <input type="number" step="0.01" name="price_per_kg_sale" x-model.number="pricePerKg" class="w-full border rounded px-3 py-2" placeholder="e.g., 8000"
                   :required="productType === 'meat'" :disabled="productType !== 'meat'" />
            <?php $__errorArgs = ['price_per_kg_sale'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
          </div>
        </div>

        <!-- Summary Section for Meat -->
        <div class="mt-4 rounded border p-3 bg-gray-50 text-sm text-gray-800">
          <div class="flex flex-wrap gap-4">
            <div>
              <div class="text-gray-500">Weight sold</div>
              <div class="font-medium"><span x-text="weight || 0"></span> kg</div>
            </div>
            <div>
              <div class="text-gray-500">Price per kg</div>
              <div class="font-medium">TZS <span x-text="(pricePerKg || 0).toFixed(2)"></span></div>
            </div>
            <div>
              <div class="text-gray-500">Total sale amount</div>
              <div class="font-medium text-lg text-indigo-600">TZS <span x-text="totalMeatCost().toFixed(2)"></span></div>
            </div>
          </div>
        </div>
      </div>
      
      <div>
        <label class="block text-sm text-gray-700 mb-1">Notes</label>
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
      
      <div class="flex flex-col sm:flex-row gap-2 sm:gap-3">
        <button type="submit" class="px-3 py-2 bg-indigo-600 text-white rounded">Save Sale</button>
        <a href="<?php echo e(route('sales.index')); ?>" class="px-3 py-2 bg-gray-100 rounded text-center">Cancel</a>
      </div>
    </form>
  </div>
</div>

<?php $__env->startPush('scripts'); ?>
<script>
// Debug form submission
document.addEventListener('DOMContentLoaded', function() {
    const form = document.querySelector('form');
    if (form) {
        form.addEventListener('submit', function(e) {
            console.log('Form being submitted...');
            const formData = new FormData(form);
            for (let [key, value] of formData.entries()) {
                console.log(key, value);
            }
        });
    }
});
</script>
<?php $__env->stopPush(); ?>
<?php $__env->stopSection(); ?>
<?php echo $__env->make('layouts.app', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\Timo Kilale\Desktop\Kashier\resources\views/sales/create.blade.php ENDPATH**/ ?>