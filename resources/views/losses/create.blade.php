@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Record Loss</h1>

  <div class="bg-white rounded border p-4">
    <form method="POST" action="{{ route('losses.store') }}" class="space-y-4" id="lossForm">
      @csrf

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="md:col-span-2">
          <label class="block text-sm text-gray-700 mb-1">Product</label>
          <select name="item_id" id="item_id" class="w-full border rounded px-3 py-2" required>
            <option value="">-- Select item --</option>
            @foreach($items as $it)
              <option value="{{ $it->id }}" data-uom-type="{{ $it->uom_type }}" @selected(old('item_id', $itemId)===$it->id)>{{ $it->name }}</option>
            @endforeach
          </select>
          @error('item_id')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="md:col-span-2">
          <label class="block text-sm text-gray-700 mb-1">Related Purchase (optional)</label>
          <select name="purchase_id" id="purchase_id" class="w-full border rounded px-3 py-2">
            <option value="">-- None --</option>
            @foreach(($purchases ?? collect()) as $p)
              <option value="{{ $p->id }}" @selected(old('purchase_id', $purchaseId)===$p->id)>
                #{{ $p->id }} — {{ $p->purchase_date->format('Y-m-d') }} — {{ number_format($p->total_cost ?? ($p->cartons * $p->carton_cost), 0) }} TZS
              </option>
            @endforeach
          </select>
          <p class="text-xs text-gray-500 mt-1" id="purchase_help">Pick an item first to see its purchases.</p>
          @error('purchase_id')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div class="md:col-span-2">
          <label class="block text-sm text-gray-700 mb-1">Quantity</label>
          <div class="flex gap-2">
            <input type="number" min="0.001" step="0.001" name="quantity_value" value="{{ old('quantity_value') }}" class="w-full border rounded px-3 py-2" placeholder="e.g., 1.5" required />
            <select name="quantity_unit" id="quantity_unit" class="border rounded px-3 py-2">
              <option value="unit">unit</option>
            </select>
          </div>
          @error('quantity_value')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
          @error('quantity_unit')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Date</label>
          <input type="date" name="loss_date" value="{{ old('loss_date', now()->format('Y-m-d')) }}" class="w-full border rounded px-3 py-2" required />
          @error('loss_date')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>

      <div>
        <label class="block text-sm text-gray-700 mb-1">Reason</label>
        <input type="text" name="reason" value="{{ old('reason') }}" class="w-full border rounded px-3 py-2" placeholder="Spoilage, expired, damaged, etc." required />
        @error('reason')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
      </div>

      <div>
        <label class="block text-sm text-gray-700 mb-1">Notes (optional)</label>
        <textarea name="notes" class="w-full border rounded px-3 py-2" rows="3">{{ old('notes') }}</textarea>
        @error('notes')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
      </div>

      <div class="flex gap-2">
        <button class="px-3 py-2 bg-red-600 text-white rounded">Save Loss</button>
        <a href="{{ url()->previous() }}" class="px-3 py-2 bg-gray-100 rounded">Cancel</a>
      </div>
    </form>
  </div>
</div>
@endsection

@push('scripts')
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
    var serverItemId = '{{ (int)($itemId ?? 0) }}';
    if(opt && serverItemId && opt.value !== serverItemId){
      var url = new URL("{{ route('losses.create') }}", window.location.origin);
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
    if(purchaseHelp){ purchaseHelp.style.display = {{ ($purchases ?? collect())->count() > 0 ? '"none"' : '""' }}; }
  })();
})();
</script>
@endpush
