@extends('layouts.app')

@section('title', 'Department Statistics')

@section('content')
    <h1 class="mb-4">
        <i class="fas fa-chart-bar"></i> {{ auth()->user()->department->name }} - Statistics
    </h1>

    <div class="row mb-4">
        <div class="col-md-3 mb-3">
            <div class="stat-card">
                <i class="fas fa-envelope" style="font-size: 2rem; color: var(--primary-color);"></i>
                <h3>{{ $stats['total'] }}</h3>
                <p>Total Inquiries</p>
            </div>
        </div>
        <div class="col-md-3 mb-3">
            <div class="stat-card" style="border-left-color: var(--warning-color);">
                <i class="fas fa-hourglass-half" style="font-size: 2rem; color: var(--warning-color);"></i>
                <h3>{{ $stats['pending'] }}</h3>
                <p>Pending</p>
            </div>
        </div>
        <div class="col-md-3 mb-3">
            <div class="stat-card" style="border-left-color: #3b82f6;">
                <i class="fas fa-spinner" style="font-size: 2rem; color: #3b82f6;"></i>
                <h3>{{ $stats['in_progress'] }}</h3>
                <p>In Progress</p>
            </div>
        </div>
        <div class="col-md-3 mb-3">
            <div class="stat-card" style="border-left-color: var(--success-color);">
                <i class="fas fa-check-circle" style="font-size: 2rem; color: var(--success-color);"></i>
                <h3>{{ $stats['resolved'] }}</h3>
                <p>Resolved</p>
            </div>
        </div>
        <div class="col-md-3 mb-3">
            <div class="stat-card" style="border-left-color: var(--muted-color);">
                <i class="fas fa-lock" style="font-size: 2rem; color: var(--muted-color);"></i>
                <h3>{{ $stats['closed'] }}</h3>
                <p>Closed</p>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-6">
            <div class="card">
                <div class="card-header section-card-header">
                    <h5 class="mb-0"><i class="fas fa-file-alt"></i> Department Report Summary</h5>
                </div>
                <div class="table-responsive">
                    <table class="table mb-0">
                        <tr>
                            <th>Status</th>
                            <th>Count</th>
                            <th>Percentage</th>
                        </tr>
                        <tr>
                            <td><strong>Pending</strong></td>
                            <td><span class="badge bg-warning">{{ $stats['pending'] }}</span></td>
                            <td>{{ $stats['total'] > 0 ? round(($stats['pending'] / $stats['total']) * 100, 1) : 0 }}%</td>
                        </tr>
                        <tr>
                            <td><strong>In Progress</strong></td>
                            <td><span class="badge bg-info">{{ $stats['in_progress'] }}</span></td>
                            <td>{{ $stats['total'] > 0 ? round(($stats['in_progress'] / $stats['total']) * 100, 1) : 0 }}%</td>
                        </tr>
                        <tr>
                            <td><strong>Resolved</strong></td>
                            <td><span class="badge bg-success">{{ $stats['resolved'] }}</span></td>
                            <td>{{ $stats['total'] > 0 ? round(($stats['resolved'] / $stats['total']) * 100, 1) : 0 }}%</td>
                        </tr>
                        <tr>
                            <td><strong>Closed</strong></td>
                            <td><span class="badge bg-secondary">{{ $stats['closed'] }}</span></td>
                            <td>{{ $stats['total'] > 0 ? round(($stats['closed'] / $stats['total']) * 100, 1) : 0 }}%</td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>

        <div class="col-md-6">
            <div class="card" style="border-left: 4px solid var(--success-color);">
                <div class="card-header section-card-header">
                    <h6 class="mb-0">Resolution Rate</h6>
                </div>
                <div class="card-body text-center">
                    @php
                        $total = $stats['total'];
                        $resolved = $stats['resolved'] + $stats['closed'];
                        $rate = $total > 0 ? round(($resolved / $total) * 100, 1) : 0;
                    @endphp
                    <h2 style="color: var(--success-color);">{{ $rate }}%</h2>
                    <p class="text-muted mb-0">
                        {{ $resolved }} of {{ $total }} inquiries completed
                    </p>
                </div>
            </div>

            <div class="card mt-3" style="border-left: 4px solid var(--primary-color);">
                <div class="card-header section-card-header">
                    <h6 class="mb-0"><i class="fas fa-tags"></i> Frequently Asked Concerns</h6>
                </div>
                <div class="card-body">
                    @forelse ($frequentConcerns as $concern)
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span>{{ Str::limit($concern->subject, 42) }}</span>
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
        </div>
    </div>
@endsection
