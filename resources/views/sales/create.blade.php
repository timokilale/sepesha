@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto px-4" x-data="{
  mode: 'simple',
  productType: '{{ old('product_type', 'beverage') }}',
  weight: Number('{{ old('weight_sold', 0) }}') || 0,
  pricePerKg: Number('{{ old('price_per_kg_sale', 0) }}') || 0,
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
    <form method="POST" action="{{ route('sales.store') }}" class="space-y-4">
      @csrf
      <!-- Product Type Selection -->
      <div>
        <label class="block text-sm text-gray-700 mb-1">Product Type</label>
        <select name="product_type" x-model="productType" class="w-full border rounded px-3 py-2" required>
          <option value="beverage" @selected(old('product_type', 'beverage')==='beverage')>Beverage</option>
          <option value="meat" @selected(old('product_type')==='meat')>Meat</option>
        </select>
        @error('product_type')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
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
          @foreach($purchases as $purchase)
            <option value="{{ $purchase->id }}" @selected(old('purchase_id', request('purchase_id'))==$purchase->id) data-uom-type="{{ $purchase->item?->uom_type }}">
              {{ $purchase->item?->name ?? $purchase->item_name }} — zimebaki: 
              @if($purchase->item?->uom_type === 'weight')
                {{ $purchase->item?->formatBaseQuantity($purchase->remaining_quantity) }}
              @else
                {{ $purchase->remaining_quantity }} @if($purchase->item?->unit_name){{ $purchase->item?->unit_name }}@endif
              @endif
            </option>
          @endforeach
        </select>
        @error('purchase_id')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        <p class="text-xs text-gray-500 mt-1">
          <span x-show="productType === 'beverage'">Tip: Choose the batch you want to sell from. Remaining bottles help you avoid overselling.</span>
          <span x-show="productType === 'meat'">Tip: Choose the meat batch you want to sell from. Remaining weight helps you avoid overselling.</span>
        </p>
      </div>

      <!-- Sale Date - Single field for both product types -->
      <div>
        <label class="block text-sm text-gray-700 mb-1">Tarehe uliyouza</label>
        <input type="date" name="sale_date" value="{{ old('sale_date') }}" class="w-full border rounded px-3 py-2" required />
        @error('sale_date')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
      </div>

      <!-- Beverage Sales Fields -->
      <div x-show="productType === 'beverage'">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-sm text-gray-700 mb-1">Chupa zilizouzwa</label>
            <input type="number" min="1" name="quantity_sold" value="{{ old('quantity_sold') }}" class="w-full border rounded px-3 py-2"
                   :required="productType === 'beverage'" :disabled="productType !== 'beverage'" />
            @error('quantity_sold')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
          </div>
          <div>
            <label class="block text-sm text-gray-700 mb-1">Bei ya kila chupa</label>
            <input type="number" step="0.01" name="selling_price" value="{{ old('selling_price') }}" class="w-full border rounded px-3 py-2"
                   :required="productType === 'beverage'" :disabled="productType !== 'beverage'" />
            @error('selling_price')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
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
            @error('weight_sold')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
          </div>
          <div>
            <label class="block text-sm text-gray-700 mb-1">Bei ya kila kg (TZS)</label>
            <input type="number" step="0.01" name="price_per_kg_sale" x-model.number="pricePerKg" class="w-full border rounded px-3 py-2" placeholder="e.g., 8000"
                   :required="productType === 'meat'" :disabled="productType !== 'meat'" />
            @error('price_per_kg_sale')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
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
        <textarea name="notes" class="w-full border rounded px-3 py-2" rows="3">{{ old('notes') }}</textarea>
        @error('notes')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
      </div>
      
      <div class="flex flex-col sm:flex-row gap-2 sm:gap-3">
        <button type="submit" class="px-3 py-2 bg-indigo-600 text-white rounded">Save Sale</button>
        <a href="{{ route('sales.index') }}" class="px-3 py-2 bg-gray-100 rounded text-center">Cancel</a>
      </div>
    </form>
  </div>
</div>

@push('scripts')
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
@endpush
@endsection