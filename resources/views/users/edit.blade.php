@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto px-4">
  <h1 class="text-xl font-semibold text-gray-900 mb-3">Edit User: {{ $user->name }}</h1>
  
  <div class="bg-white rounded border p-4">
    <form method="POST" action="{{ route('users.update', $user->id) }}">
      @csrf
      @method('PUT')
      
      <div class="grid grid-cols-1 gap-4">
        <div>
          <label class="block text-sm text-gray-700 mb-1">Full Name</label>
          <input type="text" name="name" value="{{ old('name', $user->name) }}" class="w-full border rounded px-3 py-2" required />
          @error('name')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>

        <div>
          <label class="block text-sm text-gray-700 mb-1">Email Address</label>
          <input type="email" name="email" value="{{ old('email', $user->email) }}" class="w-full border rounded px-3 py-2" required />
          @error('email')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>

        <div>
          <label class="block text-sm text-gray-700 mb-1">Phone Number (Optional)</label>
          <input type="text" name="phone" value="{{ old('phone', $user->phone) }}" class="w-full border rounded px-3 py-2" />
          @error('phone')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>

        <div>
          <label class="block text-sm text-gray-700 mb-1">Role</label>
          <select name="role" class="w-full border rounded px-3 py-2" required>
            <option value="">-- Select Role --</option>
            <option value="admin" @selected(old('role', $user->role) === 'admin')>Admin (Full Access)</option>
            <option value="seller" @selected(old('role', $user->role) === 'seller')>Seller (Limited Access)</option>
          </select>
          @error('role')<p class="text-red-600 text-sm">{{ $message }}</p>@enderror
        </div>
      </div>

      @if($user->id !== auth()->id())
      <div class="mt-4 p-3 bg-yellow-50 rounded text-sm text-yellow-800">
        <strong>Password:</strong> To reset this user's password, use the "Reset Password" button on the user list.
      </div>
      @endif

      <div class="flex flex-col sm:flex-row gap-2 sm:gap-3 mt-6">
        <button type="submit" class="px-3 py-2 bg-indigo-600 text-white rounded">Update User</button>
        <a href="{{ route('users.index') }}" class="px-3 py-2 bg-gray-100 rounded text-center">Cancel</a>
      </div>
    </form>
  </div>
</div>
@endsection
