#!/bin/bash

# Faith Klinik Ministries - iOS Build Script
echo "🍎 Building Faith Klinik Ministries for iOS..."

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed. Please install Xcode from the App Store."
    exit 1
fi

# Build the web app
echo "📦 Building React app..."
npm run build

# Sync with Capacitor
echo "🔄 Syncing with Capacitor..."
npx cap sync ios

# Open Xcode for manual build (since we need certificates)
echo "🚀 Opening Xcode for iOS project..."
echo "
📋 MANUAL STEPS IN XCODE:
1. Select 'Faith Klinik Ministries' target
2. Go to Signing & Capabilities
3. Set your Team and Bundle Identifier
4. Select 'Any iOS Device' from the scheme selector
5. Go to Product → Archive
6. When archive completes, click 'Distribute App'
7. Choose 'App Store Connect'
8. Follow the prompts to upload

📁 IPA Location: 
- After archiving, go to Window → Organizer
- Select Archives tab
- Right-click on your archive → Show in Finder
- The .ipa file will be in a subfolder
"

npx cap open ios

# Alternative: Try to build from command line (requires certificates)
echo "
🔧 ALTERNATIVE: Command Line Build
If you have certificates configured, you can try:

# Clean build
xcodebuild clean -workspace ios/App/App.xcworkspace -scheme App

# Archive (replace TEAM_ID with your actual team ID)
xcodebuild archive \\
  -workspace ios/App/App.xcworkspace \\
  -scheme App \\
  -destination 'generic/platform=iOS' \\
  -archivePath ios/build/Faith-Klinik.xcarchive \\
  DEVELOPMENT_TEAM=YOUR_TEAM_ID

# Export IPA
xcodebuild -exportArchive \\
  -archivePath ios/build/Faith-Klinik.xcarchive \\
  -exportPath ios/build \\
  -exportOptionsPlist ios/ExportOptions.plist
"

echo "✅ iOS build process initiated!"