@extends('layouts.app')

@section('title', 'Inquiry: ' . $inquiry->subject)

@section('content')
    <div class="row mb-3">
        <div class="col-12">
            <a href="{{ auth()->user()->isSuperAdmin() ? route('superadmin.dashboard') : route('admin.inquiry.inbox') }}" class="btn btn-sm btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to Inbox
            </a>
        </div>
    </div>

    <div class="row">
        <div class="col-md-8">
            <div class="card mb-4">
                <div class="card-header section-card-header">
                    <h5 class="mb-0">
                        <i class="fas fa-file"></i> {{ $inquiry->subject }}
                    </h5>
                </div>
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <p class="mb-1"><strong>Student:</strong></p>
                            <p class="mb-3">
                                {{ $inquiry->student->name }}<br>
                                <small class="text-muted">{{ $inquiry->student->email }}</small>
                                @if ($inquiry->student->user_identifier)
                                    <br>
                                    <small class="text-muted">ID: {{ $inquiry->student->user_identifier }}</small>
                                @endif
                            </p>
                        </div>
                        <div class="col-md-6 text-end">
                            <p class="mb-1"><strong>Status:</strong></p>
                            <span class="badge status-{{ $inquiry->status }}">
                                {{ ucfirst(str_replace('_', ' ', $inquiry->status)) }}
                            </span>
                        </div>
                    </div>
                    <hr>
                    <h6>Student's Inquiry:</h6>
                    <p class="text-muted">{{ $inquiry->description }}</p>
                    @if ($inquiry->resolution_notes)
                        <hr>
                        <h6>Resolution Notes:</h6>
                        <p class="text-muted mb-0">{{ $inquiry->resolution_notes }}</p>
                    @endif
                </div>
            </div>

            <div class="card">
                <div class="card-header section-card-header">
                    <h5 class="mb-0">
                        <i class="fas fa-comments"></i> Conversation
                    </h5>
                </div>
                <div class="card-body" style="max-height: 500px; overflow-y: auto; background-color: #f9fafb;">
                    @forelse ($messages as $message)
                        <div class="message-item @if ($message->user_id === auth()->id()) sent @else received @endif">
                            <strong>{{ $message->user->name }}</strong>
                            <small class="text-muted d-block mb-2">{{ $message->created_at->diffForHumans() }}</small>
                            <p class="mb-0">{{ $message->message }}</p>
                            @if ($message->attachment_path)
                                <small class="mt-2 d-block">
                                    <i class="fas fa-paperclip"></i>
                                    <a href="{{ route('message.download', $message) }}">Download attachment</a>
                                </small>
                            @endif
                        </div>
                    @empty
                        <p class="text-center text-muted py-4">
                            <i class="fas fa-comments"></i> No messages yet
                        </p>
                    @endforelse
                </div>
                <div class="card-footer" style="background-color: white;">
                    <form action="{{ route('message.store', $inquiry) }}" method="POST" enctype="multipart/form-data">
                        @csrf
                        <div class="mb-2">
                            <textarea name="message" class="form-control" rows="2" placeholder="Type your response..."></textarea>
                        </div>
                        <div class="row g-2 align-items-center">
                            <div class="col-md-8">
                                <input type="file" name="attachment" class="form-control" accept=".pdf,.doc,.docx,.xls,.xlsx,.csv,.txt,.jpg,.jpeg,.png">
                                <small class="text-muted">Attach registrar records up to 5 MB.</small>
                            </div>
                            <div class="col-md-4 d-grid">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-paper-plane"></i> Send
                                </button>
                            </div>
                        </div>
                    </form>
                    @if ($messages->hasPages())
                        <div class="mt-3">
                            {{ $messages->links() }}
                        </div>
                    @endif
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card mb-3" style="border-left: 4px solid var(--primary-color);">
                <div class="card-header section-card-header">
                    <h6 class="mb-0">
                        <i class="fas fa-sync-alt"></i> Update Status
                    </h6>
                </div>
                <div class="card-body">
                    <form action="{{ auth()->user()->isSuperAdmin() ? route('superadmin.inquiry.update-status', $inquiry) : route('admin.inquiry.update-status', $inquiry) }}" method="POST">
                        @csrf
                        @method('PUT')
                        <div class="mb-3">
                            <label for="status" class="form-label">Status</label>
                            <select class="form-select" name="status" id="status" required>
                                @foreach ($statuses as $value => $label)
                                    <option value="{{ $value }}" @selected($inquiry->status === $value)>{{ $label }}</option>
                                @endforeach
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="resolution_notes" class="form-label">Resolution Notes</label>
                            <textarea class="form-control" name="resolution_notes" id="resolution_notes" rows="3" placeholder="Optional notes for resolved or closed inquiries">{{ old('resolution_notes', $inquiry->resolution_notes) }}</textarea>
                        </div>

                        <button type="submit" class="btn btn-primary w-100">
                            <i class="fas fa-check"></i> Update Status
                        </button>
                    </form>
                </div>
            </div>

            <div class="card" id="student-information" style="border-left: 4px solid var(--primary-color);">
                <div class="card-header section-card-header">
                    <h6 class="mb-0">
                        <i class="fas fa-user-graduate"></i> Student Information
                    </h6>
                </div>
                <div class="card-body small">
                    <p class="mb-2">
                        <strong>Name:</strong><br>
                        {{ $inquiry->student->name }}
                    </p>
                    <p class="mb-2">
                        <strong>Email:</strong><br>
                        <a href="mailto:{{ $inquiry->student->email }}">{{ $inquiry->student->email }}</a>
                    </p>
                    @if ($inquiry->student->user_identifier)
                        <p class="mb-2">
                            <strong>Student ID:</strong><br>
                            {{ $inquiry->student->user_identifier }}
                        </p>
                    @endif
                    @if ($inquiry->student->phone)
                        <p class="mb-2">
                            <strong>Contact Number:</strong><br>
                            {{ $inquiry->student->phone }}
                        </p>
                    @endif
                    @if ($inquiry->student->address)
                        <p class="mb-2">
                            <strong>Address:</strong><br>
                            {{ $inquiry->student->address }}
                        </p>
                    @endif
                    @if ($inquiry->student->bio)
                        <p class="mb-0">
                            <strong>Profile Notes:</strong><br>
                            {{ $inquiry->student->bio }}
                        </p>
                    @endif
                </div>
            </div>

            <div class="card mt-3" style="border-left: 4px solid var(--secondary-color);">
                <div class="card-header section-card-header">
                    <h6 class="mb-0">
                        <i class="fas fa-info-circle"></i> Inquiry Details
                    </h6>
                </div>
                <div class="card-body small">
                    <p class="mb-2">
                        <strong>Inquiry ID:</strong><br>
                        #{{ $inquiry->id }}
                    </p>
                    <p class="mb-2">
                        <strong>Department:</strong><br>
                        {{ $inquiry->department->name }}
                    </p>
                    <p class="mb-2">
                        <strong>Category:</strong><br>
                        {{ ucfirst(str_replace('_', ' ', $inquiry->category ?? 'general')) }}
                    </p>
                    <p class="mb-2">
                        <strong>Submitted:</strong><br>
                        {{ $inquiry->created_at->format('M d, Y H:i') }}
                    </p>
                    @if ($inquiry->resolved_at)
                        <p class="mb-2">
                            <strong>Resolved:</strong><br>
                            {{ $inquiry->resolved_at->format('M d, Y H:i') }}
                        </p>
                    @endif
                    <p class="mb-0">
                        <strong>Total Messages:</strong><br>
                        {{ $inquiry->messages()->count() }}
                    </p>
                </div>
            </div>

            @if (auth()->user()->isDepartmentAdmin() && isset($departments) && $departments->isNotEmpty())
                <div class="card mt-3" style="border-left: 4px solid var(--warning-color);">
                    <div class="card-header section-card-header">
                        <h6 class="mb-0">
                            <i class="fas fa-share"></i> Forward Inquiry
                        </h6>
                    </div>
                    <div class="card-body">
                        <form action="{{ route('admin.inquiry.forward', $inquiry) }}" method="POST">
                            @csrf
                            @method('PUT')
                            <div class="mb-3">
                                <label for="department_id" class="form-label">Forward to Department</label>
                                <select class="form-select" id="department_id" name="department_id" required>
                                    <option value="">Select department</option>
                                    @foreach ($departments as $department)
                                        <option value="{{ $department->id }}">{{ $department->name }}</option>
                                    @endforeach
                                </select>
                            </div>
                            <div class="mb-3">
                                <label for="forward_note" class="form-label">Forward Note</label>
                                <textarea class="form-control" id="forward_note" name="forward_note" rows="2" placeholder="Optional note for context"></textarea>
                            </div>
                            <button type="submit" class="btn btn-secondary w-100">
                                <i class="fas fa-share"></i> Forward
                            </button>
                        </form>
                    </div>
                </div>
            @endif
        </div>
    </div>
@endsection

@push('scripts')
    <script>
        // Auto-scroll to bottom of messages
        const messagesDiv = document.querySelector('[style*="max-height"]');
        if (messagesDiv) {
            messagesDiv.scrollTop = messagesDiv.scrollHeight;
        }
    </script>
@endpush
