# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Play Core
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Bloc
-keep class * extends bloc.** { *; }
-keepclassmembers class * extends bloc.** { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Notification
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.** { *; }

# GetIt & Injectable
-keepattributes *Annotation*
-keepclassmembers class * {
    @javax.inject.* <fields>;
    @javax.inject.* <init>(...);
}