<p align="center">
  <img width="200" height="auto" src="images/logo.png">
  <br />
  <br />
  <span>Simple Library is a personal digital library app that helps you to keep track of your books with attractive features and provides you to build a continuous reading habit.</span>
</p>

<p align="center">
  <a href="https://play.google.com/store/apps/details?id=com.talhakerpicci.simplelibrary"><img alt="Get it on Google Play" src="images/google-play-badge.png" height="75px"/></a>
</p>

## Features
- High Customization Ability
- Highlights For Every Book
- Goals
- Reading Statistics and Graphs
- Collections
- Reading Reminders
- Filter and Detailed Search

## Demo Video
[![simplelibrary](https://img.youtube.com/vi/4Go0qeIhCTE/0.jpg)](https://www.youtube.com/watch?v=4Go0qeIhCTE)

## Downloading
Visit releases page to get the latest version or view the release notes.

## Building From Source

**DISCLAIMER**: Simple Library is one of the first app i built with flutter. I know code is very messy. It's hard to work with. Yes, it could be alot better but at this point i dont have time or the energy to make it any better. PR's are welcomed.

**WARNING**: **TESTED WITH FLUTTER VERSION 2.0.5 ON LINUX**. I tried to build with newer versions but it always failed, the app doesnt support null-safety, and there are too many dependencies that cause problems, and i dont have the time to fix all dependency conflicts. Again, PR's are welcomed.

## Building Steps

### Clone the repository

```
git clone https://github.com/N1ght-Fury/simple_library
```

### Create a new firebase project
- Navigate to https://console.firebase.google.com/
- Click on `Add Project`
- Enter your project name
- Make sure to enable Google Analytics (it could work without it but i didnt test it)
- Click on `Create Project`

### Adding android app
- Once your project is created, it's time to create an Android App. Click on `Add App` and select Android
- Enter package name (eg: com.example.package_name) and click on `Register App`
- Download `google-services.json` file and put the file inside `android/app` folder
- Click on next and continue to console

### Setting up Firebase Authentication
- Navigate to Authentication page
- Select `email/password` as sign-in method and enable `email/password`
- Click on save

### Setting up Cloud Firestore
- Navigate to `Firestore Database` page
- Click on `Get Started` and and select test mode (or production if you like. Warning: At some point you will need to edit your firestore rules. Make sure to edit it)
- Select your Cloud Firestore location and click on `enable`

### Installing NDK Version 22.0.7026061
- Open Android Studio
- Navigate to Android Sdk -> SDK Tools
- Click on `Show Package Details` at the bottom right
- Expand NDK tab and make sure you have version 22.0.7026061 installed. If not install it

### Running the project
- Open the project with your favorite IDE
- Search for `com.example.simple_library` in the whole project, and replace all the strings with your own package name (eg: com.example.package_name)
- Open an emulator or plug in your phone
- Execute `flutter run --release`
- Done!
- **Warning:** You wont be able to upgrade your account to premium since that requires to have the app published. Open your Firebase project, navigate to Firestore Database, find your user id and change the property `isPremium` to `true`. (`users->userId->userData->data->isPremium`)

