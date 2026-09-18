# Flutter

A modern Flutter-based mobile application utilizing the latest mobile development technologies and tools for building responsive cross-platform applications.

## 📋 Prerequisites

- Flutter SDK (^3.38.4)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for iOS development)

## 🛠️ Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the application:

To run the app with environment variables defined in an env.json file, follow the steps mentioned below:
1. Through CLI
    ```bash
    flutter run --dart-define-from-file=env.json
    ```
2. For VSCode
    - Open .vscode/launch.json (create it if it doesn't exist).
    - Add or modify your launch configuration to include --dart-define-from-file:
    ```json
    {
        "version": "0.2.0",
        "configurations": [
            {
                "name": "Launch",
                "request": "launch",
                "type": "dart",
                "program": "lib/main.dart",
                "args": [
                    "--dart-define-from-file",
                    "env.json"
                ]
            }
        ]
    }
    ```
3. For IntelliJ / Android Studio
    - Go to Run > Edit Configurations.
    - Select your Flutter configuration or create a new one.
    - Add the following to the "Additional arguments" field:
    ```bash
    --dart-define-from-file=env.json
    ```

## 📁 Project Structure

```
flutter_app/
├── android/            # Android-specific configuration
├── ios/                # iOS-specific configuration
├── lib/
│   ├── core/           # Core utilities and services
│   │   └── utils/      # Utility classes
│   ├── presentation/   # UI screens and widgets
│   │   └── splash_screen/ # Splash screen implementation
│   ├── routes/         # Application routing
│   ├── theme/          # Theme configuration
│   ├── widgets/        # Reusable UI components
│   └── main.dart       # Application entry point
├── assets/             # Static assets (images, fonts, etc.)
├── pubspec.yaml        # Project dependencies and configuration
└── README.md           # Project documentation
```

## 🧩 Adding Routes

To add new routes to the application, update the `lib/routes/app_routes.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:package_name/presentation/home_screen/home_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    // Add more routes as needed
  }
}
```

## 🎨 Theming

This project includes a comprehensive theming system with both light and dark themes:

```dart
// Access the current theme
ThemeData theme = Theme.of(context);

// Use theme colors
Color primaryColor = theme.colorScheme.primary;
```

The theme configuration includes:
- Color schemes for light and dark modes
- Typography styles
- Button themes
- Input decoration themes
- Card and dialog themes

## 📱 Responsive Design

The app is built with responsive design using the Sizer package:

```dart
// Example of responsive sizing
Container(
  width: 50.w, // 50% of screen width
  height: 20.h, // 20% of screen height
  child: Text('Responsive Container'),
)
```
## 📦 Deployment

Build the application for production:

```bash
# For Android
flutter build apk --release

# For iOS
flutter build ios --release
```

## Account deletion website

The public deletion page is `web/delete-account.html`. Upload it to IONOS at:

```text
https://www.alliancematrimony.online/delete-account.html
```

The page calls the `account-deletion` Supabase Edge Function. Deploy the migration and function from the project root:

```bash
supabase db push
supabase functions deploy account-deletion --no-verify-jwt
supabase secrets set RESEND_API_KEY=your_resend_key
supabase secrets set DELETION_FROM_EMAIL="Alliance Matrimony <no-reply@alliancematrimony.online>"
supabase secrets set PUBLIC_DELETION_URL=https://www.alliancematrimony.online/delete-account.html
```

The sending domain must be verified in Resend before deletion emails can be delivered. The Supabase service-role key is used only by the Edge Function and must never be placed in the webpage or the Flutter app.

### GitHub Pages alternative

The repository includes `.github/workflows/deploy-deletion-page.yml`. Push the project to GitHub, then open **Settings → Pages** and set the source to **GitHub Actions**. The workflow publishes `web/delete-account.html` at both `/` and `/delete-account.html`.

The `web/CNAME` file configures the custom domain. In the domain's DNS settings, point `www` to the GitHub Pages hostname shown by GitHub, usually:

```text
your-github-username.github.io
```

Do not point `www` to `alliancematrimony.online` when using GitHub Pages. In GitHub **Settings → Pages → Custom domain**, enter:

```text
www.alliancematrimony.online
```

Then enable **Enforce HTTPS** after DNS has propagated.

## 🙏 Acknowledgments
- Built with [Rocket.new](https://rocket.new)
- Powered by [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- Styled with Material Design

Built with ❤️ on Rocket.new
