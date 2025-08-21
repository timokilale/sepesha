@extends('layouts.app')

@section('content')
<div class="max-w-lg mx-auto px-4 sm:px-6 lg:px-8">
  <div class="bg-white rounded shadow p-6" x-data="{ show: false }">
    <div class="flex items-center justify-between mb-4">
      <h1 class="text-xl font-semibold text-gray-800">Change Password</h1>
      <button type="button" @click="show = !show" class="p-2 text-gray-500 hover:text-gray-700" :aria-label="show ? 'Hide passwords' : 'Show passwords'">
        <!-- Eye (show) -->
        <svg x-show="!show" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 010-.644C3.423 7.51 7.36 4.5 12 4.5c4.64 0 8.577 3.01 9.964 7.178.07.215.07.429 0 .644C20.577 16.49 16.64 19.5 12 19.5c-4.64 0-8.577-3.01-9.964-7.178z" />
          <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
        </svg>
        <!-- Eye-off (hide) -->
        <svg x-show="show" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c1.51 0 2.944-.318 4.236-.889M6.228 6.228A10.45 10.45 0 0112 4.5c4.756 0 8.774 3.162 10.066 7.5a10.523 10.523 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l12.544 12.544M12 8.25a3.75 3.75 0 013.75 3.75" />
        </svg>
      </button>
    </div>

    <form method="POST" action="{{ route('password.update') }}" class="space-y-4">
      @csrf

      <div>
        <label class="block text-sm text-gray-700 mb-1">Current password</label>
        <input :type="show ? 'text' : 'password'" name="current_password" class="w-full border rounded px-3 py-2" required />
        @error('current_password')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">New password</label>
          <input :type="show ? 'text' : 'password'" name="password" class="w-full border rounded px-3 py-2" required />
          @error('password')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
        <div>
          <label class="block text-sm text-gray-700 mb-1">Confirm new password</label>
          <input :type="show ? 'text' : 'password'" name="password_confirmation" class="w-full border rounded px-3 py-2" required />
        </div>
      </div>

      <div class="flex flex-col sm:flex-row gap-2 sm:gap-3">
        <button class="px-4 py-2 bg-indigo-600 text-white rounded">Update Password</button>
        <a href="{{ route('home') }}" class="px-4 py-2 bg-gray-100 rounded text-center">Cancel</a>
      </div>
    </form>
  </div>
</div>
@endsection
