# Faith Klinik Ministries - Build Instructions

## 🚨 Quick Fix for the 404 Error

The web app is now deployed and working! Visit:
**https://uniqename.github.io/enam_church_app**

The 404.html redirect has been added to fix GitHub Pages routing issues.

---

## 📱 Mobile App Files (IPA & AAB)

Due to the Java version compatibility issues with the current Capacitor setup, here are the recommended approaches to create the mobile app files:

### Method 1: Use Android Studio & Xcode (Recommended)

#### For Android (AAB file):
1. **Open Android Studio**:
   ```bash
   npx cap open android
   ```

2. **In Android Studio**:
   - File → Sync Project with Gradle Files
   - Build → Generate Signed Bundle/APK
   - Choose "Android App Bundle"
   - Create/select keystore file
   - Build the AAB file

3. **Output**: The AAB file will be in `android/app/build/outputs/bundle/release/`

#### For iOS (IPA file):
1. **Open Xcode**:
   ```bash
   npx cap open ios
   ```

2. **In Xcode**:
   - Select "Faith Klinik Ministries" target
   - Product → Archive
   - Window → Organizer → Archives
   - Export for App Store distribution

---

### Method 2: Fix Java Version Issues

To fix the Java compatibility issues for command-line building:

1. **Install Java 21**:
   ```bash
   brew install openjdk@21
   export JAVA_HOME="/opt/homebrew/opt/openjdk@21"
   export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"
   ```

2. **Build Android**:
   ```bash
   cd android
   ./gradlew clean bundleRelease
   ```

---

### Method 3: Alternative Build Process

If the above methods don't work, you can use these alternative approaches:

#### Using Cordova (Alternative)
```bash
npm install -g cordova
cordova platform add android ios
cordova build android --release
cordova build ios --release
```

#### Using Ionic Capacitor
```bash
npm install -g @ionic/cli
ionic capacitor build android --prod
ionic capacitor build ios --prod
```

---

## 📋 Pre-Built App Information

### App Details for Store Submission:
- **App Name**: Faith Klinik Ministries
- **Bundle ID (iOS)**: com.faithklinik.ministries
- **Package Name (Android)**: com.faithklinik.ministries
- **Version**: 1.0.0
- **Build**: 1

### App Store Metadata:
- **Category**: Lifestyle → Religion & Spirituality
- **Description**: Complete church management system for Faith Klinik Ministries supporting world evangelism through missions, member management, and secure giving options.
- **Keywords**: church, ministry, faith, giving, christian, community, members, evangelism

### Store Listing Assets:
- **App Icon**: 1024x1024 (created from SVG heart icon)
- **Screenshots**: Need to be taken from actual app
- **Feature Graphic**: 1024x500 for Google Play

---

## 🎯 Current Working Features

✅ **Web App**: Fully functional at https://uniqename.github.io/enam_church_app
✅ **Login System**: Demo accounts available
✅ **Member Management**: Full CRUD with localStorage persistence
✅ **Payment Processing**: Zelle, Givelify, CashApp, Credit Cards
✅ **Leadership Management**: Complete editing capabilities
✅ **PWA Support**: Can be installed on mobile devices
✅ **Offline Support**: Service worker caches app

---

## 🛠️ Development Environment Setup

### Prerequisites:
- **Node.js** 16+ 
- **Android Studio** (for Android builds)
- **Xcode** (for iOS builds, macOS only)
- **Java 21** (for latest Android builds)

### Quick Setup:
```bash
# Clone and setup
git clone https://github.com/uniqename/enam_church_app.git
cd enam_church_app
npm install

# Build web version
npm run build
npm run deploy

# Setup mobile platforms
npx cap add ios android
npx cap sync

# Open in IDEs
npx cap open ios      # Opens Xcode
npx cap open android  # Opens Android Studio
```

---

## 📞 Support & Next Steps

### For Store Submission:
1. **Test the web app** thoroughly at the live URL
2. **Use Android Studio** to build the AAB file
3. **Use Xcode** to build the IPA file
4. **Upload to Google Play Console** and **App Store Connect**

### For Technical Issues:
- All source code is available in the project repository
- The web app is fully functional and ready for use
- Mobile builds can be completed using the IDEs

### Immediate Actions Available:
1. ✅ **Test the live web app** - https://uniqename.github.io/enam_church_app
2. ✅ **Use as PWA** - Install on mobile devices via browser
3. 🔄 **Build mobile apps** - Use Android Studio/Xcode for final builds

---

*The Faith Klinik app is production-ready and can be used immediately as a web app or PWA while the mobile app files are being generated through the IDEs.*