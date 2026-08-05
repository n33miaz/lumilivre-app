import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/models/loan.dart';
import 'package:lumilivre/models/loan_status_code.dart';
import 'package:lumilivre/models/paged_result.dart';
import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/utils/incremental_pager.dart';
import 'package:lumilivre/widgets/loan_card.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/utils/constants.dart';

class LoansTab extends StatefulWidget {
  const LoansTab({super.key});

  @override
  State<LoansTab> createState() => _LoansTabState();
}

class _LoansTabState extends State<LoansTab> {
  /// Distância do fim da lista em que a próxima página é pedida — cerca de três
  /// cartões. Antecipar é o que evita o rodapé de carregando aparecer no meio da
  /// leitura; o pager cuida de não pedir duas vezes a mesma página.
  static const double _historyPrefetch = 420.0;

  final ApiService _apiService = ApiService();

  bool _isLoadingActive = true;
  List<Loan> _inProgress = [];
  List<Loan> _closedRequests = [];

  /// Só existe depois de a aba "Histórico" aparecer pela primeira vez.
  IncrementalPager<Loan>? _historyPager;
  final ScrollController _historyController = ScrollController();

  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _historyController.addListener(_onHistoryScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActive();
    });
  }

  @override
  void dispose() {
    _historyController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// Matrícula e token da sessão, ou `null` quando não há leitor identificado.
  ({String matricula, String token})? _session() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final matricula = auth.user?.readerRegistrationNumber;
    final token = auth.sessionToken;

    if (matricula == null || token == null || token.isEmpty) {
      return null;
    }
    return (matricula: matricula, token: token);
  }

  /// Carrega "Em Andamento": empréstimos ativos + solicitações.
  ///
  /// O histórico saiu daqui. Ele era buscado no mesmo `Future.wait`, ou seja:
  /// todo leitor pagava o histórico completo ao abrir o perfil, inclusive quem
  /// nunca toca na segunda aba.
  Future<void> _loadActive() async {
    final session = _session();
    if (session == null) {
      if (mounted) {
        setState(() => _isLoadingActive = false);
      }
      return;
    }

    setState(() => _isLoadingActive = true);

    try {
      final results = await Future.wait([
        _apiService.getMyLoans(session.matricula, session.token),
        _apiService.getMyRequests(session.matricula, session.token),
      ]);

      // A separação em si mora no `LoanBuckets`: era aqui que o filtro comparava
      // o status com `PENDENTE` e, como a API manda `PENDING`, a solicitação
      // recém-enviada não entrava em nenhuma das duas listas.
      final buckets = LoanBuckets.split(
        activeLoans: results[0],
        requests: results[1],
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _inProgress = buckets.inProgress;
        _closedRequests = buckets.closedRequests;
        _isLoadingActive = false;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao carregar empréstimos: $e');
      }
      if (mounted) {
        setState(() => _isLoadingActive = false);
      }
    }
  }

  /// Monta o pager do histórico na primeira vez que a aba aparece.
  Future<void> _ensureHistory() {
    if (_historyPager != null) {
      return Future<void>.value();
    }

    final session = _session();
    if (session == null) {
      return Future<void>.value();
    }

    final pages = _HistoryPages(
      load: () =>
          _apiService.getMyLoansHistory(session.matricula, session.token),
    );
    _historyPager = IncrementalPager<Loan>(
      fetchPage: pages.page,
      keyOf: (loan) => loan.id,
    );

    return _loadMoreHistory();
  }

  Future<void> _loadMoreHistory() {
    final pager = _historyPager;
    if (pager == null || !pager.canLoadMore) {
      return Future<void>.value();
    }
    return _track(pager.loadMore());
  }

  Future<void> _retryHistory() {
    final pager = _historyPager;
    if (pager == null) {
      return Future<void>.value();
    }
    return _track(pager.retry());
  }

  /// Redesenha ao começar e ao terminar. O estado da paginação vive no pager; o
  /// `setState` só avisa o rodapé da lista que algo mudou.
  Future<void> _track(Future<void> loading) async {
    setState(() {});
    await loading;
    if (!mounted) {
      return;
    }
    setState(() {});
    // Uma página curta pode deixar o fim da lista ainda dentro do limiar. Sem
    // reavaliar depois do layout, a paginação só continuaria no próximo gesto.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _onHistoryScroll();
      }
    });
  }

  /// Recarrega as duas abas. As solicitações recusadas aparecem no histórico mas
  /// vêm da chamada da primeira aba, então atualizar uma exige atualizar a outra.
  Future<void> _refreshAll() async {
    setState(() => _historyPager = null);
    await _loadActive();
    if (mounted && _currentIndex == 1) {
      await _ensureHistory();
    }
  }

  void _onHistoryScroll() {
    if (!_historyController.hasClients) {
      return;
    }
    final position = _historyController.position;
    if (position.maxScrollExtent - position.pixels <= _historyPrefetch) {
      _loadMoreHistory();
    }
  }

  void _onTabChanged(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _handleIndex(index);
  }

  void _handleIndex(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
    if (index == 1) {
      _ensureHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = (constraints.maxWidth - 32) / 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: _currentIndex == 0
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      width: tabWidth,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _FilterButton(
                          label: 'Em Andamento',
                          isSelected: _currentIndex == 0,
                          onTap: () => _onTabChanged(0),
                        ),
                      ),
                      Expanded(
                        child: _FilterButton(
                          label: 'Histórico',
                          isSelected: _currentIndex == 1,
                          onTap: () => _onTabChanged(1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),

        // Cada aba cuida do próprio carregamento: antes um só indicador cobria as
        // duas, então a segunda aba não podia nem existir antes da primeira.
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: _handleIndex,
            children: [_buildInProgress(), _buildHistory()],
          ),
        ),
      ],
    );
  }

  Widget _buildInProgress() {
    if (_isLoadingActive) {
      return const Center(child: CircularProgressIndicator());
    }
    return _LoansListSimple(
      loans: _inProgress,
      isHistory: false,
      onRetry: _loadActive,
    );
  }

  Widget _buildHistory() {
    final pager = _historyPager;
    final closed = _closedRequests;

    // Sem pager a aba ainda não foi aberta (nada foi buscado, que é o ponto) ou
    // não há sessão. O indicador só vale enquanto a sessão está sendo resolvida.
    if (pager == null) {
      return _isLoadingActive
          ? const Center(child: CircularProgressIndicator())
          : _LoansListSimple(
              loans: const [],
              isHistory: true,
              onRetry: _refreshAll,
            );
    }

    final loaded = pager.items;
    final isEmpty = closed.isEmpty && loaded.isEmpty;

    if (isEmpty && pager.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // Lista vazia por falha é diferente de lista vazia por não ter histórico, e a
    // grade de categoria já mostrava as duas com o mesmo texto.
    if (isEmpty && pager.failed) {
      return _HistoryFailure(onRetry: _retryHistory);
    }
    if (isEmpty) {
      return _LoansListSimple(
        loans: const [],
        isHistory: true,
        onRetry: _refreshAll,
      );
    }

    final footerSlots = pager.hasFooter ? 1 : 0;

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView.builder(
        controller: _historyController,
        padding: const EdgeInsets.only(bottom: 20, top: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: closed.length + loaded.length + footerSlots,
        itemBuilder: (context, index) {
          if (index < closed.length) {
            return LoanCard(loan: closed[index], isRequest: true);
          }

          final loanIndex = index - closed.length;
          if (loanIndex < loaded.length) {
            return LoanCard(loan: loaded[loanIndex]);
          }

          return _HistoryFooter(failed: pager.failed, onRetry: _retryHistory);
        },
      ),
    );
  }
}

/// Fonte de páginas do histórico.
///
/// `GET /api/loans/reader/{matricula}/history` devolve `List<LoanResponse>` sem
/// `Pageable`, e não há rota paginada de histórico para o leitor: a única de
/// empréstimo que aceita `Pageable` é `GET /api/loans/advanced`, restrita a
/// ADMIN/LIBRARIAN. Logo a rede é chamada **uma** vez e as páginas seguintes são
/// cortes do que já veio — o que a API oferece hoje.
///
/// O ganho que sobra é o que a tela sofria de fato: o histórico não é mais
/// buscado junto com "Em Andamento", e entra em blocos conforme rola em vez de
/// virar um `ListView` dimensionado sobre anos de empréstimo de uma vez.
class _HistoryPages {
  _HistoryPages({required this.load});

  /// Cartões por bloco. Quinze cobre com folga a altura de qualquer tela sem
  /// mandar a lista inteira para o `ListView` de uma vez.
  static const int _pageSize = 15;

  final Future<List<Loan>> Function() load;

  /// Resposta única da API. Fica `null` quando a busca falha, para a nova
  /// tentativa realmente ir à rede em vez de repetir uma lista que não existe.
  List<Loan>? _all;

  Future<PagedResult<Loan>> page(int page) async {
    final all = _all ??= await load();

    final start = page * _pageSize;
    if (start >= all.length) {
      return PagedResult<Loan>.empty(page: page);
    }

    final end = start + _pageSize < all.length ? start + _pageSize : all.length;
    return PagedResult<Loan>(
      items: all.sublist(start, end),
      page: page,
      isLast: end >= all.length,
    );
  }
}

/// Rodapé da lista paginada: carregando, ou falhou e oferece nova tentativa.
class _HistoryFooter extends StatelessWidget {
  const _HistoryFooter({required this.failed, required this.onRetry});

  final bool failed;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (!failed) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final l10n = AppLocalizations.of(context)!;

    // Falhar a próxima página não apaga as anteriores: o aviso é um rodapé, não
    // um estado de tela.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          Text(
            l10n.loadMoreError,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(l10n.retryAction),
          ),
        ],
      ),
    );
  }
}

/// Histórico que não conseguiu carregar nem a primeira página.
class _HistoryFailure extends StatelessWidget {
  const _HistoryFailure({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_outlined,
              size: 56,
              color: theme.hintColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.connectionErrorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.hintColor),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retryAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoansListSimple extends StatelessWidget {
  final List<Loan> loans;
  final bool isHistory;
  final Future<void> Function() onRetry;

  const _LoansListSimple({
    required this.loans,
    required this.isHistory,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (loans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isHistory ? Icons.history : Icons.book_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isHistory
                  ? 'Nenhum histórico encontrado.'
                  : 'Nenhum empréstimo ou solicitação ativa.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            TextButton(onPressed: onRetry, child: const Text('Atualizar')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRetry,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20, top: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: loans.length,
        itemBuilder: (context, index) {
          final loan = loans[index];
          return LoanCard(loan: loan, isRequest: loan.isRequest);
        },
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? LumiLivreTheme.primary : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
