import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/models/book.dart';
import 'package:lumilivre/models/book_details.dart';
import 'package:lumilivre/models/loan.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/favorites.dart';
import 'package:lumilivre/utils/constants.dart';

enum LoanStatus {
  loading,
  available,
  unavailable,
  noCopies,
  pending,
  active,
  overdue,
  guest,
  blockedPenalty,
  limitReached,
}

class BookDetailsScreen extends StatefulWidget {
  final Book book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  final ApiService _apiService = ApiService();

  BookDetails? _details;
  LoanStatus _status = LoanStatus.loading;
  DateTime? _dueDate;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final details = await _apiService.getBookDetails(widget.book.id);

      if (!authProvider.isAuthenticated || authProvider.user == null) {
        if (mounted) {
          setState(() {
            _details = details;
            _status = LoanStatus.guest;
            _hasError = false;
          });
        }
        return;
      }

      final user = authProvider.user!;
      final matricula = user.matriculaAluno!;
      final token = user.token;

      final results = await Future.wait([
        _apiService.getMyLoans(matricula, token),
        _apiService.getMyRequests(matricula, token),
        _apiService.getStudentData(matricula, token),
      ]);

      final loans = results[0] as List<Loan>;
      final requests = results[1] as List<dynamic>;
      final studentData = results[2] as Map<String, dynamic>?;

      if (mounted) {
        _calculateStatus(details, loans, requests, studentData);
        setState(() => _hasError = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _status = LoanStatus.available;
        });
      }
    }
  }

  void _calculateStatus(
    BookDetails details,
    List<Loan> loans,
    List<dynamic> requests,
    Map<String, dynamic>? studentData,
  ) {
    LoanStatus newStatus = LoanStatus.available;
    DateTime? date;

    final activeLoan = loans.firstWhere(
      (l) => l.livroId == widget.book.id,
      orElse: () => Loan(
        id: -1,
        dataEmprestimo: DateTime.now(),
        dataDevolucao: DateTime(1900),
        status: '',
        livroId: -1,
        livroTitulo: '',
      ),
    );

    if (activeLoan.id != -1) {
      date = activeLoan.dataDevolucao;
      newStatus = DateTime.now().isAfter(activeLoan.dataDevolucao)
          ? LoanStatus.overdue
          : LoanStatus.active;
    } else {
      final hasPendingRequest = requests.any((r) {
        if (r == null || r is! Map) return false;
        final reqLivroId = (r['livroId'] as num?)?.toInt() ?? -1;
        final reqStatus = r['status']?.toString() ?? '';
        return (reqLivroId == widget.book.id) && (reqStatus == 'PENDENTE');
      });

      if (hasPendingRequest) {
        newStatus = LoanStatus.pending;
      } else {
        String? penalidade = studentData?['penalidade'];
        bool hasPenalty = penalidade != null && penalidade != "null";

        int activeLoansCount = loans.length;

        if (details.totalExemplares == 0) {
          newStatus = LoanStatus.noCopies;
        } else if (hasPenalty) {
          newStatus = LoanStatus.blockedPenalty;
        } else if (activeLoansCount >= 3) {
          newStatus = LoanStatus.limitReached;
        } else if (details.exemplaresDisponiveis <= 0) {
          newStatus = LoanStatus.unavailable;
        } else {
          newStatus = LoanStatus.available;
        }
      }
    }

    setState(() {
      _details = details;
      _status = newStatus;
      _dueDate = date;
    });
  }

  Future<void> _handleLoanRequest() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _status = LoanStatus.loading);

    bool success = await _apiService.requestLoanByBookId(
      auth.user!.matriculaAluno!,
      widget.book.id,
      auth.user!.token,
    );

    if (success) {
      await _loadAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitação enviada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        setState(() => _status = LoanStatus.available);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao solicitar. Verifique se há exemplares.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && _details == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Não foi possível carregar os dados.'),
              ElevatedButton(
                onPressed: _loadAllData,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: _details == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(context),
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeaderSection(context, _details!),
                    const SizedBox(height: 24),
                    _buildInfoRow(context, _details!),
                    const SizedBox(height: 24),
                    _buildActionButtons(context),
                    const SizedBox(height: 24),
                    _buildAdditionalInfo(context, _details!),
                    const SizedBox(height: 40),
                  ]),
                ),
              ],
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
      // actions: [
      //   PopupMenuButton<String>(
      //     onSelected: (value) {
      //       print('Selecionado: $value');
      //     },
      //     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
      //       const PopupMenuItem<String>(
      //         value: 'author',
      //         child: ListTile(
      //           contentPadding: EdgeInsets.zero,
      //           leading: Icon(Icons.person_search),
      //           title: Text('Livros do mesmo autor'),
      //         ),
      //       ),
      //     ],
      //   ),
      // ],
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
                width: 120,
                height: 180,
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
          _InfoItem(top: '★ ${details.rating}', bottom: 'Avaliações'),

          _InfoItem(top: tipoCapaFormatado, bottom: 'Tipo da Capa'),

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
          _LikeButton(book: widget.book),
          const SizedBox(width: 16),
          Expanded(
            child: _BorrowButton(
              status: _status,
              dueDate: _dueDate,
              onPressed: _handleLoanRequest,
            ),
          ),
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

class _LikeButton extends StatelessWidget {
  final Book book;

  const _LikeButton({required this.book});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isLiked = favoritesProvider.isFavorite(book.id);

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
          favoritesProvider.toggleFavorite(book);
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.redAccent : LumiLivreTheme.primary,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _BorrowButton extends StatelessWidget {
  final LoanStatus status;
  final DateTime? dueDate;
  final VoidCallback? onPressed;

  const _BorrowButton({required this.status, this.dueDate, this.onPressed});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String text;
    String iconPath = 'assets/icons/loans.svg';
    bool isClickable = false;

    switch (status) {
      case LoanStatus.loading:
        return const SizedBox(
          height: 56,
          child: Center(child: CircularProgressIndicator()),
        );

      case LoanStatus.guest:
        backgroundColor = Colors.grey;
        text = 'FAÇA LOGIN PARA SOLICITAR';
        break;

      case LoanStatus.noCopies:
        backgroundColor = Colors.grey.shade400;
        text = 'SEM EXEMPLARES CADASTRADOS';
        iconPath = 'assets/icons/cancel.svg';
        break;

      case LoanStatus.blockedPenalty:
        backgroundColor = Colors.redAccent;
        text = 'CONTA COM PENALIDADE';
        break;

      case LoanStatus.limitReached:
        backgroundColor = Colors.orange.shade800;
        text = 'LIMITE DE EMPRÉSTIMOS ATINGIDO';
        break;

      case LoanStatus.available:
        backgroundColor = LumiLivreTheme.primary;
        text = 'SOLICITAR EMPRÉSTIMO';
        isClickable = true;
        break;

      case LoanStatus.pending:
        backgroundColor = Colors.amber;
        text = 'AGUARDANDO APROVAÇÃO';
        iconPath = 'assets/icons/loans-active.svg';
        break;

      case LoanStatus.active:
        backgroundColor = Colors.green;
        String dateStr = dueDate != null
            ? '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}'
            : '?';
        text = 'EM USO ATÉ: $dateStr';
        break;

      case LoanStatus.overdue:
        backgroundColor = Colors.redAccent;
        text = 'DEVOLUÇÃO EXCEDIDA';
        break;

      case LoanStatus.unavailable:
        backgroundColor = Colors.grey;
        if (dueDate != null && dueDate!.isAfter(DateTime.now())) {
          String dateStr = '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';
          text = 'DISPONÍVEL A PARTIR DE: $dateStr';
        } else {
          text = 'INDISPONÍVEL NO MOMENTO';
        }
        break;
    }

    return GestureDetector(
      onTap: isClickable ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isClickable
              ? [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (status == LoanStatus.available)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SvgPicture.asset(
                  iconPath,
                  height: 24,
                  colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                ),
              ),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
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
