# Keep just_audio
-keep class com.ryanheise.just_audio.** { *; }

# Keep Media3
-keep class androidx.media3.** { *; }

# Keep ExoPlayer
-keep class com.google.android.exoplayer2.** { *; }

# Don't warn
-dontwarn androidx.media3.**
-dontwarn com.google.android.exoplayer2.**