# Regras do R8 para o release do app.
#
# O APK é distribuído por download direto: qualquer pessoa baixa, descompila e
# lê. Minificar renomeia classes/métodos e joga fora o que não é alcançável, o
# que encarece a leitura. O risco é o inverso: o R8 não vê chamadas por JNI nem
# por reflexão, então o que é resolvido por nome precisa ser mantido aqui à mão.
# Um APK que minifica e crasha é pior que um não minificado — cada bloco abaixo
# existe porque a alternativa é falha só em release, que não aparece no debug.
#
# O Flutter já injeta `proguard-android-optimize.txt` e o
# `flutter_proguard_rules.pro` do SDK (que trata `io.flutter.plugin.**` e
# `android.**`); aqui ficam apenas as regras específicas deste app.

# --- Embedding do Flutter ----------------------------------------------------
# O engine (C++) chama o embedding por JNI. Sem referência Java para rastrear,
# o R8 consideraria os métodos inalcançáveis e o app abriria em tela preta.
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.util.** { *; }

# O embedding referencia o Play Core (download de componentes deferidos) mesmo
# sem usarmos deferred components. Sem isto o R8 aborta em "Missing class".
-dontwarn com.google.android.play.core.**

# --- flutter_secure_storage / Tink -------------------------------------------
# É onde o JWT da sessão mora. O tink-android (dependência do plugin na v10)
# resolve as primitivas de cifra por nome de classe registrado, em runtime:
# renomeá-las quebra a leitura do token e o auto-login morre só no release.
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**
# Anotações de build-time que o Tink arrasta e não existem no APK.
-dontwarn javax.annotation.**
-dontwarn com.google.errorprone.annotations.**

# --- local_auth / biometria --------------------------------------------------
# O gate biométrico falha fechado: se o R8 remover o plugin ou o BiometricPrompt,
# `authenticate` lança e o auto-login é recusado — o usuário fica sem sessão
# restaurada sem entender por quê.
-keep class io.flutter.plugins.localauth.** { *; }
-keep class androidx.biometric.** { *; }

# --- Plugins registrados por nome -------------------------------------------
# O `GeneratedPluginRegistrant` é `@Keep`, mas o R8 já removeu implementações de
# `FlutterPlugin` por engano (flutter#154580) — a própria regra do SDK existe por
# causa disso. Estes três carregam funções sem plano B: sessão, biometria e o
# gate de versão (se o `package_info` sumir, o gate cai no fail-open e para de
# proteger).
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class dev.fluttercommunity.plus.packageinfo.** { *; }

# --- Stack trace legível -----------------------------------------------------
# O `proguard-android-optimize.txt` não preserva linha/arquivo. Sem estes
# atributos o trace de produção perde o número de linha e o `mapping.txt` não
# recupera mais nada além do nome do método.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
-keepattributes Signature,InnerClasses,EnclosingMethod
