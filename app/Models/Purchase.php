<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Purchase extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'item_id',
        'item_name',
        'cost_price',
        'purchase_date',
        'description',
        'quantity',
        // packaging fields
        'cartons',
        'loose_units',
        'units_per_carton',
        'carton_cost',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'purchase_date' => 'date',
        'cost_price' => 'decimal:1',
    ];

    /**
     * Get the user that owns the purchase.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Optional related item (catalog entry)
     */
    public function item()
    {
        return $this->belongsTo(Item::class);
    }

    /**
     * Get the sales for the purchase.
     */
    public function sales()
    {
        return $this->hasMany(Sale::class);
    }

    /**
     * Loss entries associated with this purchase.
     */
    public function losses()
    {
        return $this->hasMany(Loss::class);
    }

    /**
     * Get the total quantity sold for this purchase.
     */
    public function getTotalQuantitySoldAttribute()
    {
        return $this->sales->sum('quantity_sold');
    }

    /**
     * Total quantity recorded as loss for this purchase (in base units of the item).
     */
    public function getTotalQuantityLostAttribute()
    {
        return $this->losses->sum('quantity');
    }

    /**
     * Get the remaining quantity for this purchase.
     */
    public function getRemainingQuantityAttribute()
    {
        return $this->quantity - $this->total_quantity_sold - $this->total_quantity_lost;
    }

    /**
     * Computed: total units for this purchase (for convenience)
     */
    public function getTotalUnitsAttribute()
    {
        return (int) $this->quantity;
    }

    /**
     * Computed: unit cost. We keep `cost_price` as unit cost for compatibility.
     */
    public function getUnitCostAttribute()
    {
        return (float) $this->cost_price;
    }

    /**
     * Computed: exact unit cost derived from carton (higher precision for internal math).
     * Falls back to stored cost_price when packaging fields are missing.
     */
    public function getExactUnitCostAttribute()
    {
        if (!empty($this->units_per_carton) && !empty($this->carton_cost)) {
            // Use higher precision for internal computations
            return round(((float) $this->carton_cost) / (int) $this->units_per_carton, 4);
        }
        return (float) $this->cost_price;
    }

    /**
     * Computed: total purchase cost, driven by carton cost (authoritative).
     * Includes loose units valued at the exact unit cost.
     */
    public function getTotalCostAttribute()
    {
        if (!empty($this->cartons) && !empty($this->carton_cost)) {
            $cartonTotal = (int) $this->cartons * (float) $this->carton_cost;
            $loose = (int) ($this->loose_units ?? 0);
            if ($loose > 0) {
                return $cartonTotal + ($loose * $this->exact_unit_cost);
            }
            return $cartonTotal;
        }
        // Fallback to legacy behavior when packaging fields are not present
        return (float) $this->cost_price * (int) $this->quantity;
    }

    /**
     * Get the total revenue from sales of this purchase.
     */
    public function getTotalRevenueAttribute()
    {
        return $this->sales->sum(function ($sale) {
            return $sale->selling_price * $sale->quantity_sold;
        });
    }

    /**
     * Get the profit/loss for this purchase.
     */
    public function getProfitLossAttribute()
    {
        // Use exact unit cost derived from carton for COGS to avoid rounding drift
        $totalCostSold = $this->exact_unit_cost * $this->total_quantity_sold;
        $lossCost = $this->exact_unit_cost * $this->total_quantity_lost;
        return $this->total_revenue - $totalCostSold - $lossCost;
    }
}
