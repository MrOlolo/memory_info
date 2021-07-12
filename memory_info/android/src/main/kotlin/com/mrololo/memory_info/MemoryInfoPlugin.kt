package com.mrololo.memory_info

import android.app.ActivityManager
import android.content.Context
import android.content.Context.ACTIVITY_SERVICE
import android.os.Environment
import android.os.StatFs
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** MemoryInfoPlugin */
class MemoryInfoPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var applicationContext: Context? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "github.com/MrOlolo/memory_info")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getDiskSpace" -> result.success(getDiskSpace())
            "getMemoryInfo" -> result.success(getMemInfo())
            else ->
                result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = null
        channel.setMethodCallHandler(null)
    }

    private fun getDiskSpace(): Map<String, Double> {
        val stat = StatFs(Environment.getDataDirectory().path)

        val bytesAvailable: Long
        val bytesTotal: Long

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN_MR2) {
            bytesAvailable = stat.blockSizeLong * stat.availableBlocksLong
            bytesTotal = stat.blockSizeLong * stat.blockCountLong
        } else {
            bytesAvailable = stat.blockSize.toLong() * stat.availableBlocks.toLong()
            bytesTotal = stat.blockSize.toLong() * stat.blockCount.toLong()
        }
        return mapOf("diskFreeSpace" to (bytesAvailable / (1024f * 1024f)).toDouble(),
                "diskTotalSpace" to (bytesTotal / (1024f * 1024f)).toDouble())
    }

    private fun getMemInfo(): Map<String, Any> {
        applicationContext?.let {
            val actManager: ActivityManager = it.getSystemService(ACTIVITY_SERVICE) as ActivityManager
            val memInfo = ActivityManager.MemoryInfo()
            actManager.getMemoryInfo(memInfo)
            val totalMem: Long = memInfo.totalMem
            val freeMem: Long = memInfo.availMem
            val lowMem: Boolean = memInfo.lowMemory
            val runtime = Runtime.getRuntime()
            val usedByApp: Long = (runtime.totalMemory() - runtime.freeMemory()) / 1048576L;
            return mapOf(
                    "usedByApp" to usedByApp,
                    "total" to (totalMem / (1024f * 1024f)).toDouble(),
                    "free" to (freeMem / (1024f * 1024f)).toDouble(),
                    "lowMemory" to lowMem
            )
        }

        return mapOf(
                "total" to 0,
                "free" to 0
        )
    }

}

