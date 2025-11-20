# Animation Assets

This directory contains Lottie animation files for the Quantum Scanner app.

## Recommended Animations

- **splash_animation.json**: Loading animation for splash screen
- **scan_animation.json**: Scanning indicator animation
- **success_animation.json**: Success animation for completed scans

## Usage

Add Lottie animation files to this directory and reference them in the Flutter code using the `lottie` package.

Example:
```dart
Lottie.asset('assets/animations/splash_animation.json')
```

## File Format

- Use `.json` format for Lottie animations
- Keep file sizes optimized for mobile performance
- Test animations on different screen sizes