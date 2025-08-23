<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('purchases', function (Blueprint $table) {
            $table->foreignId('item_id')->nullable()->after('user_id')->constrained('items')->onDelete('set null');
            $table->integer('cartons')->nullable()->after('quantity');
            $table->integer('loose_units')->nullable()->after('cartons');
            $table->integer('units_per_carton')->nullable()->after('loose_units');
            $table->decimal('carton_cost', 10, 2)->nullable()->after('units_per_carton');
        });
    }

    public function down(): void
    {
        Schema::table('purchases', function (Blueprint $table) {
            $table->dropConstrainedForeignId('item_id');
            $table->dropColumn(['cartons', 'loose_units', 'units_per_carton', 'carton_cost']);
        });
    }
};
