# --- TensorFlow Lite GPU fix ---
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**
