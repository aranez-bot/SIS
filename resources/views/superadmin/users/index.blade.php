@extends('layouts.app')

@section('title', 'Manage Users')

@section('content')
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="mb-0">
            <i class="fas fa-users"></i> User Management
        </h1>
        <div class="d-flex gap-2">
            <a href="{{ route('superadmin.users.create') }}" class="btn btn-secondary">
                <i class="fas fa-user-plus"></i> Add User
            </a>
            <a href="{{ route('superadmin.users.create-admin') }}" class="btn btn-primary">
                <i class="fas fa-user-shield"></i> Create Department Admin
            </a>
        </div>
    </div>

    <div class="card">
        <div class="card-header section-card-header">
            <h5 class="mb-0">All Users</h5>
        </div>
        <div class="table-responsive">
            <table class="table mb-0">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>User ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>User Type</th>
                        <th>Status</th>
                        <th>Department</th>
                        <th>Joined</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($users as $user)
                        <tr>
                            <td><strong>#{{ $user->id }}</strong></td>
                            <td>
                                @if ($user->user_identifier)
                                    <strong>{{ $user->user_identifier }}</strong>
                                @else
                                    <span class="text-muted">-</span>
                                @endif
                            </td>
                            <td>
                                <strong>{{ $user->name }}</strong>
                            </td>
                            <td>{{ $user->email }}</td>
                            <td>
                                @if ($user->isStudent())
                                    <span class="badge bg-info">Student</span>
                                @elseif ($user->isDepartmentAdmin())
                                    <span class="badge bg-warning">Department Admin</span>
                                @else
                                    <span class="badge bg-danger">Admin</span>
                                @endif
                            </td>
                            <td>
                                @if ($user->is_active)
                                    <span class="badge bg-success">Active</span>
                                @else
                                    <span class="badge bg-secondary">Inactive</span>
                                @endif
                            </td>
                            <td>
                                @if ($user->department)
                                    {{ $user->department->name }}
                                @else
                                    <span class="text-muted">-</span>
                                @endif
                            </td>
                            <td>
                                <small class="text-muted">{{ $user->created_at->format('M d, Y') }}</small>
                            </td>
                            <td>
                                <a href="{{ route('superadmin.users.edit', $user) }}" class="btn btn-sm btn-primary">
                                    <i class="fas fa-edit"></i> Edit
                                </a>
                                @if ($user->id !== auth()->id())
                                    <form action="{{ route('superadmin.users.toggle-status', $user) }}" method="POST" style="display: inline;">
                                        @csrf
                                        @method('PATCH')
                                        <button type="submit" class="btn btn-sm btn-secondary">
                                            <i class="fas fa-power-off"></i> {{ $user->is_active ? 'Deactivate' : 'Reactivate' }}
                                        </button>
                                    </form>
                                    <form action="{{ route('superadmin.users.delete', $user) }}" method="POST" style="display: inline;" onsubmit="return confirm('Are you sure?');">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="btn btn-sm btn-danger">
                                            <i class="fas fa-trash"></i> Delete
                                        </button>
                                    </form>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="9" class="text-center py-4 text-muted">
                                <i class="fas fa-inbox"></i> No users
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if ($users->hasPages())
            <div class="card-footer">
                {{ $users->links() }}
            </div>
        @endif
    </div>
@endsection
