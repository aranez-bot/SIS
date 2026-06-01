@extends('layouts.app')

@section('title', 'Manage Inquiry')

@section('content')
    <h1 class="mb-4">
        <i class="fas fa-inbox"></i> Manage Inquiry
    </h1>

    <div class="card">
        <div class="card-header section-card-header">
            <div class="d-flex justify-content-between align-items-center">
                <h5 class="mb-0">All Department Inquiries</h5>
                <span class="badge bg-light text-dark">{{ $inquiries->total() }} Total</span>
            </div>
        </div>
        <div class="card-body border-bottom">
            <form method="GET" action="{{ route('admin.inquiry.inbox') }}" class="row g-2 align-items-end">
                <div class="col-md-3">
                    <label class="form-label" for="search">Search</label>
                    <input type="search" class="form-control" id="search" name="search" value="{{ request('search') }}" placeholder="Student, subject, or ID">
                </div>
                <div class="col-md-2">
                    <label class="form-label" for="status">Status</label>
                    <select class="form-select" id="status" name="status">
                        <option value="">All</option>
                        @foreach ($statuses as $value => $label)
                            <option value="{{ $value }}" @selected(request('status') === $value)>{{ $label }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label" for="category">Category</label>
                    <select class="form-select" id="category" name="category">
                        <option value="">All</option>
                        @foreach ($categories as $category)
                            <option value="{{ $category }}" @selected(request('category') === $category)>{{ ucfirst(str_replace('_', ' ', $category)) }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label" for="date_from">From</label>
                    <input type="date" class="form-control" id="date_from" name="date_from" value="{{ request('date_from') }}">
                </div>
                <div class="col-md-2">
                    <label class="form-label" for="date_to">To</label>
                    <input type="date" class="form-control" id="date_to" name="date_to" value="{{ request('date_to') }}">
                </div>
                <div class="col-md-1 d-grid">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-filter"></i>
                    </button>
                </div>
                @if (request()->hasAny(['search', 'status', 'category', 'date_from', 'date_to']))
                    <div class="col-md-1 d-grid">
                        <a href="{{ route('admin.inquiry.inbox') }}" class="btn btn-secondary">
                            <i class="fas fa-times"></i>
                        </a>
                    </div>
                @endif
            </form>
        </div>
        <div class="table-responsive">
            <table class="table mb-0">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Student Name</th>
                        <th>Department</th>
                        <th>Subject</th>
                        <th>Status</th>
                        <th>Priority</th>
                        <th>Assigned To</th>
                        <th>Submitted</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($inquiries as $inquiry)
                        <tr>
                            <td><strong>#{{ $inquiry->id }}</strong></td>
                            <td>
                                <strong>{{ $inquiry->student->name }}</strong><br>
                                <small class="text-muted">{{ $inquiry->student->email }}</small>
                            </td>
                            <td>{{ $inquiry->department->name }}</td>
                            <td>
                                {{ Str::limit($inquiry->subject, 35) }}
                                @if ($inquiry->category)
                                    <br>
                                    <small class="text-muted">{{ ucfirst(str_replace('_', ' ', $inquiry->category)) }}</small>
                                @endif
                            </td>
                            <td>
                                <span class="badge status-{{ $inquiry->status }}">
                                    {{ ucfirst(str_replace('_', ' ', $inquiry->status)) }}
                                </span>
                            </td>
                            <td>
                                @if ($inquiry->priority === 1)
                                    <span class="badge bg-light text-dark"><i class="fas fa-circle"></i> Normal</span>
                                @elseif ($inquiry->priority === 2)
                                    <span class="badge bg-warning"><i class="fas fa-arrow-up"></i> High</span>
                                @else
                                    <span class="badge bg-danger"><i class="fas fa-exclamation"></i> Urgent</span>
                                @endif
                            </td>
                            <td>
                                @if ($inquiry->assignedAdmin)
                                    <span class="badge bg-info">{{ $inquiry->assignedAdmin->name }}</span>
                                @else
                                    <span class="badge bg-secondary">Unassigned</span>
                                @endif
                            </td>
                            <td>
                                <small class="text-muted">{{ $inquiry->created_at->format('M d, H:i') }}</small>
                            </td>
                            <td>
                                <div class="d-flex flex-wrap gap-1">
                                    <a href="{{ route('admin.inquiry.show', $inquiry) }}" class="btn btn-sm btn-primary">
                                        <i class="fas fa-reply"></i> Respond
                                    </a>
                                    <a href="{{ route('admin.inquiry.show', $inquiry) }}#student-information" class="btn btn-sm btn-secondary">
                                        <i class="fas fa-user-graduate"></i> Student
                                    </a>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="9" class="text-center py-4 text-muted">
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
@endsection
