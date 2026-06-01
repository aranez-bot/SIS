@extends('layouts.app')

@section('title', 'Department FAQ')

@section('content')
    <div class="d-flex flex-wrap gap-2 justify-content-between align-items-center mb-4">
        <div>
            <h1 class="mb-1">
                <i class="fas fa-question-circle"></i> Department FAQ
            </h1>
            <p class="text-muted mb-0">Manage common answers for {{ $department->name }} services.</p>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-5 mb-4">
            <div class="card">
                <div class="card-header section-card-header">
                    <h5 class="mb-0"><i class="fas fa-plus-circle"></i> Add FAQ</h5>
                </div>
                <div class="card-body">
                    <form action="{{ route('admin.faqs.store') }}" method="POST">
                        @csrf
                        <div class="mb-3">
                            <label for="question" class="form-label">Question</label>
                            <input type="text" class="form-control" id="question" name="question" required placeholder="Example: How do I request a transcript?">
                        </div>
                        <div class="mb-3">
                            <label for="category" class="form-label">Category</label>
                            <input type="text" class="form-control" id="category" name="category" placeholder="Registrar, Records, Finance">
                        </div>
                        <div class="mb-3">
                            <label for="answer" class="form-label">Answer</label>
                            <textarea class="form-control" id="answer" name="answer" rows="5" required placeholder="Write the department-approved answer."></textarea>
                        </div>
                        <div class="form-check form-switch mb-3">
                            <input class="form-check-input" type="checkbox" role="switch" id="is_active" name="is_active" value="1" checked>
                            <label class="form-check-label" for="is_active">Active</label>
                        </div>
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="fas fa-save"></i> Save FAQ
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <div class="col-lg-7">
            <div class="card">
                <div class="card-header section-card-header">
                    <div class="d-flex justify-content-between align-items-center">
                        <h5 class="mb-0"><i class="fas fa-list"></i> Existing FAQs</h5>
                        <span class="badge bg-light text-dark">{{ $faqs->total() }} Total</span>
                    </div>
                </div>
                <div class="card-body">
                    @forelse ($faqs as $faq)
                        <div class="border rounded p-3 mb-3">
                            <form action="{{ route('admin.faqs.update', $faq) }}" method="POST">
                                @csrf
                                @method('PUT')
                                <div class="mb-2">
                                    <label class="form-label">Question</label>
                                    <input type="text" class="form-control" name="question" value="{{ $faq->question }}" required>
                                </div>
                                <div class="mb-2">
                                    <label class="form-label">Category</label>
                                    <input type="text" class="form-control" name="category" value="{{ $faq->category }}">
                                </div>
                                <div class="mb-2">
                                    <label class="form-label">Answer</label>
                                    <textarea class="form-control" name="answer" rows="4" required>{{ $faq->answer }}</textarea>
                                </div>
                                <div class="d-flex flex-wrap gap-2 justify-content-between align-items-center">
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" role="switch" name="is_active" value="1" @checked($faq->is_active)>
                                        <label class="form-check-label">Active</label>
                                    </div>
                                    <div class="d-flex gap-2">
                                        <button type="submit" class="btn btn-sm btn-primary">
                                            <i class="fas fa-save"></i> Update
                                        </button>
                                    </div>
                                </div>
                            </form>
                            <form action="{{ route('admin.faqs.delete', $faq) }}" method="POST" class="mt-2" onsubmit="return confirm('Delete this FAQ?')">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="btn btn-sm btn-outline-danger">
                                    <i class="fas fa-trash"></i> Delete
                                </button>
                            </form>
                        </div>
                    @empty
                        <div class="text-center text-muted py-5">
                            <i class="fas fa-question-circle fa-2x mb-3"></i>
                            <p class="mb-0">No FAQs yet. Add the first common answer for your department.</p>
                        </div>
                    @endforelse
                </div>
                @if ($faqs->hasPages())
                    <div class="card-footer bg-white">
                        {{ $faqs->links() }}
                    </div>
                @endif
            </div>
        </div>
    </div>
@endsection
