import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lumilivre/models/ranking.dart';
import 'package:lumilivre/utils/constants.dart';

class RankingPodium extends StatelessWidget {
  final List<RankingItem> topThree;

  const RankingPodium({super.key, required this.topThree});

  @override
  Widget build(BuildContext context) {
    if (topThree.isEmpty) return const SizedBox.shrink();

    final first = topThree.isNotEmpty ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Container(
      height: 320,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (second != null)
            Expanded(child: _PodiumBar(item: second, position: 2)),
          if (first != null)
            Expanded(child: _PodiumBar(item: first, position: 1)),
          if (third != null)
            Expanded(child: _PodiumBar(item: third, position: 3)),
        ],
      ),
    );
  }
}

class _PodiumBar extends StatelessWidget {
  final RankingItem item;
  final int position;

  const _PodiumBar({required this.item, required this.position});

  @override
  Widget build(BuildContext context) {
    final isFirst = position == 1;
    final isSecond = position == 2;

    final double height = isFirst ? 220 : (isSecond ? 160 : 120);

    final Color color = isFirst
        ? const Color(0xFFFFD700)
        : (isSecond ? const Color(0xFFC0C0C0) : const Color(0xFFCD7F32));

    final String medalIcon = isFirst
        ? 'assets/icons/medal1.svg'
        : (isSecond ? 'assets/icons/medal2.svg' : 'assets/icons/medal3.svg');

    final iconWidget = SvgPicture.asset(
      medalIcon,
      height: 40,
      color: color,
      placeholderBuilder: (_) =>
          Icon(Icons.emoji_events, size: 40, color: color),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        iconWidget,
        const SizedBox(height: 8),

        Text(
          item.nome.split(' ').first,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            '${item.emprestimosCount}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: LumiLivreTheme.primary,
            ),
          ),
        ),

        Container(
          height: height,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border(top: BorderSide(color: color, width: 4)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.4), color.withOpacity(0.05)],
            ),
          ),
          child: Center(
            child: Text(
              '$position',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: color.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
