import 'package:flutter/material.dart';

import 'package:lumilivre_app/models/book.dart';
import 'package:lumilivre_app/models/book_details.dart';
import 'package:lumilivre_app/services/api.dart';
import 'package:lumilivre_app/utils/constants.dart';

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
              _buildSliverAppBar(context, details),
              SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeaderSection(context, details),
                  const SizedBox(height: 24),
                  _buildInfoCards(context, details),
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

  // header da página
  SliverAppBar _buildSliverAppBar(BuildContext context, BookDetails details) {
    return SliverAppBar(
      pinned: true, 
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        PopupMenuButton<String>(
          onSelected: (value) {
            print('Selecionado: $value');
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'author',
              child: ListTile(
                leading: Icon(Icons.person_search),
                title: Text('Livros do mesmo autor'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Compartilhar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // capa, título, autor e lançamento
  Widget _buildHeaderSection(BuildContext context, BookDetails details) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // capa
          Card(
            elevation: 8,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.network(
              details.imagem ?? widget.book.imageUrl,
              height: 180,
              width: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 20),
          // info
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
                ),
                const SizedBox(height: 8),
                Text(
                  details.autor,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: LumiLivreTheme.primary,
                  ),
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

  // cards de detalhes
  Widget _buildInfoCards(BuildContext context, BookDetails details) {
    // API do Google Books fornece, mas a nossa não.
    const double mockRating = 4.6;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _InfoCard(top: '★ $mockRating', bottom: 'Avaliações'),
        _InfoCard(top: details.tipoCapa, bottom: 'Tipo'),
        _InfoCard(top: details.numeroPaginas.toString(), bottom: 'Páginas'),
        _InfoCard(top: details.classificacaoEtaria, bottom: 'Classificação'),
      ],
    );
  }

  // botões like, favorito e empréstimos
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(icon: Icons.favorite_border, onTap: () {}),
          _ActionButton(icon: Icons.star_border, onTap: () {}),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(24),
              backgroundColor: LumiLivreTheme.primary,
            ),
            child: const Icon(
              Icons.add_shopping_cart,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  // sinopse e outros
  Widget _buildAdditionalInfo(BuildContext context, BookDetails details) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'Editora', value: details.editora),
          const Divider(height: 32),
          _InfoRow(label: 'Gêneros', value: details.generos.join(', ')),
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

class _InfoCard extends StatelessWidget {
  final String top;
  final String bottom;
  const _InfoCard({required this.top, required this.bottom});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          top,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(bottom, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Icon(icon, color: LumiLivreTheme.primary, size: 28),
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
