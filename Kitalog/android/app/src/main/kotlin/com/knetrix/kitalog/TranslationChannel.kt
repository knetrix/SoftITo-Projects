package com.knetrix.kitalog

import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.common.model.DownloadConditions
import com.google.mlkit.common.model.RemoteModelManager
import com.google.mlkit.nl.languageid.LanguageIdentification
import com.google.mlkit.nl.languageid.LanguageIdentificationOptions
import com.google.mlkit.nl.languageid.LanguageIdentifier
import com.google.mlkit.nl.translate.TranslateLanguage
import com.google.mlkit.nl.translate.TranslateRemoteModel
import com.google.mlkit.nl.translate.Translation
import com.google.mlkit.nl.translate.Translator
import com.google.mlkit.nl.translate.TranslatorOptions
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Okuyucudaki çevirinin Android tarafı (`kitalog/translation`): Google ML Kit ile
 * cihaz üstü çeviri ve dil tanıma. Dil paketi bir kez indirildikten sonra çeviri
 * internetsiz çalışır. İndirme onayını uygulama kendi penceresinde sorar.
 */
class TranslationChannel(messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, "kitalog/translation")
    private val models = RemoteModelManager.getInstance()
    private val translators = mutableMapOf<String, Translator>()
    private var identifier: LanguageIdentifier? = null

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "info" -> result.success(mapOf("supported" to true, "systemConfirmsDownload" to false))
            "identifyLanguage" -> identifyLanguage(call.argument<String>("text").orEmpty(), result)
            "areModelsDownloaded" -> areModelsDownloaded(call, result)
            "downloadModels" -> downloadModels(call, result)
            "translate" -> translate(call, result)
            "close" -> {
                close()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    /** Dil kodu; belirlenemezse (güven %50'nin altında) boş metin. */
    private fun identifyLanguage(text: String, result: MethodChannel.Result) {
        val client = identifier ?: LanguageIdentification.getClient(
            LanguageIdentificationOptions.Builder().setConfidenceThreshold(LANGUAGE_CONFIDENCE).build(),
        ).also { identifier = it }
        client.identifyLanguage(text)
            .addOnSuccessListener { code -> result.success(if (code == UNDETERMINED) "" else code) }
            .addOnFailureListener { result.success("") }
    }

    private fun areModelsDownloaded(call: MethodCall, result: MethodChannel.Result) {
        val pair = remoteModels(call) ?: return result.error(MODEL_DOWNLOAD, "unsupported language", null)
        whenAll(pair.map { models.isModelDownloaded(it) })
            .addOnSuccessListener { downloaded -> result.success(downloaded.all { it }) }
            .addOnFailureListener { result.success(false) }
    }

    /** Eksik paketleri indirir (mobil veri dahil; onay Flutter tarafında sorulur). */
    private fun downloadModels(call: MethodCall, result: MethodChannel.Result) {
        val pair = remoteModels(call) ?: return result.error(MODEL_DOWNLOAD, "unsupported language", null)
        val conditions = DownloadConditions.Builder().build()
        Tasks.whenAll(pair.map { models.download(it, conditions) })
            .addOnSuccessListener { result.success(null) }
            .addOnFailureListener { result.error(MODEL_DOWNLOAD, it.message, null) }
    }

    private fun translate(call: MethodCall, result: MethodChannel.Result) {
        val from = language(call.argument("from"))
        val to = language(call.argument("to"))
        if (from == null || to == null) return result.error(TRANSLATE, "unsupported language", null)
        val translator = translators.getOrPut("$from-$to") {
            Translation.getClient(TranslatorOptions.Builder().setSourceLanguage(from).setTargetLanguage(to).build())
        }
        translator.translate(call.argument<String>("text").orEmpty())
            .addOnSuccessListener { result.success(it) }
            .addOnFailureListener { result.error(TRANSLATE, it.message, null) }
    }

    private fun remoteModels(call: MethodCall): List<TranslateRemoteModel>? {
        val from = language(call.argument("from")) ?: return null
        val to = language(call.argument("to")) ?: return null
        return listOf(from, to).map { TranslateRemoteModel.Builder(it).build() }
    }

    /** ML Kit'in desteklediği dil kodu (`en`, `tr`, ...); desteklenmiyorsa `null`. */
    private fun language(code: String?): String? = code?.let { TranslateLanguage.fromLanguageTag(it) }

    private fun <T> whenAll(tasks: List<Task<T>>): Task<List<T>> = Tasks.whenAllSuccess(tasks)

    fun close() {
        translators.values.forEach { it.close() }
        translators.clear()
        identifier?.close()
        identifier = null
    }

    /** Flutter motoru kapanınca kanal ve çevirmenler bırakılır. */
    fun dispose() {
        close()
        channel.setMethodCallHandler(null)
    }

    private companion object {
        const val LANGUAGE_CONFIDENCE = 0.5f
        const val UNDETERMINED = "und"
        const val MODEL_DOWNLOAD = "modelDownload"
        const val TRANSLATE = "translate"
    }
}
