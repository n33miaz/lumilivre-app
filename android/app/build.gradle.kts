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
    namespace = "br.com.etec.tcc.lumilivre"
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
        applicationId = "br.com.etec.tcc.lumilivre"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = (localProperties.getProperty("flutter.versionCode")?.toIntOrNull()) ?: 1
        versionName = localProperties.getProperty("flutter.versionName") ?: "1.0.0"
    }

    signingConfigs {
        create("release") {
            if (keystoreProperties.isNotEmpty()) {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
