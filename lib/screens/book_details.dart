import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/models/book.dart';
import 'package:lumilivre/models/book_details.dart';
import 'package:lumilivre/models/loan.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/favorites.dart';
import 'package:lumilivre/providers/guest_access.dart';
import 'package:lumilivre/screens/auth/login.dart';
import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/services/loan_status_calculator.dart';
import 'package:lumilivre/utils/app_motion.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/utils/parsers.dart';
import 'package:lumilivre/widgets/app_toast.dart';

/// Estados que o botão de empréstimo sabe mostrar.
///
/// Não existe mais estado de penalidade aqui: ele desabilitava o botão sem
/// explicar nada e obrigava o app a decidir, com o cadastro do leitor na mão,
/// algo que só o servidor decide. Ver `LoanStatusCalculator`.
enum LoanStatus {
  loading,
  available,
  unavailable,
  noCopies,
  pending,
  active,
  overdue,
  guest,
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
  bool _isGuest = false;

  /// Motivo da última falha, não só "deu erro": a tela responde diferente para
  /// falta de sessão e para falta de rede.
  ApiFailure? _failure;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  /// Carrega a ficha e, para quem tem sessão, o estado de empréstimo.
  ///
  /// A requisição é tentada também sem sessão: o catálogo é vitrine e
  /// `GET /api/books/{id}` pode virar público. Enquanto exigir papel READER, o
  /// 401 chega tipado e a tela convida ao login em vez de acusar rede.
  Future<void> _load() async {
    if (!mounted) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    final isGuest = !auth.isAuthenticated || user == null;

    setState(() {
      _isGuest = isGuest;
      _failure = null;
      if (_details == null) {
        _status = LoanStatus.loading;
      }
    });

    try {
      final details = await _apiService.getBookDetails(
        widget.book.id,
        token: user?.token,
      );

      if (!mounted) return;

      if (isGuest) {
        setState(() {
          _details = details;
          _status = LoanStatus.guest;
        });
        return;
      }

      final registrationNumber = user.readerRegistrationNumber!;
      final token = user.token;

      // O cadastro do leitor era buscado aqui só para checar penalidade. Saiu
      // junto com o estado do botão: uma requisição menos por ficha de livro, e
      // a penalidade passa a ser assunto do perfil e da resposta ao pedido.
      final results = await Future.wait([
        _apiService.getMyLoans(registrationNumber, token),
        _apiService.getMyRequests(registrationNumber, token),
      ]);

      final loans = results[0];
      final requests = results[1];

      if (mounted) {
        _calculateStatus(details, loans, requests);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _failure = ApiException.fromError(e).failure;
          if (_details != null) {
            _status = LoanStatus.available;
          }
        });
      }
    }
  }

  /// Abre o login empilhado e recarrega ao voltar: entrar aqui tem que revelar a
  /// ficha do livro que estava na tela, sem o usuário precisar navegar de novo.
  Future<void> _openLogin() async {
    await Navigator.of(context).push(
      AppPageRoute<void>(context: context, builder: (_) => const LoginScreen()),
    );
    if (mounted) {
      await _load();
    }
  }

  void _calculateStatus(
    BookDetails details,
    List<Loan> loans,
    List<Loan> requests,
  ) {
    final result = LoanStatusCalculator.calculate(
      details: details,
      loans: loans,
      requests: requests,
      targetBookId: widget.book.id,
    );

    setState(() {
      _details = details;
      _status = result.status;
      _dueDate = result.dueDate;
    });
  }

  /// Pede o empréstimo e conta o resultado num toast.
  ///
  /// A recusa por penalidade, por limite de três empréstimos ou por exemplar já
  /// tomado vem do `RequestApprovalPolicy` da API, cada uma com a própria frase
  /// traduzida — é ela que aparece, em vez do antigo "Erro ao solicitar.
  /// Verifique se há exemplares." que servia de resposta para tudo. Toast, e não
  /// dialog: é resultado de ação, o usuário não precisa confirmar nada.
  Future<void> _handleLoanRequest() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    final toast = AppToast.of(context);

    final previousStatus = _status;
    setState(() => _status = LoanStatus.loading);

    try {
      await _apiService.requestLoanByBookId(
        auth.user!.readerRegistrationNumber!,
        widget.book.id,
        auth.user!.token,
      );

      await _load();
      if (mounted) {
        toast.success(l10n.loanRequestSent);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _status = previousStatus);
      final failure = ApiException.fromError(e);

      // A senha inicial pendente é o único 403 que não é falta de sessão: a saída
      // é trocar a senha, então o aviso diz isso em vez de sugerir novo login.
      if (failure.requiresPasswordChange) {
        toast.error(l10n.passwordChangeRequiredMessage);
        return;
      }
      if (failure.failure == ApiFailure.network) {
        toast.error(l10n.connectionErrorMessage);
        return;
      }
      toast.error(failure.apiMessage ?? l10n.loanRequestFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failure != null && _details == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes')),
        body: _buildFailureBody(context),
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

  /// Falta de sessão não é erro: é convite.
  ///
  /// Só a falha de rede/servidor merece cara de erro com "tentar novamente" —
  /// era o que aparecia para o convidado e fazia parecer app offline.
  Widget _buildFailureBody(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final needsLogin = _failure == ApiFailure.unauthorized;

    // 401 tem duas leituras: o visitante nunca teve sessão, o leitor tinha e ela
    // caiu. A ação é a mesma, a frase não.
    final String title;
    if (!needsLogin) {
      title = l10n.bookDetailsLoadError;
    } else {
      title = _isGuest ? l10n.guestBookTitle : l10n.sessionExpiredMessage;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              needsLogin ? Icons.lock_outline : Icons.wifi_off_outlined,
              size: 64,
              color: needsLogin
                  ? theme.colorScheme.primary
                  : theme.hintColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (needsLogin && _isGuest) ...[
              const SizedBox(height: 8),
              Text(
                l10n.guestBookMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.hintColor),
              ),
            ],
            const SizedBox(height: 28),
            if (needsLogin)
              ElevatedButton.icon(
                onPressed: _openLogin,
                icon: const Icon(Icons.login, size: 18),
                label: Text(l10n.loginAction),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retryAction),
              ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    // Cor, elevação e sombra ao rolar vêm do `appBarTheme`.
    return SliverAppBar(
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      // actions: [
      //   PopupMenuButton<String>(
      //     onSelected: (value) {
      //       debugPrint('Selecionado: $value');
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
              child: CachedNetworkImage(
                imageUrl: (details.imagem != null && details.imagem!.isNotEmpty)
                    ? details.imagem!
                    : widget.book.imageUrl,
                fit: BoxFit.cover,
                width: 120,
                height: 180,
                memCacheWidth: 360,
                placeholder: (context, url) => Container(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) {
                  final scheme = Theme.of(context).colorScheme;
                  return Container(
                    color: scheme.surfaceContainerHighest,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sem Capa',
                          style: TextStyle(
                            fontSize: 10,
                            color: scheme.onSurfaceVariant,
                          ),
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
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Lançado em ${details.dataLancamento.day}/${details.dataLancamento.month}/${details.dataLancamento.year}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
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
        .replaceAll('_', ' ')
        .toUpperCase()
        .replaceFirst('CAPA ', '')
        .trim()
        .toCapitalized();

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
                      color: Theme.of(context).hintColor,
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Faixa Etária',
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // Curtir e solicitar são do leitor identificado — a política única responde,
    // a tela só obedece.
    final access = GuestAccess.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        children: [
          if (access.canLikeBooks) ...[
            _LikeButton(book: widget.book),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: access.canRequestLoan
                ? _BorrowButton(
                    status: _status,
                    dueDate: _dueDate,
                    onPressed: _handleLoanRequest,
                  )
                : _BorrowButton(
                    status: LoanStatus.guest,
                    onPressed: _openLogin,
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
              Text(
                'Gêneros',
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
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
        Text(
          bottom,
          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
        ),
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
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LumiLivreTheme.radiusControl),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(LumiLivreTheme.radiusControl),
        onTap: () => favoritesProvider.toggleFavorite(book),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? LumiLivreTheme.like : scheme.primary,
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
    final scheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color textColor = LumiStatusColors.onFill;
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
        // Este botão **é** clicável: leva ao login. O cinza de indisponível
        // dizia o contrário, então ele fica em tom de marca, sem preenchimento.
        backgroundColor = scheme.primary.withValues(alpha: 0.12);
        textColor = scheme.primary;
        text = 'FAÇA LOGIN PARA SOLICITAR';
        iconPath = '';
        break;

      case LoanStatus.noCopies:
        backgroundColor = scheme.surfaceContainerHighest;
        textColor = scheme.onSurfaceVariant;
        text = 'SEM EXEMPLARES CADASTRADOS';
        iconPath = 'assets/icons/cancel.svg';
        break;

      case LoanStatus.limitReached:
        backgroundColor = LumiStatusColors.warningFill;
        text = 'LIMITE DE EMPRÉSTIMOS ATINGIDO';
        break;

      case LoanStatus.available:
        backgroundColor = LumiLivreTheme.primary;
        text = 'SOLICITAR EMPRÉSTIMO';
        isClickable = true;
        break;

      case LoanStatus.pending:
        // Era `Colors.amber` com texto branco: 1,7:1 de contraste, ou seja, a
        // frase mais importante do fluxo de solicitação ilegível ao sol.
        backgroundColor = LumiStatusColors.warningFill;
        text = 'AGUARDANDO APROVAÇÃO';
        iconPath = 'assets/icons/loans-active.svg';
        break;

      case LoanStatus.active:
        backgroundColor = LumiStatusColors.successFill;
        String dateStr = dueDate != null
            ? '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}'
            : '?';
        text = 'EM USO ATÉ: $dateStr';
        break;

      case LoanStatus.overdue:
        backgroundColor = LumiStatusColors.dangerFill;
        text = 'DEVOLUÇÃO EXCEDIDA';
        break;

      case LoanStatus.unavailable:
        backgroundColor = scheme.surfaceContainerHighest;
        textColor = scheme.onSurfaceVariant;
        if (dueDate != null && dueDate!.isAfter(DateTime.now())) {
          String dateStr = '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';
          text = 'DISPONÍVEL A PARTIR DE: $dateStr';
        } else {
          text = 'INDISPONÍVEL NO MOMENTO';
        }
        break;
    }

    return GestureDetector(
      // Sem sessão o botão leva ao login; com sessão, só clica quando a regra de
      // empréstimo permite.
      onTap: status == LoanStatus.guest
          ? onPressed
          : (isClickable ? onPressed : null),
      child: AnimatedContainer(
        duration: AppMotion.of(context, AppMotion.quick),
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(LumiLivreTheme.radiusControl),
          boxShadow: isClickable
              ? [
                  BoxShadow(
                    color: backgroundColor.withValues(alpha: 0.4),
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
        Text(label, style: TextStyle(color: Theme.of(context).hintColor)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
