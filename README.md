📖 Halaqat - Islamic Learning & Parent Portal
Halaqat is a comprehensive Flutter application designed to streamline student progress tracking, Quran memorization (Sabaq, Sabqi, Manzil), and communication between teachers and parents. The platform features dedicated interfaces for monitoring daily reports, tracking report cards, and managing student profiles seamlessly.

✨ Features
Parent Portal & Dashboard: Real-time visibility into your child's daily Quran progress, attendance, and grades.

Progress Tracking: Structured monitoring for daily lessons including Sabaq, Sabqi, and Manzil evaluations.

Report Cards & Analytics: Easy-to-read progress summaries and performance history for each student.

Multilingual Support: Built-in localization support for seamless switching between English and local languages.

🛠️ Tech Stack & Backend
Frontend: Flutter (Dart)

State Management: Provider Architecture

Backend Services:

Firebase Authentication (User identity & login access)

Cloud Firestore / Firebase Database (Real-time data storage)

🔒 Firebase Configuration Setup
Note: Firebase configuration files are intentionally excluded from this repository to protect backend credentials. You must configure your own Firebase project before running the application.

Setup Instructions
Create a Firebase Project:
Go to the Firebase Console and create a new project.

Enable Required Services:

Enable Firebase Authentication (Email/Password or your preferred auth provider).

Enable Cloud Firestore Database and update your Security Rules.

Configure Your Platform Credentials:

Automatic (Recommended): Run the FlutterFire CLI in your terminal:

Bash
flutterfire configure
This will automatically generate lib/firebase_options.dart for your own project.

Manual Setup:

Android: Download google-services.json from your Firebase Android App settings and place it in android/app/. (You can refer to android/app/google-services.json.example).

iOS: Download GoogleService-Info.plist from your Firebase iOS App settings and place it in ios/Runner/. (You can refer to ios/Runner/GoogleService-Info.plist.example).

Dart Config: Rename lib/firebase_options.dart.example to lib/firebase_options.dart and insert your API keys and project credentials.

Run the Application:

Bash
flutter pub get
flutter run