allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val androidExt = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            if (androidExt != null) {
                // 1. Fix for the missing namespace error
                if (androidExt.namespace == null) {
                    androidExt.namespace = project.group.toString()
                }
                // 2. Force every module (including :app) to one compileSdk.
                // Raised to 36 in v1.1: the AndroidX libraries pulled in by
                // image_picker and printing refuse to compile below it. This
                // runs in afterEvaluate, so it overrides app/build.gradle.kts
                // -- keep the two values in step.
                androidExt.compileSdkVersion(36)
            }
        }
    }
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

