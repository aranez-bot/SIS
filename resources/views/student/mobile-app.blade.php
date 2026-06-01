@extends('layouts.app')

@section('title', 'Mobile App Download')

@push('styles')
    <style>
        .mobile-app-hero {
            background: linear-gradient(135deg, #4f63d9 0%, #42a39a 100%);
            border-radius: 12px;
            box-shadow: 0 18px 42px rgba(79, 99, 217, 0.18);
            color: white;
            padding: 1.5rem;
        }

        .mobile-app-hero h1,
        .mobile-app-hero p {
            color: white;
        }

        .mobile-app-panel {
            border: 1px solid var(--border-color);
            border-radius: 12px;
            box-shadow: var(--shadow-sm);
        }

        .mobile-app-icon {
            align-items: center;
            background: rgba(79, 99, 217, 0.1);
            border-radius: 12px;
            color: var(--primary-color);
            display: inline-flex;
            font-size: 2rem;
            height: 4.5rem;
            justify-content: center;
            width: 4.5rem;
        }

        .mobile-app-meta {
            display: grid;
            gap: 0.75rem;
            grid-template-columns: repeat(3, minmax(0, 1fr));
        }

        .mobile-app-meta div {
            background: #f8fafc;
            border: 1px solid var(--border-color);
            border-radius: 10px;
            padding: 0.85rem;
        }

        .mobile-app-meta span {
            color: var(--muted-color);
            display: block;
            font-size: 0.78rem;
            font-weight: 700;
            text-transform: uppercase;
        }

        .mobile-app-meta strong {
            color: var(--dark-color);
            display: block;
            margin-top: 0.25rem;
        }

        .install-step {
            align-items: flex-start;
            display: flex;
            gap: 0.8rem;
        }

        .install-step span {
            align-items: center;
            background: var(--primary-color);
            border-radius: 999px;
            color: white;
            display: inline-flex;
            flex: 0 0 2rem;
            font-weight: 800;
            height: 2rem;
            justify-content: center;
            width: 2rem;
        }

        @media (max-width: 767px) {
            .mobile-app-meta {
                grid-template-columns: 1fr;
            }
        }
    </style>
@endpush

@section('content')
    <div @guest class="main-content" @endguest>
    @guest
        <nav class="navbar navbar-expand-lg mb-4">
            <div class="container-fluid px-0">
                <a class="navbar-brand" href="{{ url('/') }}">
                    <i class="fas fa-comments"></i> Inquiry System
                </a>
                <div class="d-flex gap-2">
                    <a href="{{ route('login') }}" class="btn btn-secondary">
                        <i class="fas fa-arrow-right-to-bracket"></i> Login
                    </a>
                    <a href="{{ route('register') }}" class="btn btn-primary">
                        <i class="fas fa-user-plus"></i> Register
                    </a>
                </div>
            </div>
        </nav>
    @endguest

    <div class="mobile-app-hero mb-4">
        <div class="d-flex flex-wrap gap-3 justify-content-between align-items-center">
            <div>
                <p class="mb-2 fw-semibold opacity-75">Android Installer</p>
                <h1 class="mb-2">
                    <i class="fas fa-mobile-alt"></i> Student Inquiry Mobile App
                </h1>
                <p class="mb-0">Install the APK on your Android phone for faster inquiry tracking and updates.</p>
            </div>
            @auth
                <a href="{{ route('dashboard') }}" class="btn btn-light">
                    <i class="fas fa-arrow-left"></i> Dashboard
                </a>
            @else
                <a href="{{ url('/') }}" class="btn btn-light">
                    <i class="fas fa-arrow-left"></i> Web App
                </a>
            @endauth
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-7">
            <div class="card mobile-app-panel h-100">
                <div class="card-body p-4">
                    <div class="d-flex flex-wrap gap-3 align-items-center mb-4">
                        <div class="mobile-app-icon">
                            <i class="fab fa-android"></i>
                        </div>
                        <div>
                            <h4 class="mb-1">{{ $apkFileName }}</h4>
                            <p class="text-muted mb-0">
                                @if ($apkExists)
                                    Ready to download
                                @else
                                    APK file not uploaded yet
                                @endif
                            </p>
                        </div>
                    </div>

                    <div class="mobile-app-meta mb-4">
                        <div>
                            <span>Status</span>
                            <strong>{{ $apkExists ? 'Available' : 'Unavailable' }}</strong>
                        </div>
                        <div>
                            <span>Source</span>
                            <strong>{{ $apkSource }}</strong>
                        </div>
                        <div>
                            <span>Size</span>
                            <strong>{{ $apkSize ?? 'Pending' }}</strong>
                        </div>
                    </div>

                    @if ($apkExists)
                        <a href="{{ $apkDownloadUrl }}" class="btn btn-primary btn-lg">
                            <i class="fas fa-download"></i> Download APK
                        </a>
                    @else
                        <button type="button" class="btn btn-secondary btn-lg" disabled>
                            <i class="fas fa-download"></i> Download APK
                        </button>
                    @endif
                </div>
            </div>
        </div>

        <div class="col-lg-5">
            <div class="card mobile-app-panel h-100">
                <div class="card-header section-card-header">
                    <h5 class="mb-0">
                        <i class="fas fa-list-check"></i> Install Guide
                    </h5>
                </div>
                <div class="card-body p-4">
                    <div class="install-step mb-3">
                        <span>1</span>
                        <div>
                            <strong>Download the APK</strong>
                            <p class="text-muted mb-0">Tap the download button and wait for the file to finish.</p>
                        </div>
                    </div>
                    <div class="install-step mb-3">
                        <span>2</span>
                        <div>
                            <strong>Open the file</strong>
                            <p class="text-muted mb-0">Choose the downloaded APK from your browser or file manager.</p>
                        </div>
                    </div>
                    <div class="install-step">
                        <span>3</span>
                        <div>
                            <strong>Allow installation</strong>
                            <p class="text-muted mb-0">If Android asks, allow installation from your browser, then tap Install.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </div>
@endsection
