@extends('layouts.app')

@section('title', 'Inquiry History')

@push('styles')
    <style>
        .history-hero {
            background: linear-gradient(135deg, #5569dc 0%, #4fa7a1 100%);
            border-radius: 12px;
            color: white;
            padding: 1.5rem;
            box-shadow: 0 18px 42px rgba(79, 103, 216, 0.18);
        }

        .history-hero h1 {
            color: white;
        }

        .history-hero p,
        .history-hero .breadcrumb-lite {
            color: rgba(255, 255, 255, 0.78);
        }

        .history-summary {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 0.85rem;
        }

        .history-summary-card {
            background: white;
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 1rem;
            box-shadow: var(--shadow-sm);
        }

        .history-summary-card span {
            color: var(--muted-color);
            display: block;
            font-size: 0.82rem;
            font-weight: 700;
            margin-bottom: 0.35rem;
        }

        .history-summary-card strong {
            color: var(--dark-color);
            display: block;
            font-size: 1.6rem;
            line-height: 1;
        }

        .history-summary-card i {
            color: var(--primary-color);
            margin-right: 0.35rem;
        }

        .history-filter-card,
        .history-table-card {
            border-radius: 12px;
            box-shadow: 0 14px 34px rgba(32, 40, 56, 0.055);
        }

        .history-filter-card .form-control,
        .history-filter-card .form-select {
            min-height: 46px;
        }

        .history-table-card .card-header {
            padding: 1rem 1.25rem;
        }

        .history-table {
            margin-bottom: 0;
        }

        .history-table thead th {
            background: #f5f8fc;
            padding: 1rem 1.25rem;
        }

        .history-table tbody td {
            padding: 1rem 1.25rem;
        }

        .history-id {
            color: var(--primary-color);
            font-weight: 800;
            white-space: nowrap;
        }

        .history-subject {
            color: var(--dark-color);
            font-weight: 800;
            margin-bottom: 0.2rem;
        }

        .history-description {
            color: var(--muted-color);
            font-size: 0.88rem;
            max-width: 34rem;
        }

        .history-meta {
            color: var(--muted-color);
            font-size: 0.84rem;
            font-weight: 600;
        }

        .history-actions {
            display: flex;
            gap: 0.4rem;
            justify-content: flex-end;
        }

        .history-icon-button {
            align-items: center;
            border-radius: 8px;
            display: inline-flex;
            height: 2.35rem;
            justify-content: center;
            width: 2.35rem;
        }

        .history-empty-state {
            padding: 3rem 1rem;
            text-align: center;
        }

        .history-empty-state i {
            align-items: center;
            background: #eef3ff;
            border-radius: 12px;
            color: var(--primary-color);
            display: inline-flex;
            font-size: 1.8rem;
            height: 4rem;
            justify-content: center;
            margin-bottom: 1rem;
            width: 4rem;
        }

        @media (max-width: 992px) {
            .history-summary {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 768px) {
            .history-hero {
                padding: 1.15rem;
            }

            .history-summary {
                grid-template-columns: 1fr;
            }

            .history-table thead {
                display: none;
            }

            .history-table,
            .history-table tbody,
            .history-table tr,
            .history-table td {
                display: block;
                width: 100%;
            }

            .history-table tbody tr {
                border-bottom: 1px solid var(--border-color);
                padding: 0.9rem 1rem;
            }

            .history-table tbody td {
                border: 0;
                padding: 0.35rem 0;
            }

            .history-table tbody td::before {
                color: var(--muted-color);
                content: attr(data-label);
                display: block;
                font-size: 0.75rem;
                font-weight: 800;
                text-transform: uppercase;
            }

            .history-actions {
                justify-content: flex-start;
                margin-top: 0.25rem;
            }
        }
    </style>
@endpush

@section('content')
    <div class="history-hero mb-4">
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-3">
            <div>
                <div class="breadcrumb-lite fw-semibold mb-2">
                    Dashboard <i class="fas fa-chevron-right mx-1"></i> Inquiries
                </div>
                <h1 class="mb-2">
                    <i class="fas fa-history"></i> Inquiry History
                </h1>
                <p class="mb-0">Review every request you submitted, check progress, and reopen conversations.</p>
            </div>
            <a href="{{ route('student.inquiry.create') }}" class="btn btn-light fw-bold">
                <i class="fas fa-plus-circle me-1"></i> New Inquiry
            </a>
        </div>
    </div>

    <div class="history-summary mb-4">
        <div class="history-summary-card">
            <span><i class="fas fa-clipboard-list"></i>Total Inquiries</span>
            <strong>{{ $summary['total'] }}</strong>
        </div>
        <div class="history-summary-card">
            <span><i class="fas fa-hourglass-half"></i>Pending</span>
            <strong>{{ $summary['pending'] }}</strong>
        </div>
        <div class="history-summary-card">
            <span><i class="fas fa-spinner"></i>In Progress</span>
            <strong>{{ $summary['in_progress'] }}</strong>
        </div>
        <div class="history-summary-card">
            <span><i class="fas fa-check-circle"></i>Resolved / Closed</span>
            <strong>{{ $summary['resolved'] }}</strong>
        </div>
    </div>

    <div class="card history-filter-card mb-4">
        <div class="card-body">
            <form method="GET" action="{{ route('student.inquiry.history') }}" class="row g-3 align-items-end">
                <div class="col-lg-4 col-md-6">
                    <label class="form-label" for="search">Search</label>
                    <div class="input-group">
                        <span class="input-group-text bg-white"><i class="fas fa-search text-muted"></i></span>
                        <input type="search" class="form-control" id="search" name="search" value="{{ request('search') }}" placeholder="Subject, message, or ID">
                    </div>
                </div>
                <div class="col-lg-2 col-md-6">
                    <label class="form-label" for="status">Status</label>
                    <select class="form-select" id="status" name="status">
                        <option value="">All statuses</option>
                        @foreach ($statuses as $value => $label)
                            <option value="{{ $value }}" @selected(request('status') === $value)>{{ $label }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="col-lg-2 col-md-6">
                    <label class="form-label" for="department_id">Department</label>
                    <select class="form-select" id="department_id" name="department_id">
                        <option value="">All departments</option>
                        @foreach ($departments as $department)
                            <option value="{{ $department->id }}" @selected((string) request('department_id') === (string) $department->id)>{{ $department->name }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="col-lg-2 col-md-6">
                    <label class="form-label" for="date_from">From</label>
                    <input type="date" class="form-control" id="date_from" name="date_from" value="{{ request('date_from') }}">
                </div>
                <div class="col-lg-2 col-md-6">
                    <label class="form-label" for="date_to">To</label>
                    <input type="date" class="form-control" id="date_to" name="date_to" value="{{ request('date_to') }}">
                </div>
                <div class="col-lg-2 col-md-3 d-grid">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-filter me-1"></i> Apply
                    </button>
                </div>
                @if (request()->hasAny(['search', 'status', 'department_id', 'date_from', 'date_to']))
                    <div class="col-lg-2 col-md-3 d-grid">
                        <a href="{{ route('student.inquiry.history') }}" class="btn btn-secondary">
                            <i class="fas fa-times me-1"></i> Clear
                        </a>
                    </div>
                @endif
            </form>
        </div>
    </div>

    <div class="card history-table-card">
        <div class="card-header section-card-header">
            <div class="d-flex flex-wrap justify-content-between align-items-center gap-2">
                <h5 class="mb-0">Submitted Inquiries</h5>
                <span class="badge bg-light text-dark">
                    <i class="fas fa-list me-1 text-primary"></i>{{ $inquiries->total() }} records
                </span>
            </div>
        </div>

        <div class="table-responsive">
            <table class="table history-table">
                <thead>
                    <tr>
                        <th>Inquiry</th>
                        <th>Department</th>
                        <th>Status</th>
                        <th>Messages</th>
                        <th>Submitted</th>
                        <th class="text-end">Action</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($inquiries as $inquiry)
                        <tr>
                            <td data-label="Inquiry">
                                <div class="history-id">INQ-{{ str_pad($inquiry->id, 3, '0', STR_PAD_LEFT) }}</div>
                                <div class="history-subject">{{ Str::limit($inquiry->subject, 70) }}</div>
                                <div class="history-description">{{ Str::limit($inquiry->description, 110) }}</div>
                            </td>
                            <td data-label="Department">
                                <strong>{{ $inquiry->department->name }}</strong>
                                @if ($inquiry->category)
                                    <div class="history-meta">{{ ucfirst(str_replace('_', ' ', $inquiry->category)) }}</div>
                                @endif
                            </td>
                            <td data-label="Status">
                                <span class="badge status-{{ $inquiry->status }}">
                                    {{ ucfirst(str_replace('_', ' ', $inquiry->status)) }}
                                </span>
                            </td>
                            <td data-label="Messages">
                                <span class="badge bg-light text-dark">
                                    <i class="fas fa-comments me-1 text-primary"></i>{{ $inquiry->messages_count }}
                                </span>
                            </td>
                            <td data-label="Submitted">
                                <strong>{{ $inquiry->created_at->format('M d, Y') }}</strong>
                                <div class="history-meta">Updated {{ $inquiry->updated_at->diffForHumans() }}</div>
                            </td>
                            <td data-label="Action">
                                <div class="history-actions">
                                    <a href="{{ route('student.inquiry.show', $inquiry) }}" class="btn btn-primary history-icon-button" aria-label="View {{ $inquiry->subject }}" title="View inquiry">
                                        <i class="fas fa-eye"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6">
                                <div class="history-empty-state">
                                    <i class="fas fa-inbox"></i>
                                    <h5>No inquiries found</h5>
                                    <p class="text-muted mb-3">Try clearing your filters or submit your first inquiry.</p>
                                    <a href="{{ route('student.inquiry.create') }}" class="btn btn-primary">
                                        <i class="fas fa-plus-circle me-1"></i> New Inquiry
                                    </a>
                                </div>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if ($inquiries->hasPages())
            <div class="card-footer bg-white">
                {{ $inquiries->links() }}
            </div>
        @endif
    </div>
@endsection
