plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.testNotifDonate.notif_donate"
    compileSdk = 35  // Updated
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // ADD THIS LINE - Enable core library desugaring
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.testNotifDonate.notif_donate"
        minSdk = 21  // CHANGE from flutter.minSdkVersion to 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true  // ADD THIS LINE
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

dependencies {
    // ADD THIS - Core library desugaring dependency
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}