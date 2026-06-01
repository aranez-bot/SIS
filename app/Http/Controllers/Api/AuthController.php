<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Department;
use App\Models\User;
use Illuminate\Auth\Events\Registered;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'user_identifier' => ['required', 'string', 'max:50', 'unique:users,user_identifier'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'confirmed', 'min:8'],
            'department_id' => ['nullable', 'exists:departments,id'],
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'user_identifier' => $validated['user_identifier'],
            'email' => $validated['email'],
            'department_id' => $validated['department_id'] ?? null,
            'password' => Hash::make($validated['password']),
            'user_type' => 'student',
        ]);

        event(new Registered($user));

        return response()->json([
            'user' => $this->userPayload($user),
            'token' => $user->createToken('flutter-client')->plainTextToken,
        ], 201);
    }

    public function login(Request $request)
    {
        $validated = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $user = User::where('email', $validated['email'])->first();

        if (! $user || ! Hash::check($validated['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials do not match our records.'],
            ]);
        }

        if (! $user->is_active) {
            throw ValidationException::withMessages([
                'email' => ['This account is deactivated. Please contact the system administrator.'],
            ]);
        }

        return response()->json([
            'user' => $this->userPayload($user),
            'token' => $user->createToken('flutter-client')->plainTextToken,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()?->delete();

        return response()->json(['message' => 'Logged out.']);
    }

    public function me(Request $request)
    {
        return response()->json(['user' => $this->userPayload($request->user())]);
    }

    private function userPayload(User $user): array
    {
        $user->loadMissing('department');

        return [
            'id' => $user->id,
            'name' => $user->name,
            'user_identifier' => $user->user_identifier,
            'email' => $user->email,
            'user_type' => $user->user_type,
            'department_id' => $user->department_id,
            'department' => $user->department,
            'phone' => $user->phone,
            'address' => $user->address,
            'bio' => $user->bio,
        ];
    }
}
