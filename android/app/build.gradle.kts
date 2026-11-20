import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing comes from android/key.properties (storeFile, storePassword,
// keyAlias, keyPassword) or from the ANDROID_KEYSTORE_PATH, ANDROID_KEYSTORE_PASSWORD,
// ANDROID_KEY_ALIAS and ANDROID_KEY_PASSWORD environment variables. There is no
// fallback to the debug key: a release build without them fails.
val keyProps = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}

fun signingValue(prop: String, env: String): String? =
    (keyProps.getProperty(prop) ?: System.getenv(env))?.takeIf { it.isNotBlank() }

val releaseStoreFile = signingValue("storeFile", "ANDROID_KEYSTORE_PATH")
val releaseStorePassword = signingValue("storePassword", "ANDROID_KEYSTORE_PASSWORD")
val releaseKeyAlias = signingValue("keyAlias", "ANDROID_KEY_ALIAS")
val releaseKeyPassword = signingValue("keyPassword", "ANDROID_KEY_PASSWORD")
val hasReleaseSigning = listOf(
    releaseStoreFile, releaseStorePassword, releaseKeyAlias, releaseKeyPassword
).all { it != null }

android {
    namespace = "dev.kushiemoon.flacidal_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.14206865"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "dev.kushiemoon.flacidal_mobile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(releaseStoreFile!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

gradle.taskGraph.whenReady {
    val releaseRequested = allTasks.any { it.name == "assembleRelease" || it.name == "bundleRelease" }
    if (releaseRequested && !hasReleaseSigning) {
        throw GradleException(
            "Release signing is not configured: provide android/key.properties or the ANDROID_KEYSTORE_* variables"
        )
    }
}

// libflacidal.so is not tracked by git. Build it with tool/build_core.sh.
// Use -Pflacidal.abis=arm64-v8a to require only the ABIs you actually target.
val coreAbis = (findProperty("flacidal.abis") as String?)?.split(",")?.map { it.trim() }
    ?: listOf("arm64-v8a", "armeabi-v7a", "x86_64")

val verifyCoreLibs = tasks.register("verifyCoreLibs") {
    doLast {
        coreAbis.forEach { abi ->
            if (!file("src/main/jniLibs/$abi/libflacidal.so").exists()) {
                throw GradleException(
                    "libflacidal.so missing for $abi. Run tool/build_core.sh <core checkout> (see README)"
                )
            }
        }
    }
}

tasks.matching { it.name == "preBuild" }.configureEach { dependsOn(verifyCoreLibs) }

flutter {
    source = "../.."
}
