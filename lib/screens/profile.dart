import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/screens/settings.dart';
import 'package:lumilivre/screens/ranking_tab.dart';
import 'package:lumilivre/screens/loans_tab.dart';
import 'package:lumilivre/screens/likes_tab.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  String? _studentName;
  String? _profileImageUrl;
  int _currentIndex = 0;

  int? _myRankPosition;
  // ignore: unused_field
  int? _totalStudents;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });

    _loadHeaderData();
  }

  void _loadHeaderData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated &&
        authProvider.user?.matriculaAluno != null) {
      final matricula = authProvider.user!.matriculaAluno!;
      final token = authProvider.user!.token;

      final data = await _apiService.getStudentData(matricula, token);

      if (mounted && data != null) {
        setState(() {
          _studentName = data['nomeCompleto'];
          _profileImageUrl = data['foto'];
        });
      }

      _fetchMyRank(matricula, token);
    }
  }

  Future<void> _fetchMyRank(String matricula, String token) async {
    try {
      final ranking = await _apiService.getRanking(token: token, top: 100);
      final index = ranking.indexWhere((r) => r.matricula == matricula);

      if (mounted) {
        setState(() {
          _totalStudents = ranking.length;
          if (index != -1) {
            _myRankPosition = index + 1;
          }
        });
      }
    } catch (e) {
      debugPrint('Erro ao buscar ranking: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final messenger = ScaffoldMessenger.of(context);
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (!mounted) { return; }
      final auth = Provider.of<AuthProvider>(context, listen: false);

      messenger.showSnackBar(const SnackBar(content: Text('Enviando foto...')));

      Uint8List? bytes;
      if (kIsWeb) {
        bytes = await image.readAsBytes();
      }

      final success = await _apiService.uploadProfilePicture(
        auth.user!.matriculaAluno!,
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
      } else {
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Erro ao atualizar foto.')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        toolbarHeight: 140, // Altura ajustada
        elevation: 0,
        title: _buildProfileHeader(authProvider, theme),
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
            Tab(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SvgPicture.asset(
                  _currentIndex == 0
                      ? 'assets/icons/loans-active.svg'
                      : 'assets/icons/loans.svg',
                  height: 28,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            Tab(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Icon(
                  _currentIndex == 1 ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            Tab(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SvgPicture.asset(
                  _currentIndex == 2
                      ? 'assets/icons/ranking-active.svg'
                      : 'assets/icons/ranking.svg',
                  height: 28,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [const LoansTab(), const LikesTab(), const RankingScreen()],
      ),
    );
  }

  Widget _buildProfileHeader(AuthProvider authProvider, ThemeData theme) {
    String displayName =
        _studentName ?? authProvider.user?.email.split('@')[0] ?? 'Aluno';
    String matricula = authProvider.user?.matriculaAluno ?? '---';
    String rankingText = _myRankPosition != null ? '#$_myRankPosition' : '--';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: _pickAndUploadImage,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : null,
                child: _profileImageUrl == null
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
            ),
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
                  child: const Icon(Icons.edit, size: 10, color: Colors.white),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 16),

        // TEXTOS
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nome menor
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
                '$matricula - Ranking: $rankingText',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.only(left: 8),
          width: 40,
          height: 40,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const SettingsScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;
                        final tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
