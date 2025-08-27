<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        $driver = DB::getDriverName();
        if ($driver === 'mysql') {
            DB::statement('ALTER TABLE purchases MODIFY cost_price DECIMAL(12,4)');
        } elseif ($driver === 'pgsql') {
            DB::statement('ALTER TABLE purchases ALTER COLUMN cost_price TYPE DECIMAL(12,4)');
        } else {
            // SQLite and others: skip; SQLite stores NUMERIC without strict scale.
        }
    }

    public function down(): void
    {
        $driver = DB::getDriverName();
        if ($driver === 'mysql') {
            DB::statement('ALTER TABLE purchases MODIFY cost_price DECIMAL(10,2)');
        } elseif ($driver === 'pgsql') {
            DB::statement('ALTER TABLE purchases ALTER COLUMN cost_price TYPE DECIMAL(10,2)');
        } else {
            // SQLite and others: skip revert.
        }
    }
};
