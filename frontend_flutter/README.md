# Flutter Frontend

This folder contains the Flutter mobile and web UI for the Laravel Inquiry System API.

## Screens

- Login
- Dashboard
- Inquiry list
- Create/edit inquiry form
- Profile/settings

## Run

Start Laravel first:

```bash
php artisan migrate
php artisan serve
```

Then run Flutter:

```bash
cd frontend_flutter
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

For the Android emulator, use:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```
