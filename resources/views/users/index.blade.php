@extends('layouts.app')

@section('content')
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  <div class="flex flex-col sm:flex-row sm:items-center justify-between mb-3 gap-3">
    <h1 class="text-xl font-semibold text-gray-900">User Management</h1>
    <a href="{{ route('users.create') }}" class="px-3 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700 text-center">Add User</a>
  </div>

  <div class="bg-white rounded border overflow-hidden">
    <div class="overflow-x-auto">
      <table class="data-table min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase hidden sm:table-cell">Phone</th>
            <th class="px-2 sm:px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Role</th>
            <th class="px-2 sm:px-4 py-2 text-right">Actions</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          @forelse ($users as $user)
          <tr>
            <td class="px-2 sm:px-4 py-2 text-gray-800">
              <div class="font-medium">{{ $user->name }}</div>
              <div class="text-sm text-gray-500 sm:hidden">{{ $user->email }} • {{ $user->phone ?: 'No phone' }}</div>
            </td>
            <td class="px-2 sm:px-4 py-2 hidden sm:table-cell">{{ $user->email }}</td>
            <td class="px-2 sm:px-4 py-2 hidden sm:table-cell">{{ $user->phone ?: '—' }}</td>
            <td class="px-2 sm:px-4 py-2">
              <span class="inline-block px-2 py-0.5 text-xs rounded {{ $user->isAdmin() ? 'bg-blue-100 text-blue-800' : 'bg-green-100 text-green-800' }}">
                {{ ucfirst($user->role) }}
              </span>
            </td>
            <td class="px-2 sm:px-4 py-2 text-right">
              <div class="flex flex-col items-end gap-1">
                <a href="{{ route('users.edit', $user->id) }}" class="text-indigo-600 text-sm hover:text-indigo-800">Edit</a>
                <form action="{{ route('users.reset-password', $user->id) }}" method="POST" class="inline">
                  @csrf
                  <button class="text-orange-600 text-sm hover:text-orange-800" onclick="return confirm('Reset password for {{ $user->name }}?')">Reset Password</button>
                </form>
                @if($user->id !== auth()->id())
                <form action="{{ route('users.destroy', $user->id) }}" method="POST" class="inline">
                  @csrf
                  @method('DELETE')
                  <button class="text-red-600 text-sm hover:text-red-800" onclick="return confirm('Delete {{ $user->name }}? This cannot be undone.')">Delete</button>
                </form>
                @endif
              </div>
            </td>
          </tr>
          @empty
          <tr><td colspan="5" class="px-2 sm:px-4 py-4 text-gray-500">No users yet.</td></tr>
          @endforelse
        </tbody>
      </table>
    </div>
  </div>
</div>
@endsection
