<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ config('app.name', 'Student Inquiry System') }}</title>
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=instrument-sans:400,500,600,700" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary: #2563eb;
            --primary-dark: #1d4ed8;
            --teal: #14b8a6;
            --ink: #172033;
            --muted: #64748b;
            --border: #dbe3ef;
            --surface: #ffffff;
        }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: 'Instrument Sans', 'Segoe UI', system-ui, sans-serif;
            color: var(--ink);
            background: #f8fbff;
        }

        .site-nav {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 20;
            background: rgba(255, 255, 255, 0.9);
            border-bottom: 1px solid rgba(219, 227, 239, 0.9);
            backdrop-filter: blur(16px);
        }

        .brand {
            color: var(--ink);
            font-weight: 700;
            text-decoration: none;
        }

        .brand i {
            color: var(--primary);
        }

        .hero {
            min-height: 92vh;
            display: flex;
            align-items: center;
            padding: 7rem 0 4rem;
            background:
                linear-gradient(90deg, rgba(248, 251, 255, 0.98) 0%, rgba(248, 251, 255, 0.90) 46%, rgba(248, 251, 255, 0.35) 100%),
                url('https://images.unsplash.com/photo-1523240795612-9a054b0db644?auto=format&fit=crop&w=1800&q=80') center/cover;
        }

        .hero h1 {
            max-width: 760px;
            font-size: clamp(2.3rem, 5vw, 4.8rem);
            line-height: 1.02;
            font-weight: 700;
            letter-spacing: 0;
        }

        .hero p {
            max-width: 620px;
            color: var(--muted);
            font-size: 1.12rem;
        }

        .btn-primary {
            background: var(--primary);
            border: 0;
            border-radius: 8px;
            font-weight: 700;
            padding: 0.8rem 1.2rem;
        }

        .btn-primary:hover {
            background: var(--primary-dark);
        }

        .btn-outline {
            border: 1px solid var(--border);
            border-radius: 8px;
            color: var(--ink);
            font-weight: 700;
            padding: 0.8rem 1.2rem;
            background: white;
            text-decoration: none;
        }

        .btn-outline:hover {
            border-color: #cbd5e1;
            background: #f8fafc;
            color: var(--primary);
        }

        .metric-strip {
            margin-top: -3rem;
            position: relative;
            z-index: 5;
        }

        .metric-card {
            height: 100%;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 1.25rem;
            box-shadow: 0 14px 35px rgba(15, 23, 42, 0.08);
        }

        .metric-card i {
            width: 2.5rem;
            height: 2.5rem;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 8px;
            color: var(--primary);
            background: #eff6ff;
            margin-bottom: 1rem;
        }

        .metric-card h2 {
            font-size: 1rem;
            font-weight: 700;
            margin-bottom: 0.35rem;
        }

        .metric-card p {
            color: var(--muted);
            margin-bottom: 0;
            font-size: 0.95rem;
        }

        .section {
            padding: 5rem 0;
        }

        .workflow {
            border-top: 1px solid var(--border);
            background: white;
        }

        .workflow-item {
            padding: 1rem 0;
            border-bottom: 1px solid var(--border);
        }

        .workflow-item strong {
            color: var(--ink);
        }

        .workflow-item span {
            color: var(--muted);
        }

        @media (max-width: 768px) {
            .site-nav {
                position: static;
            }

            .hero {
                min-height: auto;
                padding: 4rem 0;
                background:
                    linear-gradient(180deg, rgba(248, 251, 255, 0.98), rgba(248, 251, 255, 0.86)),
                    url('https://images.unsplash.com/photo-1523240795612-9a054b0db644?auto=format&fit=crop&w=1200&q=80') center/cover;
            }

            .metric-strip {
                margin-top: 0;
                padding-top: 1rem;
            }
        }
    </style>
</head>
<body>
    <nav class="site-nav">
        <div class="container py-3 d-flex align-items-center justify-content-between gap-3">
            <a class="brand" href="{{ url('/') }}">
                <i class="fas fa-comments"></i> Student Inquiry System
            </a>
            <div class="d-flex gap-2">
                @auth
                    <a href="{{ route('dashboard') }}" class="btn btn-primary btn-sm">Dashboard</a>
                @else
                    <a href="{{ route('login') }}" class="btn btn-outline btn-sm">Login</a>
                    <a href="{{ route('register') }}" class="btn btn-primary btn-sm">Register</a>
                @endauth
            </div>
        </div>
    </nav>

    <main>
        <section class="hero">
            <div class="container">
                <div class="col-lg-8">
                    <h1>Student Inquiry System</h1>
                    <p class="mt-3 mb-4">A clear workspace for submitting student concerns, routing them to the right department, and keeping every response easy to follow.</p>
                    <div class="d-flex flex-wrap gap-2">
                        @auth
                            <a href="{{ route('dashboard') }}" class="btn btn-primary">
                                <i class="fas fa-chart-line"></i> Open dashboard
                            </a>
                        @else
                            <a href="{{ route('register') }}" class="btn btn-primary">
                                <i class="fas fa-user-plus"></i> Create account
                            </a>
                            <a href="{{ route('login') }}" class="btn btn-outline">
                                <i class="fas fa-arrow-right-to-bracket"></i> Login
                            </a>
                        @endauth
                    </div>
                </div>
            </div>
        </section>

        <section class="metric-strip">
            <div class="container">
                <div class="row g-3">
                    <div class="col-md-4">
                        <div class="metric-card">
                            <i class="fas fa-paper-plane"></i>
                            <h2>Submit clearly</h2>
                            <p>Students send structured inquiries with department, subject, and full context.</p>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="metric-card">
                            <i class="fas fa-inbox"></i>
                            <h2>Manage centrally</h2>
                            <p>Department heads review, prioritize, and respond from a focused inbox.</p>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="metric-card">
                            <i class="fas fa-bell"></i>
                            <h2>Stay updated</h2>
                            <p>Notifications and inquiry history keep everyone aligned on status and replies.</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="section workflow">
            <div class="container">
                <div class="row align-items-start g-4">
                    <div class="col-lg-5">
                        <h2 class="fw-bold mb-3">Built around the real support flow.</h2>
                        <p class="text-muted mb-0">The interface keeps routine work compact: students can file and track, staff can triage and reply, and administrators can see departments, users, and activity.</p>
                    </div>
                    <div class="col-lg-7">
                        <div class="workflow-item d-flex gap-3">
                            <strong class="text-nowrap">01</strong>
                            <span>Student submits an inquiry to the appropriate department.</span>
                        </div>
                        <div class="workflow-item d-flex gap-3">
                            <strong class="text-nowrap">02</strong>
                            <span>Department admin reviews status, priority, and student details.</span>
                        </div>
                        <div class="workflow-item d-flex gap-3">
                            <strong class="text-nowrap">03</strong>
                            <span>Responses and notifications keep the conversation traceable.</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </main>
</body>
</html>
