@extends('layouts.app')

@section('title', 'Student Dashboard')

@section('content')
    <div class="d-flex flex-wrap gap-2 justify-content-between align-items-center mb-4">
        <h1 class="mb-0">
            <i class="fas fa-chart-line"></i> Dashboard
        </h1>
        <div class="d-flex flex-wrap gap-2">
            <a href="{{ route('student.mobile-app') }}" class="btn btn-outline-primary">
                <i class="fas fa-mobile-alt"></i> Download App
            </a>
            <a href="{{ route('student.inquiry.create') }}" class="btn btn-primary">
                <i class="fas fa-plus-circle"></i> New Inquiry
            </a>
        </div>
    </div>

    <div class="row mb-4">
        <div class="col-md-3 mb-3">
            <div class="stat-card">
                <i class="fas fa-clipboard-list" style="font-size: 2rem; color: var(--primary-color);"></i>
                <h3>{{ $inquiries->total() }}</h3>
                <p>Total Inquiries</p>
            </div>
        </div>
        <div class="col-md-3 mb-3">
            <div class="stat-card" style="border-left-color: var(--warning-color);">
                <i class="fas fa-hourglass-half" style="font-size: 2rem; color: var(--warning-color);"></i>
                <h3>{{ $inquiries->where('status', 'pending')->count() }}</h3>
                <p>Pending</p>
            </div>
        </div>
        <div class="col-md-3 mb-3">
            <div class="stat-card" style="border-left-color: var(--success-color);">
                <i class="fas fa-check-circle" style="font-size: 2rem; color: var(--success-color);"></i>
                <h3>{{ $inquiries->where('status', 'resolved')->count() }}</h3>
                <p>Resolved</p>
            </div>
        </div>
        <div class="col-md-3 mb-3">
            <div class="stat-card" style="border-left-color: var(--danger-color);">
                <i class="fas fa-bell" style="font-size: 2rem; color: var(--danger-color);"></i>
                <h3>{{ $unreadNotifications }}</h3>
                <p>Notifications</p>
            </div>
        </div>
    </div>

    <div class="card mb-4">
        <div class="card-body d-flex flex-wrap gap-3 justify-content-between align-items-center">
            <div>
                <h5 class="mb-1">
                    <i class="fas fa-mobile-alt text-primary"></i> Student Inquiry Mobile App
                </h5>
                <p class="text-muted mb-0">Download the Android APK installer for quicker access on your phone.</p>
            </div>
            <a href="{{ route('student.mobile-app') }}" class="btn btn-primary">
                <i class="fas fa-download"></i> Open Download Page
            </a>
        </div>
    </div>

    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-header section-card-header">
                    <h5 class="mb-0">
                        <i class="fas fa-history"></i> Recent Inquiries
                    </h5>
                </div>
                <div class="table-responsive">
                    <table class="table mb-0">
                        <thead>
                            <tr>
                                <th>Subject</th>
                                <th>Status</th>
                                <th>Submitted</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse ($inquiries as $inquiry)
                                <tr>
                                    <td>
                                        <strong>{{ $inquiry->subject }}</strong>
                                    </td>
                                    <td>
                                        <span class="badge status-{{ $inquiry->status }}">
                                            {{ ucfirst(str_replace('_', ' ', $inquiry->status)) }}
                                        </span>
                                    </td>
                                    <td>{{ $inquiry->created_at->format('M d, Y') }}</td>
                                    <td>
                                        <a href="{{ route('student.inquiry.show', $inquiry) }}" class="btn btn-sm btn-primary">
                                            <i class="fas fa-eye"></i> View
                                        </a>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="4" class="text-center text-muted py-4">
                                        <i class="fas fa-inbox"></i> No inquiries yet
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
                @if ($inquiries->hasPages())
                    <div class="card-footer">
                        {{ $inquiries->links() }}
                    </div>
                @endif
            </div>
        </div>
    </div>
@endsection
