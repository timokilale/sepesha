@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Create New User</h1>
  
  <div class="bg-white rounded border p-4">
    <form method="POST" action="{{ route('users.store') }}">
      @csrf
      
      <div class="grid grid-cols-1 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Full Name</label>
          <input type="text" name="name" value="{{ old('name') }}" class="w-full border rounded px-3 py-2" required />
          @error('name')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>

        <div>
          <label class="block text-sm text-gray-700 mb-1">Email Address</label>
          <input type="email" name="email" value="{{ old('email') }}" class="w-full border rounded px-3 py-2" required />
          @error('email')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>

        <div>
          <label class="block text-sm text-gray-700 mb-1">Phone Number (Optional)</label>
          <input type="text" name="phone" value="{{ old('phone') }}" class="w-full border rounded px-3 py-2" />
          @error('phone')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>

        <div>
          <label class="block text-sm text-gray-700 mb-1">Role</label>
          <select name="role" class="w-full border rounded px-3 py-2" required>
            <option value="">-- Select Role --</option>
            <option value="admin" @selected(old('role') === 'admin')>Admin (Full Access)</option>
            <option value="seller" @selected(old('role') === 'seller')>Seller (Limited Access)</option>
          </select>
          @error('role')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>

      <div class="mt-4 p-3 bg-blue-50 rounded text-sm text-blue-800">
        <strong>Note:</strong> A random password will be generated automatically. You'll receive the login credentials after creating the user.
      </div>

      <div class="flex flex-col sm:flex-row gap-2 sm:gap-3 mt-6">
        <button type="submit" class="px-3 py-2 bg-indigo-600 text-white rounded">Create User</button>
        <a href="{{ route('users.index') }}" class="px-3 py-2 bg-gray-100 rounded text-center">Cancel</a>
      </div>
    </form>
  </div>
</div>
@endsection
