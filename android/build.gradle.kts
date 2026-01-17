allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Workaround: Ensure all Android library subprojects declare a namespace (AGP 8+ requirement)
// Uses reflection to avoid compile-time dependency on AGP types in the root script.
subprojects {
    plugins.withId("com.android.library") {
        val androidExt = extensions.findByName("android")
        if (androidExt != null) {
            val getNs = androidExt.javaClass.methods.firstOrNull { it.name == "getNamespace" && it.parameterCount == 0 }
            val setNs = androidExt.javaClass.methods.firstOrNull { it.name == "setNamespace" && it.parameterCount == 1 && it.parameterTypes[0] == String::class.java }
            val currentNs = try { getNs?.invoke(androidExt) as? String } catch (_: Throwable) { null }
            if (currentNs == null || currentNs.isBlank()) {
                try {
                    setNs?.invoke(androidExt, "patched." + project.name.replace('-', '_'))
                } catch (_: Throwable) {
                    // ignore if namespace cannot be set
                }
            }
        }
    }
}
