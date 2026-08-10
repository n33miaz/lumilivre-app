import 'package:flutter/material.dart';

import 'package:lumilivre/utils/constants.dart';

/// Filete de 2 px marcando um cabeçalho de bloco.
///
/// É a peça central do motivo de ficha de catálogo: no lugar da pastilha
/// colorida de "eyebrow" — que é o que toda tela gerada usa para separar seção —
/// uma régua que corre pela largura da coluna, com o peso de uma divisória de
/// gaveta de fichário. Separa sem inventar cor e sem pedir a sombra que um
/// cartão flutuante pediria.
///
/// Mora num widget porque a régua aparece em cinco lugares e a cor dela depende
/// do tema; repetida à mão, seria a quinta espessura e o quinto cinza do app.
/// Não muda nada de lugar: entra em volta do título que já existia, ocupando os
/// 2 px da régua e o respiro dela.
class SectionRule extends StatelessWidget {
  /// Régua acima do bloco. É o caso comum — título de esteira, de seção, de
  /// grade.
  const SectionRule({super.key, required this.child}) : _above = true;

  /// Régua abaixo do bloco, para cabeçalho que já é o topo de uma superfície
  /// (o de um modal, que não tem o que separar acima de si).
  const SectionRule.below({super.key, required this.child}) : _above = false;

  final Widget child;

  final bool _above;

  /// Respiro entre a régua e o texto. Curto de propósito: a régua pertence ao
  /// título, não à folga entre blocos.
  static const double _gap = 10;

  @override
  Widget build(BuildContext context) {
    final side = BorderSide(
      color: LumiLivreTheme.rule(context),
      width: LumiLivreTheme.ruleWidth,
    );

    return Container(
      decoration: BoxDecoration(
        border: _above ? Border(top: side) : Border(bottom: side),
      ),
      padding: _above
          ? const EdgeInsets.only(top: _gap)
          : const EdgeInsets.only(bottom: _gap),
      child: child,
    );
  }
}

/// Etiqueta pequena em caixa alta — a "cota" do motivo.
///
/// No web ela é o número de classificação da lombada, em monoespaçada. Aqui a
/// monoespaçada ficou de fora: o app não empacota fonte nenhuma, e pedir a
/// família genérica do sistema resolveria no Android e no navegador e cairia na
/// fonte de texto no iOS — a etiqueta mudaria de forma conforme o aparelho. O
/// que faz o trabalho dela é o que sobra e é portátil: corpo pequeno, caixa
/// alta, entrelinha apertada, muito espaço entre letras e dígitos de largura
/// fixa, que é o que alinha número com número numa coluna de cotas.
class CotaLabel extends StatelessWidget {
  const CotaLabel(this.text, {super.key, this.color});

  final String text;

  /// Por padrão o texto secundário do tema, que é o papel da etiqueta em toda
  /// superfície pública do web.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // A caixa alta pertence ao desenho, não ao texto. No web ela é
    // `text-transform` e o conteúdo continua sendo a frase; aqui ela entra na
    // string, e leitor de tela que recebe TUDO EM MAIÚSCULA tende a soletrar —
    // então o rótulo semântico volta a ser a frase como foi traduzida.
    return Semantics(
      label: text,
      child: ExcludeSemantics(
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: color ?? Theme.of(context).hintColor,
            fontSize: 12,
            height: 1.2,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.6,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
