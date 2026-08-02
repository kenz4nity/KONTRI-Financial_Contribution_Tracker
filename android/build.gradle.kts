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
                // 2. Force older packages to compile at SDK 35
                androidExt.compileSdkVersion(35)
            }
        }
    }
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

