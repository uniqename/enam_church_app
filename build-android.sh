#!/bin/bash

# Faith Klinik Ministries - Android Build Script
echo "🤖 Building Faith Klinik Ministries for Android..."

# Check for Java
if ! command -v java &> /dev/null; then
    echo "❌ Java is not installed. Installing Java..."
    # On macOS with Homebrew
    if command -v brew &> /dev/null; then
        brew install openjdk@11
        echo "export PATH=\"/opt/homebrew/opt/openjdk@11/bin:\$PATH\"" >> ~/.zshrc
        export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"
    else
        echo "Please install Java manually: https://adoptopenjdk.net/"
        exit 1
    fi
fi

# Check for Android SDK
if [[ -z "$ANDROID_HOME" ]]; then
    echo "⚠️  ANDROID_HOME not set. Attempting to find Android SDK..."
    
    # Common Android Studio locations
    if [[ -d "$HOME/Library/Android/sdk" ]]; then
        export ANDROID_HOME="$HOME/Library/Android/sdk"
        echo "Found Android SDK at: $ANDROID_HOME"
    elif [[ -d "/Applications/Android Studio.app/Contents/plugins/android/lib/android.jar" ]]; then
        echo "Found Android Studio. Please set ANDROID_HOME manually:"
        echo "export ANDROID_HOME=$HOME/Library/Android/sdk"
        echo "Add this to your ~/.zshrc or ~/.bash_profile"
    else
        echo "❌ Android SDK not found. Please install Android Studio."
        exit 1
    fi
fi

# Build the web app
echo "📦 Building React app..."
npm run build

# Sync with Capacitor
echo "🔄 Syncing with Capacitor..."
npx cap sync android

# Create keystore if it doesn't exist
KEYSTORE_PATH="android/app/faith-klinik-release-key.keystore"
if [[ ! -f "$KEYSTORE_PATH" ]]; then
    echo "🔑 Creating release keystore..."
    keytool -genkey -v -keystore "$KEYSTORE_PATH" \
        -alias faith-klinik-key \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -storepass faithklinik2024 \
        -keypass faithklinik2024 \
        -dname "CN=Faith Klinik Ministries, OU=IT, O=Faith Klinik, L=Columbus, S=Ohio, C=US"
    
    echo "✅ Keystore created at: $KEYSTORE_PATH"
    echo "🔐 Store password: faithklinik2024"
    echo "🔐 Key password: faithklinik2024"
fi

# Create signing config
SIGNING_CONFIG="android/app/build.gradle.signing"
if [[ ! -f "$SIGNING_CONFIG" ]]; then
    echo "📝 Creating signing configuration..."
    cat > "$SIGNING_CONFIG" << EOF
android {
    signingConfigs {
        release {
            storeFile file('faith-klinik-release-key.keystore')
            storePassword 'faithklinik2024'
            keyAlias 'faith-klinik-key'
            keyPassword 'faithklinik2024'
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
EOF
fi

echo "🔨 Building Android AAB..."

# Navigate to Android project
cd android

# Clean and build
./gradlew clean
./gradlew bundleRelease

# Check if build was successful
AAB_PATH="app/build/outputs/bundle/release/app-release.aab"
if [[ -f "$AAB_PATH" ]]; then
    echo "✅ AAB file created successfully!"
    echo "📁 Location: $(pwd)/$AAB_PATH"
    
    # Copy to project root for easy access
    cp "$AAB_PATH" "../faith-klinik-ministries.aab"
    echo "📁 Copied to: faith-klinik-ministries.aab"
    
    # Show file info
    ls -lh "../faith-klinik-ministries.aab"
    
    echo "
🎉 Android build complete!
📦 AAB file: faith-klinik-ministries.aab
🚀 Ready for Google Play Console upload

📋 NEXT STEPS:
1. Go to Google Play Console
2. Create new app or select existing app
3. Go to Release → Production
4. Upload the AAB file: faith-klinik-ministries.aab
5. Fill out store listing information
6. Submit for review
"

else
    echo "❌ Build failed. Check the logs above for errors."
    echo "
🔧 TROUBLESHOOTING:
1. Make sure Android SDK is installed
2. Check ANDROID_HOME environment variable
3. Try opening in Android Studio: npx cap open android
4. Sync and build manually in Android Studio
"
    cd ..
    exit 1
fi

cd ..

# Also build APK for testing
echo "📱 Building debug APK for testing..."
cd android
./gradlew assembleDebug

DEBUG_APK="app/build/outputs/apk/debug/app-debug.apk"
if [[ -f "$DEBUG_APK" ]]; then
    cp "$DEBUG_APK" "../faith-klinik-ministries-debug.apk"
    echo "✅ Debug APK created: faith-klinik-ministries-debug.apk"
fi

cd ..

echo "✅ Android build process completed!"