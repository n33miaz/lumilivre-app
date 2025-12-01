import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lumilivre/models/book.dart';
import 'package:lumilivre/models/book_details.dart';
import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/utils/constants.dart';

class BookDetailsScreen extends StatefulWidget {
  final Book book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  final ApiService _apiService = ApiService();
  Future<BookDetails>? _bookDetailsFuture;

  @override
  void initState() {
    super.initState();
    _bookDetailsFuture = _apiService.getBookDetails(widget.book.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<BookDetails>(
        future: _bookDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Nenhum detalhe encontrado.'));
          }

          final details = snapshot.data!;

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeaderSection(context, details),
                  const SizedBox(height: 24),
                  _buildInfoRow(context, details),
                  const SizedBox(height: 24),
                  _buildActionButtons(context),
                  const SizedBox(height: 24),
                  _buildAdditionalInfo(context, details),
                  const SizedBox(height: 40),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            // TODO: "Livros do mesmo autor"
            print('Selecionado: $value');
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'author',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.person_search),
                title: Text('Livros do mesmo autor'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context, BookDetails details) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            height: 180,
            child: Card(
              elevation: 8,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.network(
                (details.imagem != null && details.imagem!.isNotEmpty)
                    ? details.imagem!
                    : widget.book.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported, color: Colors.grey),
                        SizedBox(height: 4),
                        Text(
                          'Sem Capa',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  details.nome,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  details.autor,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: LumiLivreTheme.primary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Lançado em ${details.dataLancamento.day}/${details.dataLancamento.month}/${details.dataLancamento.year}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, BookDetails details) {
    final tipoCapaFormatado = details.tipoCapa
        .replaceFirst('Capa ', '')
        .toUpperCase();

    final normalizedClassificacao = details.classificacaoEtaria
        .toLowerCase()
        .trim()
        .replaceAll(' ', '_');

    final classificacaoAsset = 'assets/images/$normalizedClassificacao.png';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InfoItem(top: '★ 4.6', bottom: 'Avaliações'),

          _InfoItem(top: tipoCapaFormatado, bottom: 'Tipo da Capa'),

          _InfoItem(top: details.numeroPaginas.toString(), bottom: 'Páginas'),

          Column(
            children: [
              SizedBox(
                height: 24,
                child: Image.asset(
                  classificacaoAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.info_outline,
                      size: 24,
                      color: Colors.grey[600],
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Faixa Etária',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        children: [
          const _LikeButton(),
          const SizedBox(width: 16),
          const Expanded(child: _BorrowButton()),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(BuildContext context, BookDetails details) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'Editora', value: details.editora),
          const Divider(height: 32),
          Row(
            children: [
              Text('Gêneros', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  details.generos.join(', '),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Text(
            'Sinopse',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            details.sinopse,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String top;
  final String bottom;
  const _InfoItem({required this.top, required this.bottom});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 24,
          child: Center(
            child: Text(
              top,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(bottom, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}

class _LikeButton extends StatefulWidget {
  const _LikeButton();

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _isLiked = !_isLiked;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? Colors.redAccent : LumiLivreTheme.primary,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _BorrowButton extends StatefulWidget {
  const _BorrowButton();

  @override
  State<_BorrowButton> createState() => _BorrowButtonState();
}

class _BorrowButtonState extends State<_BorrowButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        // TODO: Lógica de solicitar empréstimo
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Solicitação enviada!')));
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 56,
        decoration: BoxDecoration(
          color: _isPressed
              ? LumiLivreTheme.primary.withOpacity(0.9)
              : LumiLivreTheme.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: LumiLivreTheme.primary.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              _isPressed
                  ? 'assets/icons/loans-active.svg'
                  : 'assets/icons/loans.svg',
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'SOLICITAR EMPRÉSTIMO',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
