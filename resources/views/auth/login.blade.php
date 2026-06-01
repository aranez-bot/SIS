@extends('layouts.app')

@section('title', 'Sign in - Student Inquiry System')

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
            <h1>Your academic support portal</h1>
            <p>A dedicated platform for students to submit, track, and resolve academic inquiries fast and hassle-free.</p>
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
        <div class="student-auth-card">
            <div class="student-auth-heading">
                <h2>Welcome back, student</h2>
                <p>Sign in with your student account to continue.</p>
            </div>

            <form method="POST" action="{{ route('login') }}" class="student-auth-form">
                @csrf

                <div class="student-auth-field">
                    <label for="email">Student email address</label>
                    <div class="student-auth-input">
                        <i class="far fa-envelope"></i>
                        <input id="email" type="email" class="@error('email') is-invalid @enderror" name="email" value="{{ old('email') }}" placeholder="student@university.edu" required autofocus>
                    </div>
                    @error('email')
                        <div class="invalid-feedback d-block">{{ $message }}</div>
                    @enderror
                </div>

                <div class="student-auth-field">
                    <div class="student-auth-label-row">
                        <label for="password">Password</label>
                        <a href="#" aria-disabled="true">Forgot password?</a>
                    </div>
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

                <button type="submit" class="student-auth-submit">Sign in</button>
            </form>

            <div class="student-auth-footer">
                <p>New student? <a href="{{ route('register') }}">Create your account</a></p>
            </div>
        </div>
    </main>
</div>
@endsection

@include('auth.partials.student-auth-assets')
