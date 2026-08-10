package com.example.my_fit_plan

import java.io.File
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class TranslationChannelStartupSafetyTest {
    @Test
    fun duplicateRegisterAndDisposeCallsAreIdempotent() {
        val guard = ChannelLifecycleGuard()
        var registrations = 0
        var disposals = 0

        guard.register { registrations++ }
        guard.register { registrations++ }
        guard.dispose { disposals++ }
        guard.dispose { disposals++ }

        assertEquals(1, registrations)
        assertEquals(1, disposals)
        assertFalse(guard.isRegistered)
        assertTrue(guard.isDisposed)
    }

    @Test
    fun disposeBeforeRegistrationIsHarmless() {
        val guard = ChannelLifecycleGuard()
        var disposals = 0

        guard.dispose { disposals++ }
        guard.dispose { disposals++ }

        assertEquals(1, disposals)
        assertTrue(guard.isDisposed)
    }

    @Test
    fun startupSourcesUseSafeFlutterAndMlKitInitialization() {
        val activity = source("app/src/main/kotlin/com/example/my_fit_plan/MainActivity.kt")
        val translation = source(
            "app/src/main/kotlin/com/example/my_fit_plan/OnDeviceTranslationChannel.kt",
        )

        assertTrue(activity.contains("override fun configureFlutterEngine"))
        assertTrue(activity.contains("super.configureFlutterEngine(flutterEngine)"))
        assertTrue(activity.contains("flutterEngine.dartExecutor.binaryMessenger"))
        assertFalse(activity.contains("override fun onCreate"))
        assertFalse(activity.contains("flutterEngine!!"))
        assertFalse(activity.contains("GeneratedPluginRegistrant"))
        assertFalse(activity.contains("MlKitContext"))
        assertFalse(activity.contains("ensureModelsDownloaded"))

        assertTrue(translation.contains("private var translator: Translator? = null"))
        assertTrue(translation.contains("messenger: BinaryMessenger"))
        assertTrue(translation.contains("translator?.close()"))
        assertTrue(
            translation.contains("private var modelManager: RemoteModelManager? = null"),
        )
        assertFalse(
            translation.contains(
                "private val modelManager = RemoteModelManager.getInstance()",
            ),
        )
        assertFalse(translation.contains("!!"))

        assertTrue(translation.contains("TranslateLanguage.PERSIAN"))
        assertTrue(translation.contains("TranslateLanguage.ENGLISH"))
        assertFalse(translation.contains("fromLanguageTag"))
        assertTrue(translation.contains("DownloadConditions.Builder().build()"))
        assertFalse(translation.contains(".requireWifi" + "()"))
        assertTrue(translation.contains("downloadModelIfNeeded(conditions)"))
        assertFalse(translation.contains("getDownloadedModels"))
        assertTrue(translation.contains("MlKitContext.initializeIfNeeded(applicationContext)"))
    }

    private fun source(relativePath: String): String {
        var directory = File(
            requireNotNull(System.getProperty("user.dir")),
        ).absoluteFile
        repeat(5) {
            val candidate = File(directory, relativePath)
            if (candidate.isFile) return candidate.readText(Charsets.UTF_8)
            directory = directory.parentFile
                ?: error("Unable to locate Android project root.")
        }
        error("Unable to locate Android source: $relativePath")
    }
}
