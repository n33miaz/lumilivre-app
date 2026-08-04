import java.util.Properties
import java.io.FileInputStream

fun loadProperties(filePath: String): Properties {
    val properties = Properties()
    val propertiesFile = rootProject.file(filePath)
    if (propertiesFile.exists()) {
        properties.load(FileInputStream(propertiesFile))
    }
    return properties
}

val localProperties = loadProperties("local.properties")
val keystoreProperties = loadProperties("key.properties")

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "br.com.lumilivre.lumilivre"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = "br.com.lumilivre.lumilivre"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Vem do pubspec.yaml (version: x.y.z+n). Ler de local.properties fazia
        // build sem esse arquivo (clone novo, CI) publicar 1.0.0/versionCode 1,
        // e o gate de versao do app bloquearia todo mundo.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val hasReleaseKeystore = keystoreProperties.isNotEmpty()

    signingConfigs {
        create("release") {
            if (hasReleaseKeystore) {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Sem android/key.properties o config de release fica vazio e o AGP
            // aborta a validacao; cai para a chave de debug para o build passar.
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }

    flavorDimensions.add("environment")

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "LumiLivre Dev")
            manifestPlaceholders["appTitle"] = "LumiLivre Dev"
            manifestPlaceholders["usesCleartextTraffic"] = "true"
        }

        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "LumiLivre Staging")
            manifestPlaceholders["appTitle"] = "LumiLivre Staging"
            manifestPlaceholders["usesCleartextTraffic"] = "false"
        }

        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "LumiLivre")
            manifestPlaceholders["appTitle"] = "LumiLivre"
            manifestPlaceholders["usesCleartextTraffic"] = "false"
        }
    }
}

flutter {
    source = "../.."
}
