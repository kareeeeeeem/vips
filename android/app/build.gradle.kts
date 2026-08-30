import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.vips.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "app"
    productFlavors {
        create("consumer") {
            dimension = "app"
            applicationId = "com.vips.app"
        }
        create("merchant") {
            dimension = "app"
            applicationId = "com.vips.merchant"
        }
        // Admin console. Unlike the other two it never calls Firebase, so it
        // needs no google-services.json of its own — see lib/main_admin.dart.
        create("admin") {
            dimension = "app"
            applicationId = "com.vips.admin"
        }
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

// The admin console (lib/main_admin.dart) signs in with email + password
// against /api/admin/login and never touches Firebase, so it has no Firebase
// app registered and no google-services.json. The Google Services plugin is
// applied for the whole module, so its per-variant task would fail the admin
// build looking for that file. Disabling the task for admin variants only
// leaves consumer and merchant — the two flavors that really do use Firebase
// Auth — completely untouched.
tasks.matching {
    it.name.startsWith("process") && it.name.contains("Admin") &&
        it.name.endsWith("GoogleServices")
}.configureEach {
    enabled = false
}
