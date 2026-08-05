import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/guest_access.dart';
import 'package:lumilivre/providers/settings.dart';
import 'package:lumilivre/screens/auth/login.dart';
import 'package:lumilivre/screens/likes_tab.dart';
import 'package:lumilivre/screens/loans_tab.dart';
import 'package:lumilivre/screens/ranking_tab.dart';
import 'package:lumilivre/screens/settings.dart';
import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  String? _readerName;
  String? _profileImageUrl;
  int _currentIndex = 0;
  bool _rankingEnabled = true;

  /// Sessão que o cabeçalho já carregou, para recarregar quando ela mudar.
  String? _loadedHeaderToken;

  int? _myRankPosition;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initTabController(length: 3);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Sessão nova com a tela já montada (convidado que entra pelo botão daqui):
    // o initState não roda de novo, então o cabeçalho ficaria em "Convidado"
    // mesmo já autenticado.
    final token = Provider.of<AuthProvider>(context).user?.token;
    if (token != _loadedHeaderToken) {
      _loadedHeaderToken = token;
      _readerName = null;
      _profileImageUrl = null;
      _myRankPosition = null;
      if (token != null) {
        _loadHeaderData();
      }
    }

    final rankingEnabled = Provider.of<SettingsProvider>(context).showRanking;

    if (_rankingEnabled == rankingEnabled) {
      return;
    }

    final newLength = rankingEnabled ? 3 : 2;
    final newIndex = _currentIndex >= newLength ? newLength - 1 : _currentIndex;

    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _rankingEnabled = rankingEnabled;
    _currentIndex = newIndex;
    _initTabController(length: newLength, initialIndex: newIndex);

    if (!rankingEnabled) {
      _myRankPosition = null;
    } else {
      _loadRankFromAuth();
    }
  }

  void _initTabController({required int length, int initialIndex = 0}) {
    _tabController = TabController(
      length: length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (mounted) {
      setState(() => _currentIndex = _tabController.index);
    }
  }

  void _loadHeaderData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated ||
        authProvider.user?.readerRegistrationNumber == null) {
      return;
    }

    final registrationNumber = authProvider.user!.readerRegistrationNumber!;
    final token = authProvider.user!.token;

    final data = await _apiService.getReaderData(registrationNumber, token);

    if (mounted && data != null) {
      setState(() {
        _readerName = data['nomeCompleto'];
        _profileImageUrl = data['foto'];
      });
    }

    if (!mounted) return;
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (settings.showRanking) {
      _fetchMyRank(registrationNumber, token);
    }
  }

  void _loadRankFromAuth() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final registrationNumber = authProvider.user?.readerRegistrationNumber;

    if (!authProvider.isAuthenticated || registrationNumber == null) {
      return;
    }

    _fetchMyRank(registrationNumber, authProvider.user!.token);
  }

  Future<void> _fetchMyRank(String registrationNumber, String token) async {
    try {
      final ranking = await _apiService.getRanking(token: token, top: 100);
      final index = ranking.indexWhere(
        (r) => r.registrationNumber == registrationNumber,
      );

      if (mounted) {
        setState(() {
          if (index != -1) {
            _myRankPosition = index + 1;
          }
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao buscar ranking: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (!settings.canEditAvatar) return;

    final ImagePicker picker = ImagePicker();
    final messenger = ScaffoldMessenger.of(context);
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (!mounted) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);

      messenger.showSnackBar(const SnackBar(content: Text('Enviando foto...')));

      Uint8List? bytes;
      if (kIsWeb) {
        bytes = await image.readAsBytes();
      }

      final success = await _apiService.uploadProfilePicture(
        auth.user!.readerRegistrationNumber!,
        auth.user!.token,
        image.path,
        webBytes: bytes,
      );

      if (success) {
        _loadHeaderData();
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Foto atualizada com sucesso!')),
          );
        }
      } else if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar foto.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  /// Abas do perfil numa lista só: legenda, ícone, convite do convidado e
  /// conteúdo andam juntos.
  ///
  /// Antes cada um desses quatro vinha de um lugar diferente — `tabs:` no
  /// `TabBar`, `children:` no `TabBarView` e três `Map<int, ...>` fixos com o
  /// texto do convidado. Bastava o ranking ser desligado pela biblioteca para os
  /// índices dos mapas apontarem para a aba errada, e a legenda de cada aba
  /// simplesmente não existia: as abas eram só ícone.
  List<_ProfileTab> _tabs(AppLocalizations l10n) => [
    _ProfileTab(
      caption: l10n.profileTabLoans,
      iconName: 'loans',
      guestIcon: Icons.book_outlined,
      guestTitle: l10n.guestLoansTitle,
      guestMessage: l10n.guestLoansMessage,
      body: const LoansTab(),
    ),
    _ProfileTab(
      caption: l10n.profileTabLikes,
      icon: Icons.favorite_border,
      activeIcon: Icons.favorite,
      guestIcon: Icons.favorite_border,
      guestTitle: l10n.guestLikesTitle,
      guestMessage: l10n.guestLikesMessage,
      body: const LikesTab(),
    ),
    if (_rankingEnabled)
      _ProfileTab(
        caption: l10n.profileTabRanking,
        iconName: 'ranking',
        guestIcon: Icons.emoji_events_outlined,
        guestTitle: l10n.guestRankingTitle,
        guestMessage: l10n.guestRankingMessage,
        body: const RankingScreen(),
      ),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    final access = GuestAccess.of(context);
    final theme = Theme.of(context);

    final tabs = _tabs(l10n);
    // O índice vem do controller, mas a aba pode ter deixado de existir no mesmo
    // frame (biblioteca desligou o ranking): a legenda segue o que está na tela.
    final selected = _currentIndex.clamp(0, tabs.length - 1);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        toolbarHeight: 140,
        elevation: 0,
        title: _buildProfileHeader(authProvider, access, l10n, theme),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: LumiLivreTheme.label,
          indicatorWeight: 4.0,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 0),
          indicatorSize: TabBarIndicatorSize.label,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (_) => Colors.transparent,
          ),
          tabs: [
            for (var index = 0; index < tabs.length; index++)
              _buildTab(tabs[index], isActive: index == selected),
          ],
        ),
      ),
      body: access.isGuest
          ? _buildGuestTabBody(tabs[selected], selected)
          : TabBarView(
              controller: _tabController,
              children: [for (final tab in tabs) tab.body],
            ),
    );
  }

  /// Aba com ícone **e** legenda: o rótulo é o que diz em que aba o usuário
  /// está e é o que o leitor de tela anuncia (ícone sozinho não anuncia nada).
  Tab _buildTab(_ProfileTab tab, {required bool isActive}) {
    final iconColor = Colors.white.withValues(alpha: isActive ? 1 : 0.75);

    return Tab(
      height: 62,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (tab.iconName != null)
              SvgPicture.asset(
                isActive
                    ? 'assets/icons/${tab.iconName}-active.svg'
                    : 'assets/icons/${tab.iconName}.svg',
                height: 26,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              )
            else
              Icon(
                isActive ? (tab.activeIcon ?? tab.icon) : tab.icon,
                color: iconColor,
                size: 26,
              ),
            const SizedBox(height: 4),
            Text(
              tab.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: iconColor,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestTabBody(_ProfileTab tab, int index) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _GuestEmptyState(
        key: ValueKey(index),
        icon: tab.guestIcon,
        title: tab.guestTitle,
        subtitle: tab.guestMessage,
        onLogin: _openLogin,
      ),
    );
  }

  /// Login empilhado sobre o perfil. Ao voltar autenticado, o próprio
  /// `didChangeDependencies` recarrega o cabeçalho.
  Future<void> _openLogin() {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  Widget _buildProfileHeader(
    AuthProvider authProvider,
    GuestAccess access,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    if (access.isGuest) {
      return _buildGuestHeader(l10n, theme);
    }

    String displayName =
        _readerName ??
        authProvider.user?.email.split('@')[0] ??
        l10n.readerTerm;
    String registrationNumber =
        authProvider.user?.readerRegistrationNumber ?? '---';
    String rankingText = _myRankPosition != null ? '#$_myRankPosition' : '--';
    final subtitle = _rankingEnabled
        ? '$registrationNumber - Ranking: $rankingText'
        : registrationNumber;

    final canEditAvatar = access.canEditAvatar;
    final hasPhoto = _profileImageUrl != null && _profileImageUrl!.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: canEditAvatar ? _pickAndUploadImage : null,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 1.0, end: 1.0),
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  backgroundImage: hasPhoto
                      ? CachedNetworkImageProvider(_profileImageUrl!)
                      : null,
                  child: !hasPhoto
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
              ),
            ),
            if (canEditAvatar)
              Positioned(
                right: -2,
                bottom: -2,
                child: GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayName,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        _HeaderAction(
          icon: Icons.settings_outlined,
          tooltip: l10n.settingsTitle,
          onPressed: _openSettings,
        ),
      ],
    );
  }

  Widget _buildGuestHeader(AppLocalizations l10n, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(10),
          child: const Icon(
            Icons.person_outline,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.guestName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        // Entrar e Configurações convivem: o convidado também troca tema e
        // idioma, e antes o botão de entrar tinha ocupado o lugar da engrenagem
        // — a tela de Configurações ficou inalcançável sem conta (o próprio
        // convite de login que mora lá dentro nunca aparecia).
        _HeaderAction(
          icon: Icons.login,
          tooltip: l10n.loginAction,
          onPressed: _openLogin,
        ),
        _HeaderAction(
          icon: Icons.settings_outlined,
          tooltip: l10n.settingsTitle,
          onPressed: _openSettings,
        ),
      ],
    );
  }

  Future<void> _openSettings() {
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SettingsScreen(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }
}

/// Ação do cabeçalho: só ícone, mas nunca sem rótulo.
///
/// `tooltip` no `IconButton` também vira o rótulo semântico, então o leitor de
/// tela anuncia "Entrar" em vez de "botão" — o botão de entrar do convidado não
/// tinha nenhum dos dois.
class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(left: 8),
      width: 40,
      height: 40,
      child: IconButton(
        padding: EdgeInsets.zero,
        tooltip: tooltip,
        icon: Icon(icon, color: Colors.white, size: 22),
        onPressed: onPressed,
      ),
    );
  }
}

/// Uma aba do perfil e tudo que ela precisa para se descrever.
@immutable
class _ProfileTab {
  const _ProfileTab({
    required this.caption,
    required this.guestIcon,
    required this.guestTitle,
    required this.guestMessage,
    required this.body,
    this.iconName,
    this.icon,
    this.activeIcon,
  });

  /// Legenda visível da aba (e rótulo para leitor de tela).
  final String caption;

  /// Nome do par de SVGs em `assets/icons/{nome}.svg` e `{nome}-active.svg`.
  final String? iconName;

  /// Alternativa para abas que usam ícone do Material em vez de SVG.
  final IconData? icon;
  final IconData? activeIcon;

  final IconData guestIcon;
  final String guestTitle;
  final String guestMessage;
  final Widget body;
}

class _GuestEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onLogin;

  const _GuestEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.8, end: 1.0),
              curve: Curves.easeOutBack,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: Icon(icon, size: 72, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onLogin,
              icon: const Icon(Icons.login, size: 18),
              label: Text(AppLocalizations.of(context)!.loginAction),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
