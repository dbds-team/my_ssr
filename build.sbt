scalaVersion := "2.11.8"
dexMaxHeap := "4g"

enablePlugins(AndroidApp)
android.useSupportVectors

name := "shadowsocksr-v2ray"

applicationId := "com.xxf098.ssrray"

val supportLibVersion = "27.1.1"
platformTarget := "android-29"

compileOrder := CompileOrder.JavaThenScala
javacOptions ++= "-source" :: "1.8" :: "-target" :: "1.8" :: Nil
scalacOptions ++= "-target:jvm-1.8" :: "-Xexperimental" :: Nil
ndkJavah := Seq()
ndkBuild := Seq()

proguardVersion := "6.2.0"
proguardCache := Seq()
proguardOptions ++=
  "-keep class com.github.shadowsocks.System { *; }" ::
  "-keep class tun2socks.** { *;}" ::
  "-keep class go.** { *;}" ::
  "-keep class okhttp3.** { *; }" ::
  "-keep interface okhttp3.** { *; }" ::
  "-keep class okio.** { *; }" ::
  "-keep interface okio.** { *; }" ::
  "-keep class kotlin.jvm.functions.** { *; }" ::
  "-keep class kotlin.** { *; }" ::
  "-keep class com.github.mikephil.charting.** { *; }" ::
  "-keep class com.mikepenz.** { *; }" ::
  "-keep class me.dm7.barcodescanner.** { *; }" ::
  "-keep class com.google.android.gms.** { *; }" ::
  "-keep class com.google.zxing.** { *; }" ::
  "-keep class com.github.jorgecastilloprz.progressarc.** { *; }" ::
  "-keep class net.glxn.qrgen.** { *; }" ::
  "-keep class com.github.clans.** { *; }" ::
  "-keep class com.evernote.** { *; }" ::
  "-keep class android.widget.Space { *; }" ::
  "-keepattributes InnerClasses" ::
  "-keepattributes Signature" ::
  "-keepattributes *Annotation*" ::
  "-keepattributes EnclosingMethod" ::
  "-keepattributes RuntimeVisibleAnnotations" ::
  "-keepattributes RuntimeInvisibleAnnotations" ::
  "-keepclassmembers class * { public <init>(...); }" ::
  "-keepclassmembers enum * { public static **[] values(); public static ** valueOf(java.lang.String); }" ::
  "-dontwarn okio.**" ::
  "-dontwarn okhttp3.**" ::
  "-dontwarn kotlin.**" ::
  "-dontwarn com.github.mikephil.charting.**" ::
  "-dontwarn com.mikepenz.**" ::
  "-dontwarn me.dm7.barcodescanner.**" ::
  "-dontwarn com.google.android.gms.**" ::
  "-dontwarn com.google.zxing.**" ::
  "-dontwarn com.github.jorgecastilloprz.**" ::
  "-dontwarn net.glxn.qrgen.**" ::
  "-dontwarn com.github.clans.**" ::
  "-dontwarn com.evernote.**" ::
  "-dontwarn com.j256.ormlite.**" ::
  "-dontwarn org.xbill.**" ::
  "-dontwarn javax.annotation.**" ::
  "-dontwarn android.widget.Space" ::
  "-ignorewarnings" ::
  Nil

shrinkResources := true
typedResources := false
resConfigs := Seq("ja", "ru", "zh-rCN", "zh-rTW")

resolvers += "Google" at "https://maven.google.com/"
resolvers += "jitpack" at "https://jitpack.io"
resolvers += "Maven Central" at "https://repo1.maven.org/maven2/"

libraryDependencies ++=
  "com.android.support" % "cardview-v7" % supportLibVersion ::
  "com.android.support" % "design" % supportLibVersion ::
  "com.android.support" % "gridlayout-v7" % supportLibVersion ::
  "com.android.support" % "preference-v14" % supportLibVersion ::
  "com.evernote" % "android-job" % "1.1.3" ::
  "com.github.clans" % "fab" % "1.6.4" ::
  "com.github.jorgecastilloprz" % "fabprogresscircle" % "1.01" ::
  "com.google.android.gms" % "play-services-analytics" % "10.0.1" ::
  "com.google.android.gms" % "play-services-gcm" % "10.0.1" ::
  "com.j256.ormlite" % "ormlite-android" % "5.1" ::
  "com.mikepenz" % "fastadapter" % "2.1.5" ::
  "com.mikepenz" % "iconics-core" % "2.8.2" ::
  "com.mikepenz" % "materialdrawer" % "5.8.1" ::
  "com.mikepenz" % "materialize" % "1.0.0" ::
  "com.github.twofortyfouram" % "android-plugin-api-for-locale" % "1.0.2" ::
  "dnsjava" % "dnsjava" % "2.1.9" ::
  "com.github.Chainfire" % "libsuperuser" % "1.1.0" ::
  "me.dm7.barcodescanner" % "zxing" % "1.9.8" ::
  "net.glxn.qrgen" % "android" % "2.0" ::
  "com.squareup.okhttp3" % "okhttp" % "4.4.1" ::
  "com.github.PhilJay" % "MPAndroidChart" % "3.1.0" ::
  "com.google.code.gson" % "gson" % "2.8.6" ::
Nil

lazy val nativeBuild = TaskKey[Unit]("native-build", "Build native executables")
nativeBuild := {
  val logger = streams.value.log
  Process("./build.sh") ! logger match {
    case 0 => // Success!
    case n => sys.error(s"Native build script exit code: $n")
  }
}
