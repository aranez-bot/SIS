@extends('layouts.app')

@section('title', 'System Settings')

@section('content')
    <h1 class="mb-4">
        <i class="fas fa-sliders-h"></i> System Settings
    </h1>

    <div class="row">
        <div class="col-md-4 mb-3">
            <div class="card h-100">
                <div class="card-header section-card-header">
                    <h5 class="mb-0">Inquiry Status Labels</h5>
                </div>
                <div class="card-body">
                    @foreach ($settings['statuses'] as $status)
                        <span class="badge status-{{ $status }} mb-2">{{ ucfirst(str_replace('_', ' ', $status)) }}</span>
                    @endforeach
                </div>
            </div>
        </div>
        <div class="col-md-4 mb-3">
            <div class="card h-100">
                <div class="card-header section-card-header">
                    <h5 class="mb-0">Inquiry Categories</h5>
                </div>
                <div class="card-body">
                    @foreach ($settings['categories'] as $category)
                        <span class="badge bg-light text-dark mb-2">{{ ucfirst($category) }}</span>
                    @endforeach
                </div>
            </div>
        </div>
        <div class="col-md-4 mb-3">
            <div class="card h-100">
                <div class="card-header section-card-header">
                    <h5 class="mb-0">Notification Types</h5>
                </div>
                <div class="card-body">
                    @foreach ($settings['notifications'] as $type)
                        <span class="badge bg-light text-dark mb-2">{{ ucfirst(str_replace('_', ' ', $type)) }}</span>
                    @endforeach
                </div>
            </div>
        </div>
    </div>
@endsection
