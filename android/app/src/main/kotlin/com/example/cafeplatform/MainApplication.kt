package com.gifnut.cafeplatform

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import androidx.multidex.MultiDexApplication

class MainApplication : MultiDexApplication() {
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        // LeakCanary 완전 비활성화 (WebView Dialog 크래시 방지)
        disableLeakCanary()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "gifnut_default_channel",
                "기프넛 알림",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "기프넛 앱 알림"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
    
    private fun disableLeakCanary() {
        try {
            // LeakCanary가 포함된 경우에만 비활성화
            val leakCanaryClass = Class.forName("leakcanary.LeakCanary")
            val configField = leakCanaryClass.getDeclaredField("config")
            configField.isAccessible = true
            
            // Config 클래스 찾기
            val configClass = Class.forName("leakcanary.LeakCanary\$Config")
            
            // Config.Builder 생성 방법 1: newBuilder() 메서드 사용 시도
            try {
                val companionClass = Class.forName("leakcanary.LeakCanary\$Config\$Companion")
                val companionField = configClass.getDeclaredField("Companion")
                companionField.isAccessible = true
                val companion = companionField.get(null)
                
                val newBuilderMethod = companionClass.getDeclaredMethod("newBuilder")
                val builder = newBuilderMethod.invoke(companion)
                val builderClass = builder.javaClass
                
                // dumpHeap(false) 설정
                val dumpHeapMethod = builderClass.getDeclaredMethod("dumpHeap", Boolean::class.java)
                dumpHeapMethod.invoke(builder, false)
                
                // build() 호출
                val buildMethod = builderClass.getDeclaredMethod("build")
                val disabledConfig = buildMethod.invoke(builder)
                
                configField.set(null, disabledConfig)
            } catch (e: NoSuchMethodException) {
                // 방법 2: 기존 config에서 copy() 사용
                val currentConfig = configField.get(null)
                val copyMethod = configClass.getDeclaredMethod("copy", Boolean::class.java, Boolean::class.java, Boolean::class.java, Boolean::class.java)
                val disabledConfig = copyMethod.invoke(currentConfig, false, false, false, false)
                configField.set(null, disabledConfig)
            }
        } catch (e: ClassNotFoundException) {
            // LeakCanary가 없거나 no-op 버전이 사용된 경우 (정상)
        } catch (e: Exception) {
            // 기타 예외 무시
        }
    }
}

