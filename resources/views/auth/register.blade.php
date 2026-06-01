@extends('layouts.app')

@section('title', 'Create account - Student Inquiry System')

@section('content')
<div class="student-auth-shell">
    <aside class="student-auth-brand">
        <div class="student-auth-logo">
            <span><i class="fas fa-graduation-cap"></i></span>
            <div>
                <strong>Student Inquiry</strong>
                <small>System</small>
            </div>
        </div>

        <div class="student-auth-copy">
            <h1>Create your academic support account</h1>
            <p>Join the portal where student concerns, department responses, and inquiry updates stay organized.</p>
        </div>

        <div class="student-auth-shapes" aria-hidden="true">
            <span class="shape-one"></span>
            <span class="shape-two"></span>
        </div>

        <div class="student-auth-benefits">
            <div>
                <span><i class="far fa-comment-dots"></i></span>
                <p><strong>Submit Inquiries Easily</strong><small>Send questions to department heads from anywhere, anytime.</small></p>
            </div>
            <div>
                <span><i class="far fa-clipboard"></i></span>
                <p><strong>Track Your Requests</strong><small>Monitor the status of every inquiry in real time.</small></p>
            </div>
            <div>
                <span><i class="far fa-map"></i></span>
                <p><strong>Academic Support</strong><small>Get help with enrollment, grades, schedules, and more.</small></p>
            </div>
        </div>
    </aside>

    <main class="student-auth-main">
        <div class="student-auth-card student-auth-card-wide">
            <div class="student-auth-heading">
                <h2>Create your account</h2>
                <p>Enter your details to start using the inquiry portal.</p>
            </div>

            <form method="POST" action="{{ route('register') }}" class="student-auth-form">
                @csrf

                <div class="student-auth-grid">
                    <div class="student-auth-field">
                        <label for="name">Full name</label>
                        <div class="student-auth-input">
                            <i class="far fa-user"></i>
                            <input id="name" type="text" class="@error('name') is-invalid @enderror" name="name" value="{{ old('name') }}" placeholder="Juan Dela Cruz" required autofocus>
                        </div>
                        @error('name')
                            <div class="invalid-feedback d-block">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="student-auth-field">
                        <label for="user_identifier">Student or staff ID</label>
                        <div class="student-auth-input">
                            <i class="far fa-id-card"></i>
                            <input id="user_identifier" type="text" class="@error('user_identifier') is-invalid @enderror" name="user_identifier" value="{{ old('user_identifier') }}" placeholder="STU-2026-001" required>
                        </div>
                        @error('user_identifier')
                            <div class="invalid-feedback d-block">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="student-auth-field">
                    <label for="email">Email address</label>
                    <div class="student-auth-input">
                        <i class="far fa-envelope"></i>
                        <input id="email" type="email" class="@error('email') is-invalid @enderror" name="email" value="{{ old('email') }}" placeholder="student@university.edu" required>
                    </div>
                    @error('email')
                        <div class="invalid-feedback d-block">{{ $message }}</div>
                    @enderror
                </div>

                <div class="student-auth-grid">
                    <div class="student-auth-field">
                        <label for="user_type">Type of user</label>
                        <div class="student-auth-input student-auth-select">
                            <i class="fas fa-users"></i>
                            <select id="user_type" name="user_type" class="@error('user_type') is-invalid @enderror" required>
                                <option value="student" @selected(old('user_type', 'student') === 'student')>Student</option>
                                <option value="department_admin" @selected(old('user_type') === 'department_admin')>Department Head</option>
                                <option value="super_admin" @selected(old('user_type') === 'super_admin')>Admin</option>
                            </select>
                        </div>
                        @error('user_type')
                            <div class="invalid-feedback d-block">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="student-auth-field" id="department-field">
                        <label for="department_id">Department</label>
                        <div class="student-auth-input student-auth-select">
                            <i class="far fa-building"></i>
                            <select id="department_id" name="department_id" class="@error('department_id') is-invalid @enderror">
                                <option value="">Choose department</option>
                                @foreach ($departments as $department)
                                    <option value="{{ $department->id }}" @selected(old('department_id') == $department->id)>
                                        {{ $department->name }}
                                    </option>
                                @endforeach
                            </select>
                        </div>
                        @error('department_id')
                            <div class="invalid-feedback d-block">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="student-auth-grid">
                    <div class="student-auth-field">
                        <label for="password">Password</label>
                        <div class="student-auth-input">
                            <i class="fas fa-lock"></i>
                            <input id="password" type="password" class="@error('password') is-invalid @enderror" name="password" placeholder="Enter your password" required>
                            <button type="button" class="password-toggle" aria-label="Show password" data-target="password">
                                <i class="far fa-eye"></i>
                            </button>
                        </div>
                        @error('password')
                            <div class="invalid-feedback d-block">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="student-auth-field">
                        <label for="password_confirmation">Confirm password</label>
                        <div class="student-auth-input">
                            <i class="fas fa-lock"></i>
                            <input id="password_confirmation" type="password" name="password_confirmation" placeholder="Confirm your password" required>
                            <button type="button" class="password-toggle" aria-label="Show password" data-target="password_confirmation">
                                <i class="far fa-eye"></i>
                            </button>
                        </div>
                    </div>
                </div>

                <button type="submit" class="student-auth-submit">Create account</button>
            </form>

            <div class="student-auth-footer">
                <p>Already have an account? <a href="{{ route('login') }}">Sign in</a></p>
            </div>
        </div>
    </main>
</div>
@endsection

@include('auth.partials.student-auth-assets')

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
