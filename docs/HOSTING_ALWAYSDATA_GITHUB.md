# Hosting Guide: Alwaysdata + GitHub Releases + Pages

This setup keeps the Laravel backend/API on Alwaysdata, stores data in Alwaysdata MySQL, publishes the APK through GitHub Releases, and hosts the public download page from `docs/` on GitHub Pages or Cloudflare Pages.

## 1. Laravel Backend/API on Alwaysdata

1. Create an Alwaysdata account and site.
2. Create or enable SSH/SFTP access in `Remote access > SSH/SFTP`.
3. Upload or clone this project into your Alwaysdata home directory.
4. Set the site root/document directory to the Laravel `public` folder.
5. On the Alwaysdata server, run:

```bash
cd ~/inquiry-system
composer install --no-dev --optimize-autoloader
cp .env.example .env
php artisan key:generate
php artisan migrate --force
php artisan storage:link
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

Use these production values in `.env`:

```env
APP_NAME="Student Inquiry System"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://yourname.alwaysdata.net

DB_CONNECTION=mysql
DB_HOST=mysql-yourname.alwaysdata.net
DB_PORT=3306
DB_DATABASE=yourname_inquiry
DB_USERNAME=yourname
DB_PASSWORD=your_database_password

SESSION_DRIVER=database
CACHE_STORE=database
QUEUE_CONNECTION=database

CORS_ALLOWED_ORIGINS=https://aranez-bot.github.io,https://YOUR_PROJECT.pages.dev
APK_DOWNLOAD_URL=https://github.com/aranez-bot/SIS/releases/latest/download/student-inquiry.apk
```

The API URL for Flutter builds is:

```text
https://yourname.alwaysdata.net/api
```

## 2. Alwaysdata MySQL

Create the database and user in `Databases > MySQL`. Alwaysdata uses this host pattern:

```text
mysql-yourname.alwaysdata.net
```

After saving `.env`, run:

```bash
php artisan config:clear
php artisan migrate --force
php artisan config:cache
```

## 3. Build the Flutter APK

From your local project:

```bash
cd frontend_flutter
flutter clean
flutter pub get
flutter build apk --release --dart-define=API_BASE_URL=https://yourname.alwaysdata.net/api --dart-define=APK_DOWNLOAD_URL=https://github.com/aranez-bot/SIS/releases/latest/download/student-inquiry.apk
```

The APK will be created at:

```text
frontend_flutter/build/app/outputs/flutter-apk/app-release.apk
```

Rename it to:

```text
student-inquiry.apk
```

## 4. Upload APK to GitHub Releases

Create a release tag such as `v1.0.0`, then upload the APK:

```bash
gh release create v1.0.0 student-inquiry.apk --title "v1.0.0" --notes "Student Inquiry Android APK"
```

For later APK replacements on the same tag:

```bash
gh release upload v1.0.0 student-inquiry.apk --clobber
```

The stable download URL is:

```text
https://github.com/aranez-bot/SIS/releases/latest/download/student-inquiry.apk
```

This repo also includes `.github/workflows/release-apk.yml`. In GitHub, set repository variables:

```text
API_BASE_URL=https://yourname.alwaysdata.net/api
APK_DOWNLOAD_URL=https://github.com/aranez-bot/SIS/releases/latest/download/student-inquiry.apk
```

Then push a tag such as `v1.0.0`; the workflow builds the APK and uploads it to that GitHub Release.

## 5. Host the Download Page

The static download page is in:

```text
docs/index.html
```

Edit the config block near the bottom of that file:

```js
const config = {
  apiUrl: 'https://yourname.alwaysdata.net/api',
  webAppUrl: 'https://yourname.alwaysdata.net',
  apkUrl: 'https://github.com/aranez-bot/SIS/releases/latest/download/student-inquiry.apk'
};
```

For GitHub Pages, use the included `.github/workflows/deploy-pages.yml` workflow. In the repository settings, set Pages to GitHub Actions. The download page URL will be:

```text
https://aranez-bot.github.io/SIS/
```

For Cloudflare Pages, connect the GitHub repository and use:

```text
Build command: none
Build output directory: docs
```

## References

- Alwaysdata SSH: https://help.alwaysdata.com/en/web-hosting/remote-access/ssh/
- Alwaysdata MySQL: https://help.alwaysdata.com/en/web-hosting/databases/mariadb/
- Alwaysdata PHP: https://help.alwaysdata.com/en/languages/php/
- GitHub Pages: https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site
- GitHub Release uploads: https://cli.github.com/manual/gh_release_upload
- Cloudflare Pages GitHub integration: https://developers.cloudflare.com/pages/configuration/git-integration/github-integration/
