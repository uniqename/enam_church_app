# Faith Klinik Ministries App - Deployment Guide

## 📱 Mobile App Deployment (iOS & Android)

### Prerequisites
1. **Node.js** (v14 or higher)
2. **Xcode** (for iOS deployment)
3. **Android Studio** (for Android deployment)
4. **Apple Developer Account** (for App Store)
5. **Google Play Console Account** (for Google Play Store)

### Step 1: Install Capacitor CLI
```bash
npm install -g @capacitor/cli
npm install @capacitor/core @capacitor/ios @capacitor/android
```

### Step 2: Build the Web App
```bash
npm run build
```

### Step 3: Add Mobile Platforms
```bash
npm run capacitor:add
```

### Step 4: Sync Web Assets
```bash
npm run capacitor:sync
```

---

## 🍎 iOS Deployment (Apple App Store)

### Step 1: Open iOS Project
```bash
npm run ios
```

### Step 2: Configure in Xcode
1. **Bundle Identifier**: `com.faithklinik.ministries`
2. **App Name**: `Faith Klinik Ministries`
3. **Version**: `1.0.0`
4. **Build Number**: `1`

### Step 3: App Store Connect Setup
1. Create new app in [App Store Connect](https://appstoreconnect.apple.com)
2. Fill app information:
   - **Name**: Faith Klinik Ministries
   - **Category**: Lifestyle
   - **Description**: Complete church management system for Faith Klinik Ministries supporting world evangelism through missions
   - **Keywords**: church, ministry, faith, giving, members, christian
   - **Support URL**: https://faithklinikministries.com

### Step 4: App Store Review Guidelines
- ✅ Uses CoreData for local storage
- ✅ Implements proper payment processing
- ✅ Follows iOS Human Interface Guidelines
- ✅ Supports accessibility features
- ✅ No inappropriate content

### Step 5: Build and Upload
1. Select "Any iOS Device" in Xcode
2. Product → Archive
3. Upload to App Store Connect
4. Submit for Review

---

## 🤖 Android Deployment (Google Play Store)

### Step 1: Open Android Project
```bash
npm run android
```

### Step 2: Configure in Android Studio
1. **Application ID**: `com.faithklinik.ministries`
2. **Version Name**: `1.0.0`
3. **Version Code**: `1`
4. **Minimum SDK**: `21` (Android 5.0)
5. **Target SDK**: `33` (Android 13)

### Step 3: Generate Signed APK
1. Build → Generate Signed Bundle/APK
2. Create new keystore or use existing
3. Set keystore details:
   - **Alias**: faith-klinik-key
   - **Password**: (secure password)
   - **Validity**: 25 years

### Step 4: Google Play Console Setup
1. Create new app in [Google Play Console](https://play.google.com/console)
2. Fill app information:
   - **App Name**: Faith Klinik Ministries
   - **Category**: Lifestyle
   - **Description**: Complete church management system for Faith Klinik Ministries supporting world evangelism through missions
   - **Tags**: church, ministry, faith, giving, christian, community

### Step 5: Store Listing
- **Short Description**: Church management app for Faith Klinik Ministries
- **Full Description**: Complete church management system supporting world evangelism
- **App Icon**: 512x512 PNG (included in assets)
- **Feature Graphic**: 1024x500 PNG
- **Screenshots**: 
  - Phone: 16:9 ratio
  - Tablet: 16:10 ratio

### Step 6: Upload and Publish
1. Upload AAB file
2. Complete content rating questionnaire
3. Set up app pricing (Free)
4. Submit for review

---

## 🌐 PWA Deployment (Web App)

### Current Deployment
- **Live URL**: https://uniqename.github.io/enam_church_app
- **Hosting**: GitHub Pages
- **PWA Features**: ✅ Offline support, ✅ Add to homescreen

### Deploy Updates
```bash
npm run deploy
```

### PWA Installation
Users can install the app by:
1. Visit the website on mobile
2. Tap browser menu
3. Select "Add to Home Screen"
4. App will install like a native app

---

## 📋 Testing Checklist

### Functionality Testing
- [ ] Login/logout works
- [ ] Member editing saves data
- [ ] Leadership editing saves data
- [ ] Payment modals open correctly
- [ ] All navigation tabs work
- [ ] Data persists after app restart
- [ ] Offline functionality works

### Mobile Testing
- [ ] Touch interactions work smoothly
- [ ] Buttons are properly sized (44px minimum)
- [ ] Forms work on mobile keyboards
- [ ] App fits all screen sizes
- [ ] Safe area respected on notched devices
- [ ] No horizontal scrolling issues

### Performance Testing
- [ ] App loads in under 3 seconds
- [ ] Smooth scrolling and animations
- [ ] No memory leaks
- [ ] Proper image optimization
- [ ] Service worker caches correctly

---

## 🔧 Configuration Files

### Key Files for Deployment
- `capacitor.config.json` - Mobile app configuration
- `manifest.json` - PWA configuration
- `sw.js` - Service worker for offline support
- `DEPLOYMENT.md` - This deployment guide

### Environment Variables
Create `.env` file for production:
```
REACT_APP_ENV=production
REACT_APP_API_URL=https://api.faithklinikministries.com
REACT_APP_PAYMENT_STRIPE_KEY=pk_live_...
REACT_APP_ANALYTICS_ID=GA_TRACKING_ID
```

---

## 🚀 Production Deployment Steps

### 1. Final Build
```bash
npm run build
```

### 2. Test PWA
```bash
npm run serve
```

### 3. Deploy Web Version
```bash
npm run deploy
```

### 4. Build Mobile Apps
```bash
npm run build:mobile
```

### 5. iOS Deployment
```bash
npm run ios
# Follow iOS deployment steps above
```

### 6. Android Deployment
```bash
npm run android
# Follow Android deployment steps above
```

---

## 📞 Support & Maintenance

### Technical Support
- **Developer**: Claude Code Assistant
- **Repository**: https://github.com/uniqename/enam_church_app
- **Issues**: Create GitHub issues for bugs/features

### App Store Optimization (ASO)
- **Title**: Faith Klinik Ministries
- **Subtitle**: Church Management & Giving
- **Keywords**: church, ministry, giving, faith, christian, community, members
- **Category**: Lifestyle > Religion & Spirituality

### Analytics & Monitoring
- Implement Google Analytics
- Monitor app crashes
- Track user engagement
- Payment success rates
- Member growth metrics

---

## 🔒 Security & Privacy

### Data Protection
- All user data stored locally
- Payment processing through secure gateways
- No sensitive data transmitted
- GDPR compliant data handling

### App Store Privacy Labels
- **Data Collected**: Contact information, user content
- **Data Linked to User**: Account information, contact info
- **Data Not Collected**: Location, browsing history, sensitive info

---

*For technical assistance with deployment, please contact the development team or create an issue in the GitHub repository.*