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
        'uom_type', // unit | volume | weight
        'carton_size',
        'image_path',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
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
     * Loss entries related to this item.
     */
    public function losses()
    {
        return $this->hasMany(Loss::class);
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
        // If path points to items/* (historical uploads), try public, then images basenames, then storage
        if (str_starts_with($path, 'items/')) {
            if (is_file(public_path($path))) {
                return asset($path);
            }
            $basename = basename($path);
            // Prefer a matching file under public/images first
            $direct = 'images/' . $basename;
            if (is_file(public_path($direct))) {
                return asset($direct);
            }
            $bev = 'images/beverages/' . $basename;
            if (is_file(public_path($bev))) {
                return asset($bev);
            }
            // fall back to storage in case files are saved there
            return asset('storage/' . $path);
        }
        // If path is a bare filename or unknown prefix, try resolving under public/images/*
        $basename = basename($path);
        if ($basename && $basename === $path) {
            $direct = 'images/' . $basename;
            if (is_file(public_path($direct))) {
                return asset($direct);
            }
            $bev = 'images/beverages/' . $basename;
            if (is_file(public_path($bev))) {
                return asset($bev);
            }
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
        // Include loss cost (COGS for lost quantities)
        $lossCost = $this->getLossCost();
        return $revenue - $cost - $lossCost;
    }

    /**
     * Compute loss cost for this item by valuing each loss at its purchase exact unit cost
     * when available, otherwise falling back to weighted average unit cost across purchases.
     */
    protected function getLossCost(): float
    {
        if (!$this->relationLoaded('losses')) {
            $this->loadMissing('losses');
        }

        // Weighted average unit cost across purchases as fallback
        $totalUnits = (int) $this->purchases->sum(function ($p) {
            return (int) ($p->quantity ?? 0);
        });
        $totalCost = (float) $this->purchases->sum(function ($p) {
            return (float) ($p->unit_cost * (int) ($p->quantity ?? 0));
        });
        $avgUnitCost = $totalUnits > 0 ? ($totalCost / $totalUnits) : 0.0;

        $sum = 0.0;
        foreach ($this->losses as $loss) {
            $unitCost = $avgUnitCost;
            if ($loss->purchase) {
                $unitCost = (float) $loss->purchase->exact_unit_cost;
            }
            $sum += $unitCost * (int) $loss->quantity;
        }
        return (float) $sum;
    }

    /**
     * Base unit string for this item based on uom_type.
     */
    public function baseUnit(): string
    {
        $type = $this->uom_type ?? 'unit';
        return match ($type) {
            'volume' => 'ml',
            'weight' => 'g',
            default => 'unit',
        };
    }

    /**
     * Convert a human-entered quantity to base units.
     * Example: (1.5, 'kg') => 1500 when uom_type = weight. (2, 'l') => 2000 when volume.
     */
    public function toBaseQuantity(float $qty, ?string $unit = null): int
    {
        $type = $this->uom_type ?? 'unit';
        $u = strtolower($unit ?? $this->baseUnit());
        switch ($type) {
            case 'volume':
                if ($u === 'l' || $u === 'lt' || $u === 'liter' || $u === 'litre') {
                    return (int) round($qty * 1000);
                }
                // assume ml
                return (int) round($qty);
            case 'weight':
                if ($u === 'kg' || $u === 'kgs' || $u === 'kilogram') {
                    return (int) round($qty * 1000);
                }
                // assume g
                return (int) round($qty);
            default:
                // unit-count items
                return (int) round($qty);
        }
    }

    /**
     * Format a base quantity for display with the best unit.
     */
    public function formatBaseQuantity(int $baseQty): string
    {
        $type = $this->uom_type ?? 'unit';
        switch ($type) {
            case 'volume':
                if ($baseQty % 1000 === 0) {
                    return ($baseQty / 1000) . ' L';
                }
                return $baseQty . ' ml';
            case 'weight':
                // Always show weight in kg with decimals (no grams)
                $kg = $baseQty / 1000;
                // Trim trailing zeros and dot for clean display (e.g., 1.500 -> 1.5, 2.000 -> 2)
                $formatted = rtrim(rtrim(number_format($kg, 3, '.', ''), '0'), '.');
                if ($formatted === '') {
                    $formatted = '0';
                }
                return $formatted . ' kg';
            default:
                return $baseQty . ' pcs';
        }
    }

    /**
     * Generate a unique SKU for the given item (global across shop).
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
        while (static::where('sku', $sku)->exists()) {
            $sku = $base . '-' . str_pad((string) $i, 3, '0', STR_PAD_LEFT);
            $i++;
        }
        return $sku;
    }
}
