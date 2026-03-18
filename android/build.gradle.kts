allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val javaCompilerArgs = listOf("-Xlint:-options", "-Xlint:-deprecation")

tasks.withType<JavaCompile>().configureEach {
    options.compilerArgs.addAll(javaCompilerArgs)
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    tasks.withType<JavaCompile>().configureEach {
        options.compilerArgs.addAll(javaCompilerArgs)
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
