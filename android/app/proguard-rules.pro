# 기본 Android ProGuard 규칙
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses


# 앱 특정 규칙
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}