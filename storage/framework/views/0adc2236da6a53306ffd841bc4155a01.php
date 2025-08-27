<?php $__env->startSection('content'); ?>
<div class="max-w-2xl mx-auto px-4" x-data="{
  productType: '<?php echo e(old('product_type', 'beverage')); ?>',
  cartons: Number('<?php echo e(old('cartons', 1)); ?>') || 1,
  unitsPerCarton: Number('<?php echo e(old('units_per_carton', 12)); ?>') || 0,
  cartonCost: Number('<?php echo e(old('carton_cost', 0)); ?>') || 0,
  weight: Number('<?php echo e(old('weight', 0)); ?>') || 0,
  pricePerKg: Number('<?php echo e(old('price_per_kg', 0)); ?>') || 0,
  totalBottles(){ return Math.max(0, this.cartons * this.unitsPerCarton) },
  perBottle(){ return this.unitsPerCarton > 0 ? (this.cartonCost / this.unitsPerCarton) : 0 },
  totalMeatCost(){ return this.weight * this.pricePerKg }
}"
     x-init="
       // On load, align productType with selected item's uom_type if any
       (() => {
         const sel = $refs.itemSelect;
         if (sel && sel.selectedIndex > 0) {
           const opt = sel.options[sel.selectedIndex];
           const t = opt?.dataset?.uomType;
           if (t === 'weight') { productType = 'meat'; } else { productType = 'beverage'; }
         }
       })()
     ">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Buy Stock for <span x-text="productType === 'meat' ? 'Meat' : 'Beverage'"></span> Products</h1>

  <div class="bg-white rounded border p-4">
    <form method="POST" action="<?php echo e(route('purchases.store')); ?>" class="space-y-4">
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

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="md:col-span-2">
          <label class="block text-sm text-gray-700 mb-1">Pick a product</label>
          <select name="item_id" id="item_id" class="w-full border rounded px-3 py-2" required
                  x-ref="itemSelect"
                  @change="
                    const opt = $refs.itemSelect.options[$refs.itemSelect.selectedIndex];
                    const t = opt?.dataset?.uomType;
                    if (t === 'weight') { productType = 'meat'; } else { productType = 'beverage'; }
                  ">
            <option value="">-- Select item --</option>
            <?php $__currentLoopData = $items; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $item): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
              <option value="<?php echo e($item->id); ?>" data-uom-type="<?php echo e($item->uom_type); ?>" <?php if(old('item_id', request('item_id'))==$item->id): echo 'selected'; endif; ?>><?php echo e($item->name); ?></option>
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

      <!-- Beverage (Carton-based) fields -->
      <div x-show="productType === 'beverage'" class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">How many cartons?</label>
          <input type="number" min="1" name="cartons" x-model.number="cartons" class="w-full border rounded px-3 py-2"
                 :required="productType === 'beverage'" :disabled="productType !== 'beverage'" />
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
          <input type="number" min="1" name="units_per_carton" x-model.number="unitsPerCarton" class="w-full border rounded px-3 py-2"
                 :required="productType === 'beverage'" :disabled="productType !== 'beverage'" />
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
          <input type="number" step="0.01" min="0" name="carton_cost" x-model.number="cartonCost" class="w-full border rounded px-3 py-2"
                 :required="productType === 'beverage'" :disabled="productType !== 'beverage'" />
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

      <!-- Meat (Weight-based) fields -->
      <div x-show="productType === 'meat'" class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Weight (kg)</label>
          <input type="number" min="0.1" step="0.1" name="weight" x-model.number="weight" class="w-full border rounded px-3 py-2" placeholder="e.g., 5.5"
                 :required="productType === 'meat'" :disabled="productType !== 'meat'" />
          <?php $__errorArgs = ['weight'];
$__bag = $errors->getBag($__errorArgs[1] ?? 'default');
if ($__bag->has($__errorArgs[0])) :
if (isset($message)) { $__messageOriginal = $message; }
$message = $__bag->first($__errorArgs[0]); ?><p class="text-red-600 text-sm"><?php echo e($message); ?></p><?php unset($message);
if (isset($__messageOriginal)) { $message = $__messageOriginal; }
endif;
unset($__errorArgs, $__bag); ?>
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Price per kg (TZS)</label>
          <input type="number" step="0.01" min="0" name="price_per_kg" x-model.number="pricePerKg" class="w-full border rounded px-3 py-2" placeholder="e.g., 7000"
                 :required="productType === 'meat'" :disabled="productType !== 'meat'" />
          <?php $__errorArgs = ['price_per_kg'];
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

      <!-- Summary Section -->
      <div class="rounded border p-3 bg-gray-50 text-sm text-gray-800">
        <div class="flex flex-wrap gap-4">
          <!-- Beverage Summary -->
          <div x-show="productType === 'beverage'">
            <div class="text-gray-500">Total bottles</div>
            <div class="font-medium" x-text="totalBottles()"></div>
            <div class="text-gray-500 mt-2">Per-bottle cost (computed)</div>
            <div class="font-medium">TZS <span x-text="perBottle().toFixed(1)"></span></div>
            <div class="text-gray-500 mt-2">Total purchase cost</div>
            <div class="font-medium">TZS <span x-text="(cartons * cartonCost).toFixed(2)"></span></div>
          </div>
          
          <!-- Meat Summary -->
          <div x-show="productType === 'meat'">
            <div class="text-gray-500">Total weight</div>
            <div class="font-medium"><span x-text="weight"></span> kg</div>
            <div class="text-gray-500 mt-2">Price per kg</div>
            <div class="font-medium">TZS <span x-text="pricePerKg.toFixed(2)"></span></div>
            <div class="text-gray-500 mt-2">Total purchase cost</div>
            <div class="font-medium">TZS <span x-text="totalMeatCost().toFixed(2)"></span></div>
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