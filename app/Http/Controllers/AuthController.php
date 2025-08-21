<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function showLogin()
    {
        if (Auth::check()) {
            return redirect()->route('home');
        }
        return view('auth.login');
    }

    public function login(Request $request)
    {
        $validated = $request->validate([
            // Allow numbers starting with 255 followed by 9 digits OR 0 followed by 8 digits
            'phone' => ['required','regex:/^(?:255\d{9}|0\d{8})$/'],
            'password' => ['required','string'],
        ]);

        $credentials = ['phone' => $validated['phone'], 'password' => $validated['password']];

        if (Auth::attempt($credentials, $request->boolean('remember'))) {
            // Regenerate session ID and bind it as the user's active session
            $request->session()->regenerate();
            $user = Auth::user();
            $user->current_session_id = $request->session()->getId();
            $user->save();

            return redirect()->intended(route('home'));
        }

        return back()->withErrors([
            'phone' => 'The provided credentials do not match our records.',
        ])->onlyInput('phone');
    }

    public function logout(Request $request)
    {
        // Clear the tracked session so another login can take over
        if (Auth::check()) {
            $user = Auth::user();
            $user->current_session_id = null;
            $user->save();
        }
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect()->route('login');
    }
}
