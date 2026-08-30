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
