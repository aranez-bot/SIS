@extends('layouts.app')

@section('title', 'Role and Permission Management')

@section('content')
    <h1 class="mb-4">
        <i class="fas fa-user-shield"></i> Role and Permission Management
    </h1>

    <div class="row">
        @foreach ($roles as $role => $permissions)
            <div class="col-lg-4 mb-3">
                <div class="card h-100">
                    <div class="card-header section-card-header">
                        <h5 class="mb-0">{{ $role }}</h5>
                    </div>
                    <div class="card-body">
                        <ul class="mb-0">
                            @foreach ($permissions as $permission)
                                <li class="mb-2">{{ $permission }}</li>
                            @endforeach
                        </ul>
                    </div>
                </div>
            </div>
        @endforeach
    </div>

    <div class="card mt-3">
        <div class="card-header section-card-header">
            <h5 class="mb-0">Access Control Notes</h5>
        </div>
        <div class="card-body">
            <p class="mb-2">Route middleware enforces each dashboard area by role: student, department admin, and superadmin.</p>
            <p class="mb-0 text-muted">To change a user's role or department access, open User Management and edit the account.</p>
        </div>
    </div>
@endsection
