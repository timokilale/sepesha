<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class PasswordController extends Controller
{
    public function edit()
    {
        return view('auth.password');
    }

    public function update(Request $request)
    {
        $request->validate([
            'current_password' => ['required','current_password'],
            'password' => ['required','string','min:8','confirmed'],
        ]);

        $user = $request->user();
        $user->password = Hash::make($request->password);

        // Regenerate session id and bind as the only active session
        $request->session()->regenerate();
        $user->current_session_id = $request->session()->getId();
        $user->save();

        return redirect()->route('home')->with('success', 'Password updated successfully.');
    }
}
