import 'dart:math';
import 'package:flutter/material.dart';

class GenreCard extends StatelessWidget {
  final String title;
  final Color color;
  final String imagePath;

  const GenreCard({
    super.key,
    required this.title,
    required this.color,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(color: color),
        child: Stack(
          children: [ 
            // título TODO: aumentar tamanho do card e diminuir espaçamento entre eles
            Positioned(
              top: 12,
              left: 12,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // imagem TODO: deixar o título encima e cantos arredondados
            Positioned(
              bottom: -10,
              right: -10,
              child: Transform.rotate(
                angle: pi / 10.0,
                child: Image.asset(
                  imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
