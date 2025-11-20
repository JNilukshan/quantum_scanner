# 🔬 Quantum Scanner

A modern, real-time QR code scanning system with mobile app and web dashboard integration using Socket.IO.

## Features

- **Modern Design**: Clean and intuitive user interface with smooth animations
- **Fast QR Scanning**: Quick and accurate QR code detection using camera
- **Multiple Format Support**: Supports various QR code formats including URLs, text, emails, and phone numbers
- **Smart Actions**: Automatic detection of content type with appropriate action buttons
- **Flash Support**: Toggle flashlight for scanning in low-light conditions
- **Copy & Share**: Easy copying to clipboard and URL launching
- **Splash Screen**: Beautiful animated splash screen with gradient background

## Screenshots

### Splash Screen
- Animated gradient background
- App logo with smooth scaling animation
- Loading indicator

### QR Scanner
- Real-time camera preview
- Animated scan overlay with corner markers
- Moving scan line animation
- Flash toggle button
- Intuitive instructions

### Scan Results
- Beautiful result dialog with content type detection
- Smart action buttons based on scanned content
- Copy to clipboard functionality
- Direct URL opening for web links

## Technical Details

### Built With
- **Flutter**: Cross-platform mobile framework
- **qr_code_scanner**: Camera-based QR code scanning
- **Google Fonts**: Poppins font family for modern typography
- **Material Design 3**: Latest Material Design components
- **Permission Handler**: Camera permission management

### Architecture
- Clean widget separation
- Reusable components
- Proper state management
- Smooth animations and transitions

### Permissions Required
- **Camera**: Required for QR code scanning
- **Flashlight**: Optional for low-light scanning

## Installation

1. Ensure Flutter is installed on your development machine
2. Clone this repository
3. Navigate to the mobile directory
4. Run `flutter pub get` to install dependencies
5. Run `flutter run` to start the app

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/
│   ├── splash_screen.dart   # Animated splash screen
│   └── qr_scanner_screen.dart # Main QR scanning interface
└── widgets/
    ├── scan_result_dialog.dart # Result display dialog
    └── scan_overlay.dart     # Custom scan overlay animation
```

## Features in Detail

### QR Code Detection
- Real-time camera scanning
- Automatic code recognition
- Support for various QR code types
- Haptic feedback on successful scan

### Content Type Recognition
- **URLs**: Direct opening with web browser
- **Email addresses**: Automatic email app integration
- **Phone numbers**: Direct calling capability
- **Plain text**: Easy copying and sharing

### User Experience
- Smooth page transitions
- Loading states and animations
- Error handling and permission requests
- Responsive design for different screen sizes

## Development

### Adding New Features
- Follow the existing architecture pattern
- Use proper widget separation
- Implement smooth animations
- Add proper error handling

### Customization
- Colors and themes can be modified in `main.dart`
- Animations can be adjusted in respective widget files
- Scanner overlay can be customized in `scan_overlay.dart`

## License

This project is part of the VespineIT Siyapatha quantum scanner application.

---

**Quantum Scanner** - Scan • Decode • Discover