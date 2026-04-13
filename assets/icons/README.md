# App Icon Setup Instructions

The Corporate Ladies logo should be placed in this directory as:
- `app_icon.png` (1024x1024 pixels recommended)

To generate all required icon sizes for Android and iOS, use the flutter_launcher_icons package:

1. Add to pubspec.yaml:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.4
```

2. Add configuration to pubspec.yaml:
```yaml
flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icons/app_icon.png"
  min_sdk_android: 21
  adaptive_icon_background: "#000000"
  adaptive_icon_foreground: "assets/icons/app_icon.png"
```

3. Run: `flutter pub get && flutter pub run flutter_launcher_icons`

The logo features:
- Golden silhouette of a woman in a suit with wide-brimmed hat
- "Corporate Ladies" text in elegant white script font
- Black background
- Horizontal lines on either side of "Ladies"
