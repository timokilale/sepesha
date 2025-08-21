@extends('layouts.app')

@section('content')
<div class="max-w-lg mx-auto px-4 sm:px-6 lg:px-8">
  <div class="bg-white rounded shadow p-6" x-data="{ show: false }">
    <div class="flex items-center justify-between mb-4">
      <h1 class="text-xl font-semibold text-gray-800">Change Password</h1>
      <button type="button" @click="show = !show" class="text-sm text-gray-600 hover:text-gray-800">
        <span x-text="show ? 'Hide all' : 'Show all'"></span>
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
        <a href="{{ route('dashboard') }}" class="px-4 py-2 bg-gray-100 rounded text-center">Cancel</a>
      </div>
    </form>
  </div>
</div>
@endsection
