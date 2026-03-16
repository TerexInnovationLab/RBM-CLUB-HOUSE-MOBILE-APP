fun org.gradle.api.Project.configureNamespaceFallback() {
    afterEvaluate {
        val androidExtension = extensions.findByName("android") ?: return@afterEvaluate

        val getNamespace = androidExtension.javaClass.methods.firstOrNull {
            it.name == "getNamespace" && it.parameterCount == 0
        } ?: return@afterEvaluate

        val currentNamespace = getNamespace.invoke(androidExtension) as? String
        if (!currentNamespace.isNullOrBlank()) {
            return@afterEvaluate
        }

        val setNamespace = androidExtension.javaClass.methods.firstOrNull {
            it.name == "setNamespace" && it.parameterCount == 1
        } ?: return@afterEvaluate

        val manifestFile = file("src/main/AndroidManifest.xml")
        if (!manifestFile.exists()) {
            return@afterEvaluate
        }

        val packageName = Regex("""package\s*=\s*"([^"]+)"""")
            .find(manifestFile.readText())
            ?.groupValues
            ?.getOrNull(1)

        if (!packageName.isNullOrBlank()) {
            setNamespace.invoke(androidExtension, packageName)
        }
    }
}

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
    project.configureNamespaceFallback()
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
