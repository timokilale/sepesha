<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $admin = User::where('email', 'admin@example.com')->first();
        if (!$admin) {
            User::create([
                'name' => 'Admin',
                'email' => 'admin@example.com',
                'phone' => '255714609135',
                'password' => Hash::make('password123'),
            ]);
        } else {
            // Ensure phone is set
            if (!$admin->phone) {
                $admin->phone = '255714609135';
                $admin->save();
            }
        }
    }
}
