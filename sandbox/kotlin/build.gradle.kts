import org.gradle.api.tasks.testing.logging.TestExceptionFormat
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    kotlin("jvm") version "2.2.20"
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(kotlin("test"))
}

// Pinned rather than left to a toolchain: the JDK on this machine may be newer than
// the Kotlin compiler's highest supported target, and no toolchain is downloaded.
// Any JDK 17 or newer can build and run this project.
java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_17
    }
}

tasks.test {
    useJUnitPlatform()
    // JUnit 5's @EnabledIfEnvironmentVariable reads the *test process* environment,
    // so the gate has to be forwarded from Gradle's environment into the fork.
    // The gate is read from -PrunKnownIssues=1 or the LEDGER_RUN_KNOWN_ISSUES environment variable;
    // declaring it as a task input makes Gradle re-run the tests when only the gate changes.
    val knownIssues = (project.findProperty("runKnownIssues")?.toString() ?: System.getenv("LEDGER_RUN_KNOWN_ISSUES") ?: "")
    inputs.property("knownIssues", knownIssues)
    environment("LEDGER_RUN_KNOWN_ISSUES", knownIssues)
    // Without this the task would report UP-TO-DATE when only the variable changed.
    inputs.property("ledgerRunKnownIssues", System.getenv("LEDGER_RUN_KNOWN_ISSUES") ?: "")
    testLogging {
        // Print the failure message on the console, so a red run is readable
        // without opening the HTML report.
        events("failed")
        exceptionFormat = TestExceptionFormat.FULL
    }
}
