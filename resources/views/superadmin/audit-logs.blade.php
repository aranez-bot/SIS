@extends('layouts.app')

@section('title', 'Audit Logs')

@section('content')
    <h1 class="mb-4">
        <i class="fas fa-clipboard-list"></i> Audit Logs
    </h1>

    <div class="row">
        <div class="col-lg-4 mb-3">
            <div class="card h-100">
                <div class="card-header section-card-header"><h5 class="mb-0">Recent Users</h5></div>
                <div class="card-body">
                    @foreach ($recentUsers as $user)
                        <p class="mb-2">
                            <strong>{{ $user->name }}</strong><br>
                            <small class="text-muted">{{ ucfirst(str_replace('_', ' ', $user->user_type)) }} - {{ $user->created_at->format('M d, Y H:i') }}</small>
                        </p>
                    @endforeach
                </div>
            </div>
        </div>
        <div class="col-lg-4 mb-3">
            <div class="card h-100">
                <div class="card-header section-card-header"><h5 class="mb-0">Inquiry Updates</h5></div>
                <div class="card-body">
                    @foreach ($recentInquiries as $inquiry)
                        <p class="mb-2">
                            <strong>#{{ $inquiry->id }} {{ $inquiry->subject }}</strong><br>
                            <small class="text-muted">{{ $inquiry->department->name }} - {{ ucfirst(str_replace('_', ' ', $inquiry->status)) }} - {{ $inquiry->updated_at->format('M d, Y H:i') }}</small>
                        </p>
                    @endforeach
                </div>
            </div>
        </div>
        <div class="col-lg-4 mb-3">
            <div class="card h-100">
                <div class="card-header section-card-header"><h5 class="mb-0">Notifications</h5></div>
                <div class="card-body">
                    @foreach ($recentNotifications as $notification)
                        <p class="mb-2">
                            <strong>{{ $notification->title }}</strong><br>
                            <small class="text-muted">{{ $notification->user->name ?? 'User' }} - {{ $notification->created_at->format('M d, Y H:i') }}</small>
                        </p>
                    @endforeach
                </div>
            </div>
        </div>
    </div>
@endsection
