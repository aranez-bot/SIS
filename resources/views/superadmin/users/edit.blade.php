@extends('layouts.app')

@section('title', 'Edit User')

@section('content')
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="mb-0">
            <i class="fas fa-user-edit"></i> Edit User
        </h1>
        <a href="{{ route('superadmin.users.index') }}" class="btn btn-outline-secondary">
            <i class="fas fa-arrow-left"></i> Back
        </a>
    </div>

    <div class="card">
        <div class="card-header section-card-header">
            <h5 class="mb-0">{{ $user->name }}</h5>
        </div>
        <div class="card-body">
            <form method="POST" action="{{ route('superadmin.users.update', $user) }}">
                @csrf
                @method('PUT')

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="name" class="form-label">Full Name</label>
                        <input type="text" class="form-control @error('name') is-invalid @enderror" id="name" name="name" value="{{ old('name', $user->name) }}" required>
                        @error('name')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="user_identifier" class="form-label">User ID</label>
                        <input type="text" class="form-control @error('user_identifier') is-invalid @enderror" id="user_identifier" name="user_identifier" value="{{ old('user_identifier', $user->user_identifier) }}">
                        @error('user_identifier')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="email" class="form-label">Email Address</label>
                        <input type="email" class="form-control @error('email') is-invalid @enderror" id="email" name="email" value="{{ old('email', $user->email) }}" required>
                        @error('email')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="user_type" class="form-label">Type of User</label>
                        <select class="form-select @error('user_type') is-invalid @enderror" id="user_type" name="user_type" required>
                            <option value="super_admin" @selected(old('user_type', $user->user_type) === 'super_admin')>Admin</option>
                            <option value="student" @selected(old('user_type', $user->user_type) === 'student')>Student</option>
                            <option value="department_admin" @selected(old('user_type', $user->user_type) === 'department_admin')>Department Head</option>
                        </select>
                        @error('user_type')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="mb-4" id="department-field">
                    <label for="department_id" class="form-label">Department</label>
                    <select class="form-select @error('department_id') is-invalid @enderror" id="department_id" name="department_id">
                        <option value="">Choose department</option>
                        @foreach ($departments as $department)
                            <option value="{{ $department->id }}" @selected(old('department_id', $user->department_id) == $department->id)>
                                {{ $department->name }}
                            </option>
                        @endforeach
                    </select>
                    @error('department_id')
                        <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>

                <div class="form-check form-switch mb-4">
                    <input class="form-check-input" type="checkbox" role="switch" id="is_active" name="is_active" value="1" @checked(old('is_active', $user->is_active)) @disabled($user->id === auth()->id())>
                    <label class="form-check-label" for="is_active">Active account</label>
                    @if ($user->id === auth()->id())
                        <div class="form-text">You cannot deactivate your own account.</div>
                    @endif
                </div>

                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> Update User
                </button>
            </form>
        </div>
    </div>
@endsection

@push('scripts')
    <script>
        const userTypeSelect = document.getElementById('user_type');
        const departmentField = document.getElementById('department-field');
        const departmentSelect = document.getElementById('department_id');

        function toggleDepartmentField() {
            const needsDepartment = userTypeSelect.value === 'department_admin';
            departmentField.style.display = needsDepartment ? 'block' : 'none';
            departmentSelect.required = needsDepartment;
        }

        userTypeSelect.addEventListener('change', toggleDepartmentField);
        toggleDepartmentField();
    </script>
@endpush
