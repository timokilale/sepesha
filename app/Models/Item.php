<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Item extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'name',
        'sku',
        'unit_name', // e.g., bottle, piece, can
        'volume_ml',
        'notes',
        'category',
        'carton_size',
        'image_path',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function purchases()
    {
        return $this->hasMany(Purchase::class);
    }

    /**
     * All sales for this item via purchases.
     */
    public function sales()
    {
        return $this->hasManyThrough(Sale::class, Purchase::class);
    }

    /**
     * Convenience accessor for a full image URL.
     */
    public function getImageUrlAttribute()
    {
        if (!$this->image_path) {
            return null;
        }
        $path = ltrim($this->image_path, '/');
        // If path points to public/images/* serve directly
        if (str_starts_with($path, 'images/')) {
            // If file exists, serve it as-is
            if (is_file(public_path($path))) {
                return asset($path);
            }
            // Fallback: try images/beverages/<basename> when original missing and not already beverages
            if (!str_starts_with($path, 'images/beverages/')) {
                $fallback = 'images/beverages/' . basename($path);
                if (is_file(public_path($fallback))) {
                    return asset($fallback);
                }
            }
            // As last resort, still return asset path (may 404) to avoid breaking markup
            return asset($path);
        }
        // Otherwise assume stored in storage/app/public
        return asset('storage/' . $path);
    }

    protected static function booted()
    {
        static::creating(function (Item $item) {
            if (empty($item->sku)) {
                $item->sku = static::generateSku($item);
            }
        });
    }

    /**
     * Computed: total profit/loss across all purchases and their sales for this item.
     * Revenue = sum(selling_price * quantity_sold)
     * Cost = sum(purchase.unit_cost * total_quantity_sold)
     */
    public function getProfitLossAttribute()
    {
        // Ensure relations are available without extra queries when eager loaded
        $revenue = $this->purchases->sum(function ($p) {
            return $p->sales->sum(function ($s) {
                return (float) $s->selling_price * (int) $s->quantity_sold;
            });
        });
        $cost = $this->purchases->sum(function ($p) {
            return (float) $p->unit_cost * (int) $p->total_quantity_sold;
        });
        return $revenue - $cost;
    }

    /**
     * Generate a unique SKU for the given item (per user).
     */
    public static function generateSku(Item $item): string
    {
        // Base from name: alphanumeric uppercase, max 8 chars
        $base = (string) Str::of($item->name ?? 'ITEM')
            ->upper()
            ->replaceMatches('/[^A-Z0-9]+/', '')
            ->substr(0, 8);
        if ($base === '') {
            $base = 'ITEM';
        }

        $sku = $base;
        $i = 1;
        while (static::where('user_id', $item->user_id)->where('sku', $sku)->exists()) {
            $sku = $base . '-' . str_pad((string) $i, 3, '0', STR_PAD_LEFT);
            $i++;
        }
        return $sku;
    }
}
