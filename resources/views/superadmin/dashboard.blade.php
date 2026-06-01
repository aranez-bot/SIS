@extends('layouts.app')

@section('title', 'Superadmin Dashboard')

@section('content')
    @php
        $categoryFor = function ($inquiry) {
            $text = strtolower($inquiry->subject . ' ' . $inquiry->description);

            return str_contains($text, 'enroll') || str_contains($text, 'admission') || str_contains($text, 'registration') ? 'Enrollment'
                : (str_contains($text, 'grade') || str_contains($text, 'transcript') ? 'Grades'
                : (str_contains($text, 'payment') || str_contains($text, 'tuition') || str_contains($text, 'fee') ? 'Finance'
                : (str_contains($text, 'record') || str_contains($text, 'certificate') || str_contains($text, 'document') ? 'Records' : 'General')));
        };

        $responseTimeFor = function ($inquiry) {
            $message = $inquiry->messages->first(fn ($message) => $message->user && $message->user->isDepartmentAdmin());

            if (!$message) {
                return 'No reply yet';
            }

            $hours = round($inquiry->created_at->diffInMinutes($message->created_at) / 60, 1);
            return $hours < 1 ? 'Under 1 hr' : $hours . ' hrs';
        };

        $statusFor = function ($inquiry) use ($overdueHours) {
            if (in_array($inquiry->status, ['pending', 'in_progress']) && $inquiry->created_at->lte(now()->subHours($overdueHours))) {
                return 'overdue';
            }

            return $inquiry->status;
        };
    @endphp

    <!-- Header Section -->
    <div class="mb-5">
        <div class="d-flex align-items-center gap-3 mb-2">
            <h1 class="mb-0" style="font-weight: 700; font-size: 2.5rem;">
                <i class="fas fa-crown" style="color: var(--primary-color);"></i> System Dashboard
            </h1>
        </div>
        <p class="text-muted mb-0" style="font-size: 1.05rem;">Welcome back, {{ auth()->user()->name }}. Here's an overview of your inquiry system.</p>
    </div>

    <!-- Main Superadmin Summary -->
    <div class="row mb-4">
        <div class="col-lg-2 col-md-4 col-sm-6 mb-3">
            <div class="stat-card">
                <i class="fas fa-users" style="font-size: 2rem; color: var(--primary-color);"></i>
                <h3>{{ $totalUsers }}</h3>
                <p>Total Users</p>
            </div>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6 mb-3">
            <div class="stat-card" style="border-left-color: #7c3aed;">
                <i class="fas fa-user-shield" style="font-size: 2rem; color: #7c3aed;"></i>
                <h3>{{ $totalAdmins }}</h3>
                <p>Department Admins</p>
            </div>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6 mb-3">
            <div class="stat-card" style="border-left-color: #14b8a6;">
                <i class="fas fa-building" style="font-size: 2rem; color: #14b8a6;"></i>
                <h3>{{ $totalDepartments }}</h3>
                <p>Departments</p>
            </div>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6 mb-3">
            <div class="stat-card">
                <i class="fas fa-file-alt" style="font-size: 2rem; color: var(--primary-color);"></i>
                <h3>{{ $totalInquiries }}</h3>
                <p>Total Inquiries</p>
            </div>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6 mb-3">
            <div class="stat-card" style="border-left-color: var(--warning-color);">
                <i class="fas fa-hourglass-half" style="font-size: 2rem; color: var(--warning-color);"></i>
                <h3>{{ $pendingInquiries }}</h3>
                <p>Pending</p>
            </div>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6 mb-3">
            <div class="stat-card" style="border-left-color: var(--success-color);">
                <i class="fas fa-check-circle" style="font-size: 2rem; color: var(--success-color);"></i>
                <h3>{{ $resolvedInquiries }}</h3>
                <p>Resolved</p>
            </div>
        </div>
    </div>

    <!-- Superadmin Control Center -->
    <div class="card mb-5">
        <div class="card-header section-card-header">
            <h5 class="mb-0"><i class="fas fa-toolbox"></i> Superadmin Control Center</h5>
        </div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-xl-3 col-md-4 col-sm-6">
                    <a href="{{ route('superadmin.users.index') }}" class="btn btn-secondary w-100 text-start p-3">
                        <i class="fas fa-users"></i> Manage User Accounts
                    </a>
                </div>
                <div class="col-xl-3 col-md-4 col-sm-6">
                    <a href="{{ route('superadmin.users.create-admin') }}" class="btn btn-secondary w-100 text-start p-3">
                        <i class="fas fa-user-shield"></i> Manage Department Admins
                    </a>
                </div>
                <div class="col-xl-3 col-md-4 col-sm-6">
                    <a href="{{ route('superadmin.departments.index') }}" class="btn btn-secondary w-100 text-start p-3">
                        <i class="fas fa-building"></i> Manage Departments
                    </a>
                </div>
                <div class="col-xl-3 col-md-4 col-sm-6">
                    <a href="#inquiry-master-table" class="btn btn-secondary w-100 text-start p-3">
                        <i class="fas fa-table"></i> Monitor All Inquiries
                    </a>
                </div>
                <div class="col-xl-3 col-md-4 col-sm-6">
                    <a href="{{ route('superadmin.analytics') }}" class="btn btn-secondary w-100 text-start p-3">
                        <i class="fas fa-chart-line"></i> System Reports and Analytics
                    </a>
                </div>
                <div class="col-xl-3 col-md-4 col-sm-6">
                    <a href="{{ route('superadmin.role-permissions') }}" class="btn btn-secondary w-100 text-start p-3">
                        <i class="fas fa-user-lock"></i> Role and Permission Management
                    </a>
                </div>
                <div class="col-xl-3 col-md-4 col-sm-6">
                    <a href="{{ route('superadmin.system-settings') }}" class="btn btn-secondary w-100 text-start p-3">
                        <i class="fas fa-sliders-h"></i> System Settings
                    </a>
                </div>
                <div class="col-xl-3 col-md-4 col-sm-6">
                    <a href="{{ route('superadmin.audit-logs') }}" class="btn btn-secondary w-100 text-start p-3">
                        <i class="fas fa-clipboard-list"></i> Audit Logs
                    </a>
                </div>
                <div class="col-xl-3 col-md-4 col-sm-6">
                    <a href="{{ route('superadmin.maintenance') }}" class="btn btn-secondary w-100 text-start p-3">
                        <i class="fas fa-database"></i> Backup and Maintenance
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Key Metrics Row -->
    <div class="row mb-5">
        <div class="col-lg-2 col-md-4 col-sm-6 mb-3">
            <div class="card border-0 shadow-sm h-100" style="transition: all 0.3s ease;">
                <div class="card-body text-center py-4">
                    <div class="mb-3">
                        <i class="fas fa-file-alt" style="font-size: 2.5rem; color: var(--primary-color);"></i>
                    </div>
                    <h3 class="mb-1" style="font-weight: 700;">{{ $totalInquiries }}</h3>
                    <p class="text-muted mb-0">Total Inquiries</p>
                </div>
            </div>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6 mb-3">
            <div class="card border-0 shadow-sm h-100" style="transition: all 0.3s ease;">
                <div class="card-body text-center py-4">
                    <div class="mb-3">
                        <i class="fas fa-hourglass-half" style="font-size: 2.5rem; color: var(--warning-color);"></i>
                    </div>
                    <h3 class="mb-1" style="font-weight: 700; color: var(--warning-color);">{{ $pendingInquiries }}</h3>
                    <p class="text-muted mb-0">Pending</p>
                </div>
            </div>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6 mb-3">
            <div class="card border-0 shadow-sm h-100" style="transition: all 0.3s ease;">
                <div class="card-body text-center py-4">
                    <div class="mb-3">
                        <i class="fas fa-spinner" style="font-size: 2.5rem; color: #3b82f6;"></i>
                    </div>
                    <h3 class="mb-1" style="font-weight: 700; color: #3b82f6;">{{ $inProgressInquiries }}</h3>
                    <p class="text-muted mb-0">In Progress</p>
                </div>
            </div>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6 mb-3">
            <div class="card border-0 shadow-sm h-100" style="transition: all 0.3s ease;">
                <div class="card-body text-center py-4">
                    <div class="mb-3">
                        <i class="fas fa-check-circle" style="font-size: 2.5rem; color: var(--success-color);"></i>
                    </div>
                    <h3 class="mb-1" style="font-weight: 700; color: var(--success-color);">{{ $resolvedToday }}</h3>
                    <p class="text-muted mb-0">Resolved Today</p>
                </div>
            </div>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6 mb-3">
            <div class="card border-0 shadow-sm h-100" style="transition: all 0.3s ease;">
                <div class="card-body text-center py-4">
                    <div class="mb-3">
                        <i class="fas fa-triangle-exclamation" style="font-size: 2.5rem; color: var(--danger-color);"></i>
                    </div>
                    <h3 class="mb-1" style="font-weight: 700; color: var(--danger-color);">{{ $overdueInquiries }}</h3>
                    <p class="text-muted mb-0">Overdue</p>
                </div>
            </div>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6 mb-3">
            <div class="card border-0 shadow-sm h-100" style="transition: all 0.3s ease;">
                <div class="card-body text-center py-4">
                    <div class="mb-3">
                        <i class="fas fa-chart-pie" style="font-size: 2.5rem; color: #14b8a6;"></i>
                    </div>
                    <h3 class="mb-1" style="font-weight: 700; color: #14b8a6;">{{ $resolutionRate }}%</h3>
                    <p class="text-muted mb-0">Resolution Rate</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Quick Actions & Analytics Section -->
    <div class="row mb-5">
        <div class="col-12 mb-3">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-header bg-white border-bottom py-3">
                    <h5 class="mb-0"><i class="fas fa-chart-line"></i> Analytics & Reports</h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <h6 class="mb-3 fw-6">Inquiry Volume (Last 2 Weeks)</h6>
                            @foreach ($volumeByDay as $item)
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <small>{{ \Carbon\Carbon::parse($item->day)->format('M d') }}</small>
                                    <div class="progress flex-grow-1 mx-2" style="height: 6px;">
                                        <div class="progress-bar" style="width: {{ ($item->total / ($volumeByDay->max('total') ?? 1)) * 100 }}%;"></div>
                                    </div>
                                    <small class="fw-6">{{ $item->total }}</small>
                                </div>
                            @endforeach
                        </div>
                        <div class="col-md-6 mb-3">
                            <h6 class="mb-3 fw-6">Inquiries per Department</h6>
                            @foreach ($byDepartment as $item)
                                <div class="mb-2">
                                    <div class="d-flex justify-content-between align-items-center mb-1">
                                        <span style="font-size: 0.9rem;">{{ $item->name }}</span>
                                        <span class="badge bg-light text-dark">{{ $item->total }}</span>
                                    </div>
                                    <div class="progress" style="height: 6px;">
                                        <div class="progress-bar" style="width: {{ $totalInquiries ? ($item->total / $totalInquiries) * 100 : 0 }}%;"></div>
                                    </div>
                                </div>
                            @endforeach
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <!-- Department Performance Section -->
    <div class="mb-5">
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-white border-bottom py-3">
                <h5 class="mb-0"><i class="fas fa-building"></i> Department Performance</h5>
            </div>
            <div class="table-responsive">
                <table class="table mb-0">
                    <thead>
                        <tr style="background-color: #f8f9fa;">
                            <th>Department</th>
                            <th class="text-center">Total Received</th>
                            <th class="text-center">Pending</th>
                            <th class="text-center">Resolved</th>
                            <th class="text-center">Avg. Response Time</th>
                            <th class="text-center">Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($departmentPerformance as $department)
                            <tr>
                                <td>
                                    <a href="{{ route('superadmin.dashboard', ['department_id' => $department['id']]) }}" class="text-decoration-none fw-5">
                                        {{ $department['name'] }}
                                    </a>
                                </td>
                                <td class="text-center">{{ $department['total_received'] }}</td>
                                <td class="text-center"><span class="badge bg-warning">{{ $department['pending'] }}</span></td>
                                <td class="text-center"><span class="badge bg-success">{{ $department['resolved'] }}</span></td>
                                <td class="text-center">
                                    {{ $department['avg_response_time'] ? $department['avg_response_time'] . ' hrs' : '-' }}
                                </td>
                                <td class="text-center">
                                    @if ($department['status'] === 'Good')
                                        <span class="badge bg-success"><i class="fas fa-smile-wink"></i> Good</span>
                                    @elseif ($department['status'] === 'Slow')
                                        <span class="badge bg-warning"><i class="fas fa-snail"></i> Slow</span>
                                    @else
                                        <span class="badge bg-danger"><i class="fas fa-exclamation"></i> Overdue</span>
                                    @endif
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Inquiry Master List Section -->
    <div class="mb-5">
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-white border-bottom py-3">
                <h5 class="mb-0"><i class="fas fa-table"></i> Inquiry Master List</h5>
            </div>
            <div class="card-body">
                <!-- Filters -->
                <form method="GET" action="{{ route('superadmin.dashboard') }}" class="row g-2 align-items-end mb-4">
                    <div class="col-md-2">
                        <label class="form-label" for="department_id">Department</label>
                        <select class="form-select form-select-sm" id="department_id" name="department_id">
                            <option value="">All</option>
                            @foreach ($departments as $department)
                                <option value="{{ $department->id }}" @selected(request('department_id') == $department->id)>{{ $department->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label" for="status">Status</label>
                        <select class="form-select form-select-sm" id="status" name="status">
                            <option value="">All</option>
                            @foreach (['pending' => 'Pending', 'in_progress' => 'In Progress', 'resolved' => 'Resolved', 'closed' => 'Closed'] as $value => $label)
                                <option value="{{ $value }}" @selected(request('status') === $value)>{{ $label }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label" for="category">Category</label>
                        <select class="form-select form-select-sm" id="category" name="category">
                            <option value="">All</option>
                            @foreach (['Enrollment', 'Grades', 'Finance', 'Records'] as $category)
                                <option value="{{ $category }}" @selected(request('category') === $category)>{{ $category }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label" for="date_from">From</label>
                        <input type="date" class="form-control form-control-sm" id="date_from" name="date_from" value="{{ request('date_from') }}">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label" for="date_to">To</label>
                        <input type="date" class="form-control form-control-sm" id="date_to" name="date_to" value="{{ request('date_to') }}">
                    </div>
                    <div class="col-md-2 d-grid">
                        <button type="submit" class="btn btn-primary btn-sm">
                            <i class="fas fa-filter"></i> Filter
                        </button>
                    </div>
                </form>

                <!-- Export Buttons -->
                <div class="d-flex gap-2 justify-content-end mb-3">
                    <button type="button" class="btn btn-sm btn-outline-secondary" onclick="exportInquiryTableCsv()">
                        <i class="fas fa-file-excel"></i> Export Excel
                    </button>
                    <button type="button" class="btn btn-sm btn-outline-secondary" onclick="window.print()">
                        <i class="fas fa-file-pdf"></i> Export PDF
                    </button>
                </div>

                <!-- Table -->
                <div class="table-responsive">
                    <table class="table table-hover mb-0" id="inquiry-master-table">
                        <thead style="background-color: #f8f9fa;">
                            <tr>
                                <th>Inquiry ID</th>
                                <th>Student Name & ID</th>
                                <th>Department</th>
                                <th>Category</th>
                                <th>Subject</th>
                                <th>Date Submitted</th>
                                <th>Status</th>
                                <th>Response Time</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse ($inquiries as $inquiry)
                                @php $displayStatus = $statusFor($inquiry); @endphp
                                <tr>
                                    <td><span class="badge bg-light text-dark">#{{ $inquiry->id }}</span></td>
                                    <td>
                                        <strong>{{ $inquiry->student->name }}</strong><br>
                                        <small class="text-muted">{{ $inquiry->student->user_identifier ?? 'No ID' }}</small>
                                    </td>
                                    <td>{{ $inquiry->department->name }}</td>
                                    <td><span class="badge bg-light text-dark">{{ $categoryFor($inquiry) }}</span></td>
                                    <td>{{ Str::limit($inquiry->subject, 35) }}</td>
                                    <td><small>{{ $inquiry->created_at->format('M d, Y H:i') }}</small></td>
                                    <td>
                                        @if ($displayStatus === 'overdue')
                                            <span class="badge bg-danger">Overdue</span>
                                        @else
                                            <span class="badge status-{{ $inquiry->status }}">{{ ucfirst(str_replace('_', ' ', $inquiry->status)) }}</span>
                                        @endif
                                    </td>
                                    <td><small>{{ $responseTimeFor($inquiry) }}</small></td>
                                    <td>
                                        <a href="{{ route('superadmin.inquiry.show', $inquiry) }}" class="btn btn-sm btn-primary">
                                            <i class="fas fa-comments"></i> View
                                        </a>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="9" class="text-center text-muted py-4">No inquiries found</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
            @if ($inquiries->hasPages())
                <div class="card-footer bg-white">
                    {{ $inquiries->links() }}
                </div>
            @endif
        </div>
    </div>
@endsection

@push('scripts')
    <script>
        function exportInquiryTableCsv() {
            const rows = Array.from(document.querySelectorAll('#inquiry-master-table tr'));
            const csv = rows.map(row => {
                return Array.from(row.querySelectorAll('th, td'))
                    .slice(0, 8)
                    .map(cell => '"' + cell.innerText.replaceAll('"', '""').trim() + '"')
                    .join(',');
            }).join('\n');

            const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
            const link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = 'inquiries.csv';
            link.click();
            URL.revokeObjectURL(link.href);
        }
    </script>
@endpush
