# 기본 Android ProGuard 규칙
# 릴리스 R8/ProGuard로 플러터·Firebase 심볼이 제거되며 스플래시 이후 멈춤 나는 경우 완화
# https://medium.com/@chetan.akarte/flutter-app-freezes-on-the-splash-screen-in-release-mode-e15a6045a189
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses


# 앱 특정 규칙
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}