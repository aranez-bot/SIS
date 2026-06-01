@extends('layouts.app')

@section('title', 'Backup and Maintenance')

@section('content')
    <div class="d-flex flex-wrap gap-2 justify-content-between align-items-center mb-4">
        <h1 class="mb-0">
            <i class="fas fa-database"></i> Backup and Maintenance
        </h1>
        <a href="{{ route('superadmin.maintenance.backup') }}" class="btn btn-primary">
            <i class="fas fa-download"></i> Download JSON Backup
        </a>
    </div>

    <div class="row">
        @foreach ($summary as $label => $count)
            <div class="col-md-3 mb-3">
                <div class="stat-card">
                    <i class="fas fa-database" style="font-size: 2rem; color: var(--primary-color);"></i>
                    <h3>{{ $count }}</h3>
                    <p>{{ ucfirst($label) }}</p>
                </div>
            </div>
        @endforeach
    </div>

    <div class="card">
        <div class="card-header section-card-header">
            <h5 class="mb-0">System Monitoring</h5>
        </div>
        <div class="card-body">
            <p class="mb-2"><strong>Database:</strong> Connected</p>
            <p class="mb-2"><strong>Backup Format:</strong> JSON export of core records</p>
            <p class="mb-0 text-muted">Use backups before major maintenance, data cleanup, or deployment work.</p>
        </div>
    </div>
@endsection
