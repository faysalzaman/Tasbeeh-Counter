plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

android {
    namespace = "com.sairatec.tesbeeh_counter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.sairatec.tesbeeh_counter"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // TODO: Configure your release signing for Play Store.
            // Create a keystore with:
            //   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
            //     -keysize 2048 -validity 10000 -alias upload
            // Then create android/key.properties with:
            //   storePassword=<password>
            //   keyPassword=<password>
            //   keyAlias=upload
            //   storeFile=/Users/<username>/upload-keystore.jks
            // And uncomment the lines below:
            // val keystorePropertiesFile = rootProject.file("key.properties")
            // val keystoreProperties = Properties()
            // keystoreProperties.load(FileInputStream(keystorePropertiesFile))
            // keyAlias = keystoreProperties["keyAlias"] as String
            // keyPassword = keystoreProperties["keyPassword"] as String
            // storeFile = file(keystoreProperties["storeFile"] as String)
            // storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            // TODO: Replace with signingConfigs.getByName("release") before Play Store upload.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
