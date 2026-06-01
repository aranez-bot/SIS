@extends('layouts.app')

@section('title', 'Admin Dashboard - ' . $department->name)

@section('content')
    <h1 class="mb-4">
        <i class="fas fa-chart-line"></i> {{ $department->name }} Dashboard
    </h1>

    <div class="row mb-4">
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="stat-card">
                <i class="fas fa-envelope" style="font-size: 2rem; color: var(--primary-color);"></i>
                <h3>{{ $totalCount }}</h3>
                <p>Total Assigned</p>
            </div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="stat-card" style="border-left-color: var(--warning-color);">
                <i class="fas fa-hourglass-half" style="font-size: 2rem; color: var(--warning-color);"></i>
                <h3>{{ $pendingCount }}</h3>
                <p>Pending</p>
            </div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="stat-card" style="border-left-color: #3b82f6;">
                <i class="fas fa-spinner" style="font-size: 2rem; color: #3b82f6;"></i>
                <h3>{{ $inProgressCount }}</h3>
                <p>In Progress</p>
            </div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="stat-card" style="border-left-color: var(--success-color);">
                <i class="fas fa-check-circle" style="font-size: 2rem; color: var(--success-color);"></i>
                <h3>{{ $resolvedCount }}</h3>
                <p>Resolved</p>
            </div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="stat-card" style="border-left-color: var(--muted-color);">
                <i class="fas fa-lock" style="font-size: 2rem; color: var(--muted-color);"></i>
                <h3>{{ $closedCount }}</h3>
                <p>Closed</p>
            </div>
        </div>
    </div>

    <div class="row mb-4">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header section-card-header">
                    <h5 class="mb-0">
                        <i class="fas fa-inbox"></i> Recent Inquiries
                    </h5>
                </div>
                <div class="table-responsive">
                    <table class="table mb-0">
                        <thead>
                            <tr>
                                <th>Student</th>
                                <th>Subject</th>
                                <th>Status</th>
                                <th>Priority</th>
                                <th>Submitted</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse ($inquiries as $inquiry)
                                <tr>
                                    <td>
                                        <strong>{{ $inquiry->student->name }}</strong><br>
                                        <small class="text-muted">{{ $inquiry->student->email }}</small>
                                    </td>
                                    <td>{{ Str::limit($inquiry->subject, 40) }}</td>
                                    <td>
                                        <span class="badge status-{{ $inquiry->status }}">
                                            {{ ucfirst(str_replace('_', ' ', $inquiry->status)) }}
                                        </span>
                                    </td>
                                    <td>
                                        @if ($inquiry->priority === 1)
                                            <span class="badge bg-light text-dark">Normal</span>
                                        @elseif ($inquiry->priority === 2)
                                            <span class="badge bg-warning">High</span>
                                        @else
                                            <span class="badge bg-danger">Urgent</span>
                                        @endif
                                    </td>
                                    <td>
                                        <small class="text-muted">{{ $inquiry->created_at->format('M d') }}</small>
                                    </td>
                                    <td>
                                        <a href="{{ route('admin.inquiry.show', $inquiry) }}" class="btn btn-sm btn-primary">
                                            <i class="fas fa-reply"></i> Respond
                                        </a>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="6" class="text-center py-4 text-muted">
                                        <i class="fas fa-inbox"></i> No inquiries
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

        <div class="col-md-4">
            <div class="card" style="border-left: 4px solid var(--primary-color);">
                <div class="card-header section-card-header">
                    <h6 class="mb-0">
                        <i class="fas fa-info-circle"></i> Department Info
                    </h6>
                </div>
                <div class="card-body small">
                    <p class="mb-2">
                        <strong>Email:</strong><br>
                        <a href="mailto:{{ $department->email }}">{{ $department->email }}</a>
                    </p>
                    <p class="mb-2">
                        <strong>Phone:</strong><br>
                        {{ $department->phone ?? 'N/A' }}
                    </p>
                    <p class="mb-0">
                        <strong>Office Hours:</strong><br>
                        {{ $department->office_hours ?? 'Not specified' }}
                    </p>
                </div>
            </div>

            <div class="card mt-3" style="border-left: 4px solid var(--secondary-color);">
                <div class="card-header section-card-header">
                    <h6 class="mb-0">
                        <i class="fas fa-tags"></i> Frequently Asked Concerns
                    </h6>
                </div>
                <div class="card-body small">
                    @forelse ($frequentConcerns as $concern)
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span>{{ Str::limit($concern->subject, 34) }}</span>
                            <span class="badge bg-light text-dark">{{ $concern->total }}</span>
                        </div>
                    @empty
                        <p class="text-muted mb-0">No concern data yet.</p>
                    @endforelse
                    <hr>
                    @forelse ($frequentCategories as $category)
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span>{{ ucfirst(str_replace('_', ' ', $category->category ?? 'general')) }}</span>
                            <span class="badge bg-light text-dark">{{ $category->total }}</span>
                        </div>
                    @empty
                        <p class="text-muted mb-0">No category data yet.</p>
                    @endforelse
                </div>
            </div>

            <div class="card mt-3" style="border-left: 4px solid var(--warning-color);">
                <div class="card-header section-card-header">
                    <div class="d-flex justify-content-between align-items-center">
                        <h6 class="mb-0">
                            <i class="fas fa-question-circle"></i> Department FAQ
                        </h6>
                        <a href="{{ route('admin.faqs.index') }}" class="btn btn-sm btn-secondary">Manage</a>
                    </div>
                </div>
                <div class="card-body small">
                    @forelse ($recentFaqs as $faq)
                        <p class="mb-2">
                            <strong>{{ $faq->question }}</strong><br>
                            <span class="text-muted">{{ Str::limit($faq->answer, 70) }}</span>
                        </p>
                    @empty
                        <p class="text-muted mb-0">Add common answers for this department.</p>
                    @endforelse
                </div>
            </div>
        </div>
    </div>
@endsection
