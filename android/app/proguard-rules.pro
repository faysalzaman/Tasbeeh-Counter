# ProGuard rules for Digital Tasbeeh

# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Hive (local database)
-keep class com.hivedb.** { *; }
-keep class * extends com.hivedb.TypeAdapter { *; }

# Keep local notification models
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# flutter_local_notifications deserializes scheduled notifications with Gson
# TypeTokens in ScheduledNotificationReceiver. R8 strips the generic type
# info, which crashes the app when a scheduled notification fires.
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep class com.google.gson.** { *; }

# Keep Riverpod/Provider
-keep class * extends StateNotifier { *; }
-keep class * extends AsyncNotifier { *; }

# Keep generated localizations
-keep class **.app_localizations { *; }
-keep class **.app_localizations_** { *; }

# Keep models used in JSON/Hive
-keep class **.models.** { *; }

# AudioPlayers
-keep class xyz.luan.audioplayers.** { *; }

# URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# Play Core / Deferred Components (Flutter references these but app doesn't use split APKs)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
