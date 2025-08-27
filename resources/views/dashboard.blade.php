@extends('layouts.app')

@section('content')
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  <!-- Quick actions on Home -->
  <div class="mb-4 flex items-center gap-2">
    <a href="{{ route('items.create') }}" class="px-3 py-2 text-sm rounded border bg-white hover:bg-gray-50">+ Add kinywaji</a>
    <a href="{{ route('meat.create') }}" class="px-3 py-2 text-sm rounded border bg-red-50 text-red-700 hover:bg-red-100">+ Add meat</a>
    <!--<a href="{{ route('purchases.create') }}" class="px-3 py-2 text-sm rounded border bg-white hover:bg-gray-50">+ Buy stock</a>
    <a href="{{ route('sales.create') }}" class="px-3 py-2 text-sm rounded border bg-white hover:bg-gray-50">+ Sell stock</a>-->
  </div>

  <!-- Totals Row: show Money Spent and Money In to everyone; Profit only for Admin -->
  <div class="grid grid-cols-1 {{ auth()->user()->isAdmin() ? 'sm:grid-cols-3' : 'sm:grid-cols-2' }} gap-4 sm:gap-6">
    <div class="border rounded p-4 bg-white">
      <div class="text-gray-500 text-xs uppercase tracking-wide">Money Spent (Buying)</div>
      <div class="text-xl font-semibold text-gray-900 mt-1">TZS {{ number_format($totalPurchases, 2) }}</div>
    </div>
    <div class="border rounded p-4 bg-white">
      <div class="text-gray-500 text-xs uppercase tracking-wide">Money In (Selling)</div>
      <div class="text-xl font-semibold text-gray-900 mt-1">TZS {{ number_format($totalSales, 2) }}</div>
    </div>
    @if(auth()->user()->isAdmin())
    <div class="border rounded p-4 bg-white">
      <div class="text-gray-500 text-xs uppercase tracking-wide">Profit (Money In − Expenses)</div>
      <div class="text-xl font-semibold mt-1 {{ $totalProfit >= 0 ? 'text-green-600' : 'text-red-600' }}">TZS {{ number_format($totalProfit, 2) }}</div>
    </div>
    @endif
  </div>

  <!-- Products Grid -->
  <div class="mt-6">
    <h2 class="text-sm font-semibold text-gray-700 mb-1">Products</h2>
    <p class="text-xs text-gray-500 mb-3">Tap a product to buy or sell. Stock updates automatically.</p>
    @if($items->isEmpty())
      <div class="border rounded p-6 bg-white text-center text-gray-600">
        No products yet. Click "Add kinywaji" or "Add meat" to create your first product.
      </div>
    @else
      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
        @foreach($items as $item)
          <a href="{{ route('items.show.single', ['id' => $item->id]) }}" class="block border rounded overflow-hidden bg-white hover:shadow {{ $item->is_active ? '' : 'opacity-50' }}">
            <div class="aspect-square bg-gray-50 flex items-center justify-center">
              @if($item->image_url)
                <img src="{{ $item->image_url }}" alt="{{ $item->name }}" class="w-full h-full object-cover" />
              @else
                <span class="text-gray-400 text-xs">No image</span>
              @endif
            </div>
            <div class="p-2">
              <div class="font-medium text-sm text-gray-900 truncate flex items-center gap-2">
                <span>{{ $item->name }}</span>
                @unless($item->is_active)
                  <span class="text-[10px] px-1.5 py-0.5 rounded bg-gray-200 text-gray-700">Inactive</span>
                @endunless
              </div>
              <div class="text-xs text-gray-600">
                @if($item->uom_type === 'weight')
                  Stock: {{ $item->formatBaseQuantity($item->stock_remaining) }}
                @else
                  @php($unit = $item->unit_name ?: 'unit')
                  Stock: {{ $item->stock_remaining }} {{ \Illuminate\Support\Str::plural($unit, $item->stock_remaining) }}
                @endif
              </div>
              @if($item->category)
                <div class="text-[11px] text-gray-500">{{ ucfirst($item->category) }}</div>
              @endif
              @if(auth()->user()->isAdmin())
              <div class="mt-1 text-xs font-medium {{ ($item->profit_loss ?? 0) >= 0 ? 'text-green-700' : 'text-red-700' }}">
                Profit/Loss: TZS {{ number_format($item->profit_loss ?? 0, 2) }}
              </div>
              @endif
              <div class="mt-2 flex gap-2">
                <a href="{{ route('purchases.create', ['item_id' => $item->id]) }}" class="text-xs px-2 py-1 border rounded">Buy</a>
                <a href="{{ route('sales.create', ['item_id' => $item->id]) }}" class="text-xs px-2 py-1 border rounded">Sell</a>
              </div>
            </div>
          </a>
        @endforeach
      </div>
    @endif
  </div>
</div>
@endsection
