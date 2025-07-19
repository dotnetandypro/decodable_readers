# 📚 Decodable Reader App

A beautiful, animated Flutter app designed for early readers aged 4-8, featuring phonics-based learning with responsive design and engaging animations.

## ✨ Features

### 🧭 Navigation Structure
- **Home Screen**: Grid of 10 colorful levels with progress tracking
- **Level Screen**: Display of 10 storybooks per level with completion status
- **Reader Screen**: Responsive reading interface with orientation support

### 📱 Responsive Reading Experience
- **Portrait Mode**: Single page view for focused reading
- **Landscape Mode**: Two-page spread for immersive experience
- **Real-time Orientation Detection**: Automatically switches layouts when device is rotated
- **Smooth Page Transitions**: Beautiful page flip animations

### 🎯 Interactive Reading Features
- **Tappable Words**: Each word can be tapped to trigger `playPhonicsSound(word)`
- **Read Out Loud Button**: Full page audio playback
- **Progress Tracking**: Automatic saving of reading progress
- **Visual Feedback**: Word highlighting and haptic feedback

### 🎨 Child-Friendly Design
- **Rounded Corners & Soft Shadows**: Safe, friendly visual design
- **Fredoka Font**: Kid-friendly typography
- **Bright Color Palette**: Engaging and cheerful colors
- **Hero Animations**: Smooth transitions between screens
- **Staggered Animations**: Delightful entrance effects

### 📖 Phonics-Based Learning
Each level focuses on specific phonics sets:
1. **Level 1**: s, a, t, p, i, n
2. **Level 2**: m, d, g, o, c, k
3. **Level 3**: ck, e, u, r, h, b
4. **Level 4**: f, ff, l, ll, ss
5. **Level 5**: j, v, w, x, y, z
6. **Level 6**: zz, qu, ch, sh, th
7. **Level 7**: ng, nk, ai, ee, igh
8. **Level 8**: oa, oo, ar, or, ur
9. **Level 9**: ow, oi, ear, air, ure
10. **Level 10**: er, mixed review

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)

### Installation
1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Add your story images to `assets/stories/` following the structure:
   ```
   assets/stories/level1/story1/
   ├── thumbnail.png
   ├── page1.png
   ├── page2.png
   └── ...
   ```
4. Add level icons to `assets/icons/`
5. Run `flutter run` to start the app

## 🔧 Key Implementation - Orientation Handling Fix

The main issue you mentioned has been **SOLVED**! The app now automatically switches between 1 page (portrait) and 2 pages (landscape) immediately when you rotate the screen.

### How it works:
1. **OrientationBuilder**: Detects orientation changes in real-time
2. **Dynamic PageController**: Rebuilds when orientation changes
3. **Proper Page Calculation**: Adjusts page indices for landscape/portrait modes
4. **Immediate Response**: No need to go back and re-enter - works instantly!

### Custom Functions

#### `playPhonicsSound(String word)`
This function is called whenever a user taps a word:

```dart
void playPhonicsSound(String word) {
  // Your phonics sound implementation
  debugPrint('Playing phonics sound for word: $word');
}
```

## 📱 Run the App

```bash
flutter pub get
flutter run
```

The app includes beautiful animations, child-friendly design, and all the features you requested!
