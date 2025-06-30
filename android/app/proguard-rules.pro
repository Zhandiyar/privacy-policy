# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.editing.** { *; }
-dontwarn io.flutter.embedding.**
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep your model classes
-keep class kz.finance.fintrack.models.** { *; }
-keep class kz.finance.fintrack.data.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# Retrofit
-keepattributes Signature, InnerClasses, EnclosingMethod
-keepattributes RuntimeVisibleAnnotations, RuntimeVisibleParameterAnnotations
-keepclassmembers,allowshrinking,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement
-dontwarn javax.annotation.**
-dontwarn kotlin.Unit
-dontwarn retrofit2.KotlinExtensions
-dontwarn retrofit2.KotlinExtensions$*
-if interface * { @retrofit2.http.* <methods>; }
-keep,allowobfuscation interface <1>

# ===== Flutter Navigation & Deep Link Protection =====

# Сохраняем все экраны, участвующие в маршрутах
-keep class kz.finance.fintrack.**.ResetPasswordScreen { *; }
-keep class kz.finance.fintrack.**.LoginScreen { *; }
-keep class kz.finance.fintrack.**.RegisterScreen { *; }
-keep class kz.finance.fintrack.**.ExpenseListScreen { *; }
-keep class kz.finance.fintrack.**.ReportsScreen { *; }
-keep class kz.finance.fintrack.**.ForgotPasswordScreen { *; }

# Хранить все конструкторы и поля — чтобы не ломались аргументы
-keepclassmembers class * {
    public <init>(...);
    public *;
}

# Защита от удаления .settings.arguments
-keepclassmembers class * extends android.app.Activity {
    public void *(...);
}

# Защита от обфускации Bloc и событий
-keep class kz.finance.fintrack.**.auth.** { *; }
-keep class kz.finance.fintrack.**.blocs.** { *; }

# Не обфусцировать RouteNames
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}
