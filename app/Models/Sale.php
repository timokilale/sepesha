<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Sale extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'purchase_id',
        'selling_price',
        'sale_date',
        'quantity_sold',
        'notes',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'sale_date' => 'date',
        'selling_price' => 'decimal:2',
    ];

    /**
     * Get the user that owns the sale.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the purchase that this sale belongs to.
     */
    public function purchase()
    {
        return $this->belongsTo(Purchase::class);
    }

    /**
     * Get the total revenue for this sale.
     */
    public function getTotalRevenueAttribute()
    {
        return $this->selling_price * $this->quantity_sold;
    }

    /**
     * Get the profit for this sale.
     */
    public function getProfitAttribute()
    {
        $costPrice = $this->purchase->cost_price * $this->quantity_sold;
        return $this->total_revenue - $costPrice;
    }
}
