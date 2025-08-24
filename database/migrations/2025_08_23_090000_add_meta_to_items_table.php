<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('items', function (Blueprint $table) {
            $table->string('image_path')->nullable()->after('notes');
            $table->string('category')->nullable()->after('sku');
            $table->integer('carton_size')->nullable()->after('unit_name');
        });
    }

    public function down(): void
    {
        Schema::table('items', function (Blueprint $table) {
            $table->dropColumn(['image_path','category','carton_size']);
        });
    }
};
