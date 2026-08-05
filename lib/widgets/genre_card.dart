import 'dart:math';
import 'package:flutter/material.dart';

import 'package:lumilivre/utils/app_motion.dart';
import 'package:lumilivre/utils/constants.dart';

class GenreCard extends StatefulWidget {
  final String title;
  final Color color;
  final String imagePath;
  final VoidCallback onTap;

  const GenreCard({
    super.key,
    required this.title,
    required this.color,
    required this.imagePath,
    required this.onTap,
  });

  @override
  State<GenreCard> createState() => _GenreCardState();
}

class _GenreCardState extends State<GenreCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      // `easeInOutBack` num afundar de cartão faz o cartão passar do ponto e
      // voltar: é o pulo mais visível do app. Mesma duração, curva sem
      // sobrepasso.
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: AppMotion.of(context, AppMotion.micro),
        curve: AppMotion.enter,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: _isPressed ? 2 : 5,
          shadowColor: widget.color.withValues(alpha: 0.4),
          child: Container(
            decoration: BoxDecoration(
              color: widget.color,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [widget.color.withValues(alpha: 0.8), widget.color],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: -12,
                  right: -8,
                  child: Transform.rotate(
                    angle: pi / 10.0,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(4, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          widget.imagePath,
                          width: 65,
                          height: 90,
                          fit: BoxFit.cover,
                          cacheWidth: 130,
                          cacheHeight: 180,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Text(
                    widget.title,
                    // A carta é sempre a cor da categoria, nos dois temas: a
                    // tinta é a mesma das superfícies de marca. As sombras
                    // abaixo ficam em preto de propósito — elas caem sobre a
                    // imagem da capa, não sobre a superfície do tema.
                    style: const TextStyle(
                      color: LumiLivreTheme.onBrand,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4.0,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
