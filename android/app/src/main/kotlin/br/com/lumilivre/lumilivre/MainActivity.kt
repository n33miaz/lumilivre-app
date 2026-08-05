package br.com.lumilivre.lumilivre

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity (e nao FlutterActivity) porque o BiometricPrompt do
// androidx e um Fragment: hospedado numa Activity que nao e FragmentActivity, o
// local_auth recusa a chamada com `no_fragment_activity` e o gate biometrico
// falharia fechado em todo aparelho, sem o usuario entender o motivo.
class MainActivity : FlutterFragmentActivity()
