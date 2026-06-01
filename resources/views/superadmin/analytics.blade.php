@extends('layouts.app')

@section('title', 'System Analytics')

@section('content')
    <h1 class="mb-4">
        <i class="fas fa-chart-bar"></i> System Analytics
    </h1>

    <div class="row mb-4">
        <div class="col-lg-3 col-md-6 mb-3">
            <div class="stat-card">
                <i class="fas fa-file-alt"></i>
                <h3>{{ $totalInquiries }}</h3>
                <p>Total Inquiries</p>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 mb-3">
            <div class="stat-card" style="border-left-color: var(--warning-color);">
                <i class="fas fa-hourglass-half" style="color: var(--warning-color); background: #fff7ed;"></i>
                <h3 style="color: var(--warning-color);">{{ $pendingInquiries }}</h3>
                <p>Pending Inquiries</p>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 mb-3">
            <div class="stat-card" style="border-left-color: var(--success-color);">
                <i class="fas fa-check-circle" style="color: var(--success-color); background: #ecfdf5;"></i>
                <h3 style="color: var(--success-color);">{{ $resolvedInquiries }}</h3>
                <p>Resolved Inquiries</p>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 mb-3">
            <div class="stat-card" style="border-left-color: var(--secondary-color);">
                <i class="fas fa-clock" style="color: var(--secondary-color); background: #f0fdfa;"></i>
                <h3 style="color: var(--secondary-color);">{{ $averageResponseTime ? $averageResponseTime . 'h' : '-' }}</h3>
                <p>Avg. Response Time</p>
            </div>
        </div>
    </div>

    <div class="row mb-4">
        <div class="col-md-6">
            <div class="card">
                <div class="card-header section-card-header">
                    <h5 class="mb-0">
                        <i class="fas fa-pie-chart"></i> Inquiries by Status
                    </h5>
                </div>
                <div class="card-body">
                    <div class="list-group list-group-flush">
                        @foreach ($byStatus as $status => $count)
                            <div class="list-group-item d-flex justify-content-between align-items-center">
                                <div>
                                    @if ($status === 'pending')
                                        <i class="fas fa-hourglass-half"></i>
                                    @elseif ($status === 'in_progress')
                                        <i class="fas fa-spinner"></i>
                                    @elseif ($status === 'resolved')
                                        <i class="fas fa-check-circle"></i>
                                    @else
                                        <i class="fas fa-times-circle"></i>
                                    @endif
                                    <strong>{{ ucfirst(str_replace('_', ' ', $status)) }}</strong>
                                </div>
                                <span class="badge bg-primary">{{ $count }}</span>
                            </div>
                        @endforeach
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-6">
            <div class="card">
                <div class="card-header section-card-header">
                    <h5 class="mb-0">
                        <i class="fas fa-bar-chart"></i> Inquiries by Department
                    </h5>
                </div>
                <div class="card-body">
                    <div class="list-group list-group-flush">
                        @foreach ($byDepartment as $dept => $count)
                            <div class="list-group-item d-flex justify-content-between align-items-center">
                                <div>
                                    <i class="fas fa-building"></i>
                                    <strong>{{ $dept }}</strong>
                                </div>
                                <span class="badge bg-info">{{ $count }}</span>
                            </div>
                        @endforeach
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="card mb-4">
        <div class="card-header section-card-header">
            <h5 class="mb-0">
                <i class="fas fa-building"></i> Department Performance
            </h5>
        </div>
        <div class="table-responsive">
            <table class="table mb-0">
                <thead>
                    <tr>
                        <th>Department</th>
                        <th class="text-center">Total</th>
                        <th class="text-center">Pending</th>
                        <th class="text-center">Resolved</th>
                        <th class="text-center">Resolution Rate</th>
                        <th class="text-center">Avg. Response Time</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($departmentPerformance as $department)
                        <tr>
                            <td><strong>{{ $department['name'] }}</strong></td>
                            <td class="text-center">{{ $department['total_received'] }}</td>
                            <td class="text-center"><span class="badge bg-warning">{{ $department['pending'] }}</span></td>
                            <td class="text-center"><span class="badge bg-success">{{ $department['resolved'] }}</span></td>
                            <td class="text-center">{{ $department['resolution_rate'] }}%</td>
                            <td class="text-center">{{ $department['avg_response_time'] ? $department['avg_response_time'] . ' hrs' : '-' }}</td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="text-center text-muted py-4">No department data yet</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <div class="card">
        <div class="card-header section-card-header">
            <h5 class="mb-0">
                <i class="fas fa-table"></i> Summary Statistics
            </h5>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table">
                    <tr>
                        <th>Metric</th>
                        <th>Value</th>
                    </tr>
                    <tr>
                        <td>Total Inquiries</td>
                        <td><strong>{{ $totalInquiries }}</strong></td>
                    </tr>
                    <tr>
                        <td>Average Resolution Rate</td>
                        <td>
                            @php
                                $rate = $totalInquiries > 0 ? round(($resolvedInquiries / $totalInquiries) * 100, 2) : 0;
                            @endphp
                            <strong>{{ $rate }}%</strong>
                        </td>
                    </tr>
                    <tr>
                        <td>Average First Response Time</td>
                        <td><strong>{{ $averageResponseTime ? $averageResponseTime . ' hours' : 'No replies yet' }}</strong></td>
                    </tr>
                    <tr>
                        <td>Total Departments</td>
                        <td><strong>{{ count($byDepartment) }}</strong></td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
@endsection
