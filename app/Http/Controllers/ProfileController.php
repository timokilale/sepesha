<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class ProfileController extends Controller
{
    public function edit()
    {
        return view('auth.profile');
    }

    public function update(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => ['required','string','max:255'],
            'phone' => ['required','regex:/^(?:255\d{9}|0\d{8})$/','unique:users,phone,'.$user->id],
            'email' => ['required','email','unique:users,email,'.$user->id],
        ]);

        $user->fill($validated);

        // If any password fields are present, validate and update password
        if ($request->filled('current_password') || $request->filled('password') || $request->filled('password_confirmation')) {
            $request->validate([
                'current_password' => ['required','current_password'],
                'password' => ['required','string','min:8','confirmed'],
            ]);

            $user->password = Hash::make($request->password);

            // Regenerate session id and bind as only active session
            $request->session()->regenerate();
            $user->current_session_id = $request->session()->getId();
        }

        $user->save();

        return redirect()->route('profile.edit')->with('success', 'Profile updated successfully.');
    }
}
