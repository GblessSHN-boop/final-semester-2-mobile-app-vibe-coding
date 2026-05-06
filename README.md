# Project Final Semester 2 Mobile App (Vibe Coding)

## Kalkulator IPK & IPS

Kalkulator IPK & IPS is a final semester 2 mobile application demo built with Flutter and Firebase. This application helps students manage academic records, create semester data, input courses, calculate semester GPA (IPS), and calculate cumulative GPA (IPK) automatically.

This project was created as part of a mobile application development learning process and personal portfolio documentation. The development process used a vibe coding workflow supported by AI tools, including Antigravity and ChatGPT.

## Project Overview

This application is designed to support students in monitoring academic performance in a simple, structured, and user-friendly way.

Users can register an account, log in, add semesters, add courses, input credit units, select grades, and view automatic academic calculations. The system stores data in Firebase so each user has personal academic data connected to their own account.

## Main Features

- User registration and login with Firebase Authentication
- Persistent login session
- Cloud-based academic data storage using Cloud Firestore
- Add and manage semester data
- Add and manage course data
- Automatic IPS calculation per semester
- Automatic cumulative IPK calculation
- Academic dashboard summary
- Academic statistics page
- User profile page
- Database-based profile photo feature
- Custom app icon
- Splash screen interface
- Clean and user-friendly mobile UI

## Technology Stack

This project was developed using:

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Provider State Management
- Image Picker
- Google Fonts
- FL Chart
- Flutter Launcher Icons

## AI-Assisted Development Workflow

This project was developed using a vibe coding approach. The workflow combined manual logic understanding, direct experimentation, design-first exploration, and AI-assisted development.

AI tools used during the development process include:

- Antigravity as an AI-assisted coding environment
- ChatGPT for learning support, debugging, Firebase setup guidance, UI improvement ideas, documentation drafting, and project structuring

The AI tools were used as learning and productivity assistants. The feature direction, testing process, visual preferences, and final implementation decisions were controlled by the developer.

## Application Purpose

The purpose of this application is to help students calculate and monitor their academic performance more easily. Instead of calculating IPS and IPK manually using a calculator or spreadsheet, users can store their academic data in the application and let the system calculate the results automatically.

This application is useful for:

- Students who want to track semester performance
- Students who want to monitor cumulative GPA progress
- Students who want to organize course and credit data
- Academic learning demonstrations
- Mobile app development portfolio documentation

## Basic Usage Flow

1. Open the application.
2. Register a new account or log in with an existing account.
3. If the user has logged in before and has not logged out, the application will open the home page automatically.
4. Go to the Semester page.
5. Add a new semester.
6. Open the selected semester.
7. Add courses with credit units and grades.
8. View the calculated IPS for each semester.
9. View cumulative IPK and academic summary on the dashboard.
10. Check academic statistics and profile information.
11. Change the profile photo from the profile page.

## Project Structure

```text
kalkulator_ipk_ips
├── android
├── asset
│   ├── branding
│   └── icons
├── ios
├── lib
│   ├── core
│   ├── models
│   ├── providers
│   ├── screens
│   ├── services
│   └── widgets
├── web
├── pubspec.yaml
└── README.md
```

## Firebase Services Used

This project uses the following Firebase services:

- Firebase Authentication for user registration and login
- Cloud Firestore for storing user, semester, course, and profile data

## Persistent Login Session

The application now supports a persistent login session. This means users do not need to log in again every time they reopen the application, as long as they have not logged out.

For the web platform, Firebase Authentication is configured with local persistence. This allows the login session to remain stored in the browser. When the application starts, the splash screen checks the current authentication state. If an active user session is found, the application redirects the user to the home page. If no active session is found, the user is redirected to the login page.

This feature improves user experience because users can continue using the application without repeating the login process every time.

## Database-Based Profile Photo Feature

The profile photo feature is designed to work without Firebase Storage. Since this project uses the Firebase Spark Plan, the profile photo is stored directly in Cloud Firestore as Base64 data.

The system works as follows:

1. The user selects a profile photo from the device.
2. The image is compressed before being saved.
3. The image is converted into Base64 text.
4. The Base64 data is stored in the user document inside the `users` collection.
5. When the user changes the profile photo, the old photo data is deleted and replaced with the new one.

This approach prevents old profile photos from accumulating in the database.

## Current Development Status

The current version supports the core academic data management features, including user authentication, persistent login session, semester management, course management, IPS calculation, IPK calculation, dashboard summary, profile page, basic statistics, and the foundation for a database-based profile photo feature.

Planned future improvements include:

- Manual profile photo crop before saving
- Improved splash screen animation
- More polished UI and micro-interactions
- PDF export for semester reports
- PDF export for IPK and IPS summary
- More detailed academic statistics
- Better profile management
- Enhanced form validation and user feedback
- Dark mode and light mode
- GPA target simulator
- Mini academic transcript page

## Recent Update

### Update 1

#### ID

Pada pembaruan ini, project mulai menambahkan dasar fitur foto profil berbasis database. Fitur ini dirancang agar pengguna dapat mengganti foto profil tanpa menggunakan Firebase Storage. Karena project masih menggunakan Firebase Spark Plan, penyimpanan foto dilakukan melalui Cloud Firestore dalam bentuk Base64.

Ketika pengguna memilih foto baru, sistem akan mengompres gambar, mengubahnya menjadi Base64, lalu menyimpannya pada dokumen pengguna di koleksi `users`. Apabila pengguna mengganti foto profil, data foto lama di database akan dihapus terlebih dahulu dan diganti dengan data foto yang baru. Dengan pendekatan ini, foto lama tidak menumpuk di database.

#### EN

In this update, the project started adding the foundation for a database-based profile photo feature. This feature is designed to allow users to change their profile photo without using Firebase Storage. Since the project is still using the Firebase Spark Plan, the profile photo is stored in Cloud Firestore as Base64 data.

When the user selects a new photo, the system compresses the image, converts it into Base64, and stores it in the user document inside the `users` collection. If the user changes the profile photo, the old photo data in the database is deleted first and replaced with the new photo data. With this approach, old profile photos do not accumulate in the database.

### Update 2

#### ID

Pada pembaruan ini, project menambahkan fitur persistent login session. Fitur ini membuat pengguna tidak perlu login ulang setiap kali aplikasi dibuka selama pengguna belum melakukan logout.

Pada platform web, Firebase Authentication disetel menggunakan local persistence agar sesi login tetap tersimpan di browser. Saat aplikasi dijalankan, splash screen akan memeriksa status login pengguna. Jika sesi login masih aktif, pengguna langsung diarahkan ke halaman utama. Jika tidak ada sesi login aktif, pengguna akan diarahkan ke halaman login.

#### EN

In this update, the project added a persistent login session feature. This feature allows users to stay logged in when reopening the application, as long as they have not logged out.

On the web platform, Firebase Authentication is configured using local persistence so the login session remains stored in the browser. When the application starts, the splash screen checks the user's authentication state. If an active login session exists, the user is redirected directly to the home page. If no active session exists, the user is redirected to the login page.

## Installation and Setup

Clone this repository:

```bash
git clone https://github.com/GblessSHN-boop/final-semester-2-mobile-app-vibe-coding.git
```

Go to the project directory:

```bash
cd final-semester-2-mobile-app-vibe-coding
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

Run on Chrome:

```bash
flutter run -d chrome
```

Run Flutter analysis:

```bash
flutter analyze
```

## Important Notes

This project uses Firebase. To run the application properly, Firebase configuration must be available and connected to a Firebase project.

Make sure Firebase Authentication and Cloud Firestore are enabled in Firebase Console before running the application.

This project does not use Firebase Storage for profile photos. Profile photos are stored in Cloud Firestore as compressed Base64 data for academic and demonstration purposes.

The persistent login session will remain active as long as the user does not log out, the browser data is not cleared, and the authentication session is still valid.

## Developer

Developed by:

```text
Gland Jermano Blessed Siahaan
```

Project branding:

```text
ARCDEV - GLAND S
```

## Copyright and Usage Notice

© 2026 Gland Jermano Blessed Siahaan. All rights reserved.

This project is a personal and academic mobile application project created for learning, academic purposes, learning documentation, and personal portfolio development. The source code, visual design, layout, animation, text, assets, folder structure, application concept, and development workflow are owned by Gland Jermano Blessed Siahaan unless otherwise stated.

You are not allowed to copy, reproduce, modify, redistribute, sell, publish, reuse, or claim any part of this project as your own without written permission from the owner.

Viewing, opening, cloning, forking, or accessing this repository does not grant any license, usage right, or permission to use any part of this project.

Any use, citation, redevelopment, modification, adaptation, publication, or distribution of this project must receive written permission from the owner first.

Violation of this notice may be considered copyright infringement and misuse of digital work.

For permission requests, please contact:

```text
glandjermanoblessedsiahaan@gmail.com
```

## License

No open-source license is granted for this repository.

All rights are reserved by the owner. This project may not be used, copied, modified, distributed, published, or claimed without written permission.