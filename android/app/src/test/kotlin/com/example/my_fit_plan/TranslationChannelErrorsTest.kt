package com.example.my_fit_plan

import org.junit.Assert.assertEquals
import org.junit.Test

class TranslationChannelErrorsTest {
    @Test
    fun exposesStablePlatformErrorCodes() {
        assertEquals("MODEL_DOWNLOAD_FAILED", TranslationChannelErrors.MODEL_DOWNLOAD_FAILED)
        assertEquals("MODEL_NOT_READY", TranslationChannelErrors.MODEL_NOT_READY)
        assertEquals("TRANSLATOR_INIT_FAILED", TranslationChannelErrors.TRANSLATOR_INIT_FAILED)
        assertEquals("TRANSLATION_FAILED", TranslationChannelErrors.TRANSLATION_FAILED)
        assertEquals("NETWORK_UNAVAILABLE", TranslationChannelErrors.NETWORK_UNAVAILABLE)
        assertEquals("UNSUPPORTED_LANGUAGE", TranslationChannelErrors.UNSUPPORTED_LANGUAGE)
    }
}
