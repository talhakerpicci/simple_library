<p align="center">
  <img width="200" height="auto" src="images/logo.png">
  <br />
  <span align="center">Simple Library is a personal digital library app that helps you to keep track of your books with attractive features and provides you to build a continuous reading habit.</span>
</p>
<br />
<p align="center">
  <a href="https://play.google.com/store/apps/details?id=com.talhakerpicci.simplelibrary"><img alt="Get it on Google Play" src="images/google-play-badge.png" height="75px"/></a>
</p>

## Demo Video
[![simplelibrary](https://img.youtube.com/vi/4Go0qeIhCTE/0.jpg)](https://www.youtube.com/watch?v=4Go0qeIhCTE)

## Downloading
Visit releases page to get the latest version or view the release notes.

## Building From Source

**DISCLAIMER**: Simple Library is one of the first app i built with flutter. I know code is very messy. Its hard to work with. Yes, it could be alot better but at this point i dont have time or the energy to make it any better. PR's are welcomed.

**WARNING**: **TESTED WITH FLUTTER VERSION 2.0.5 ON LINUX**. I tried to build with never versions but it always failed, the app doesnt support null-safety, and there are too many dependencies that cause problems, and i dont have the time to fix all dependency conflicts. Again, PR's are welcomed.

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
- Once your project is created, its time to create an Android App. Click on `Add App` and select Android
- Enter package name (com.example.....) and click on `Register App`
- Download `google-services.json` file and put the file inside `android/app` folder
- CLick on next and continue to console

### Setting up Firebase Authentication
- Click on Authentication tab
- Select `email/password` as sign-in method and enable `email/password`
- Click on save

### Setting up Cloud Firestore
- Click on `Firestore Database` tab
- Click on `Get Started` and and select test mode (or production if you like. make sure to edit firebase rules if you select production)
- Select your Cloud Firestore location and click on `enable`

### Installing NDK Version 22.0.7026061
- Open Android Studio
- Navigate to Android Sdk -> SDK Tools
- CLick on `Show Package Details` at the bottom right
- Expand NDK tab and make sure you have version 22.0.7026061 installed. If not install it

### Running the project
- Open the project with your favorite IDE
- Search for `com.example.simple_library` in the whole project, and replace all the strings with your own package name
- Open an emulator or plug in your phone
- Execute `flutter run --release`
- Done!
- **Warning:** You wont be able to upgrade your account to premium since that requires to have the app published. Open Firebase console, navigate to Firestore Database, find your user id and change the property `isPremium` to `true`. (`users->userId->userData->data->isPremium`)

