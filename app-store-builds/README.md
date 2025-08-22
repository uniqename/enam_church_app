# Faith Klinik Ministries - App Store Build Files

This folder contains all the production-ready files and documentation needed for submitting the Faith Klinik Ministries app to both Google Play Store and Apple App Store.

## 📱 Build Files

### Android (Google Play Store)
- **`app-release.aab`** - Android App Bundle for Google Play Store submission
- **`app-release-unsigned.apk`** - APK file for testing purposes

### iOS (Apple App Store)
- **`faith-klinik-app.ipa`** - iOS App Store distribution package

## 📋 Submission Documentation

### Google Play Store
- **`Google_Play_Store_Submission_Packet.md`** - Complete submission guide including:
  - App metadata and descriptions
  - Screenshot requirements
  - Privacy policy requirements
  - Testing instructions
  - Store listing optimization tips

### Apple App Store
- **`Apple_App_Store_Submission_Packet.md`** - Comprehensive submission guide including:
  - App Store Connect setup
  - Screenshot specifications
  - Review guidelines compliance
  - Privacy details configuration
  - Launch strategy recommendations

## 🚀 Quick Submission Guide

### For Google Play Store:
1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app with package name: `com.faithklinikministries.app`
3. Upload `app-release.aab` to Internal Testing first
4. Follow the detailed guide in `Google_Play_Store_Submission_Packet.md`
5. Complete store listing with provided descriptions and requirements

### For Apple App Store:
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Create new app with bundle ID: `com.faithklinikministries.app`
3. Upload `faith-klinik-app.ipa` using Xcode or Application Loader
4. Follow the detailed guide in `Apple_App_Store_Submission_Packet.md`
5. Configure app metadata and submit for review

## ✅ Pre-Submission Checklist

### Before Submitting to Either Store:
- [ ] Create privacy policy and host it online
- [ ] Set up support email address
- [ ] Take required screenshots for both platforms
- [ ] Test apps thoroughly on multiple devices
- [ ] Review all app content for store policy compliance
- [ ] Prepare app icons in required sizes
- [ ] Set up developer accounts on both platforms

### Testing Recommendations:
- [ ] Install and test APK on multiple Android devices
- [ ] Test IPA installation via TestFlight
- [ ] Verify all external integrations (Zoom, WhatsApp, etc.)
- [ ] Test children's portal security features
- [ ] Confirm prayer request submission works
- [ ] Verify live streaming functionality
- [ ] Test communication features

## 📊 App Information Summary

| Platform | File | Package/Bundle ID | Version | Size |
|----------|------|-------------------|---------|------|
| Android | app-release.aab | com.faithklinikministries.app | 1.0.0 (1) | ~15MB |
| iOS | faith-klinik-app.ipa | com.faithklinikministries.app | 1.0 (1) | ~25MB |

## 🔧 Build Details

### Android Build Environment:
- **Target SDK**: 34 (Android 14)
- **Minimum SDK**: 21 (Android 5.0)  
- **Java Version**: 21
- **Build Tool**: Gradle 8.10.2
- **Framework**: Capacitor + React.js

### iOS Build Environment:
- **Deployment Target**: iOS 14.0+
- **Architecture**: Universal (arm64, x86_64)
- **Build Configuration**: Release
- **Framework**: Capacitor + React.js
- **Code Signing**: Automatic (Development Team: U5JG38RBYM)

## 📞 Support Information

For technical issues or questions about the app submission process:
- Check the detailed submission packets for guidance
- Test the builds thoroughly before submission
- Ensure all external services (Zoom links, etc.) are configured correctly
- Have privacy policy and support materials ready before submission

## 🎯 Next Steps

1. **Immediate**: Review both submission packets thoroughly
2. **Before Submission**: Complete all checklist items above
3. **During Review**: Monitor app store dashboards for feedback
4. **After Approval**: Plan marketing and church rollout strategy

Good luck with your app store submissions! 🚀