plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // LEARNING: google-services plugin reads google-services.json
    // and generates the Firebase configuration for the app
    id("com.google.gms.google-services")
}

android {
    namespace = "com.faraz.taskmanager"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.faraz.taskmanager"
        minSdk = flutter.minSdkVersion
        // LEARNING: minSdk 23 is required for Firebase Auth
        // default flutter.minSdkVersion is 21 which is too low
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
