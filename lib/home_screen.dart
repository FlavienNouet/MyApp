import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'historique.dart';
import 'reserv.dart';
import 'main.dart';
import 'profile.dart';
import 'confirmation.dart';
import 'détails.dart';

// Couleurs et thème professionnel
class AppColors {
  static const Color primary = Color(0xFF2C3E50);
  static const Color secondary = Color(0xFF3498DB);
  static const Color accent = Color(0xFF1ABC9C);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.blue,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;

  final List<Widget> _pages = [
    HistoryScreen(),
    HomeContent(),
    ConfirmationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.secondary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 0 ? AppColors.secondary.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.history_rounded),
              ),
              label: 'Séances',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 1 ? AppColors.secondary.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.home_rounded),
              ),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 2 ? AppColors.secondary.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.bookmark_rounded),
              ),
              label: 'Réservations',
            ),
          ],
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class ReservationItem extends StatelessWidget {
  final dynamic seance;

  ReservationItem({required this.seance});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header avec gradient overlay
            Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Placeholder pour l'image de la séance
                  Container(
                    width: double.infinity,
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      size: 60,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Réservé',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenu de la carte
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seance['titre'] ?? 'Titre indisponible',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  
                  // Informations complémentaires
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        seance['lieu'] ?? 'En ligne',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Bouton d'action
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(seance: seance),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Voir les détails',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late List<dynamic> seances = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSeances();
  }

  Future<void> fetchSeances() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      if (userId == null) {
        throw Exception('Utilisateur non trouvé');
      }

      final response = await http.get(
        Uri.parse('http://localhost:1234/video/getBookedSeances/$userId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          seances = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Échec de la récupération des séances');
      }
    } catch (e) {
      print('Erreur : $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: Column(
          children: [
            // Header du drawer
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundImage: AssetImage('assets/profile.jpg'),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Mon Compte',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.person_rounded,
                    title: 'Profil',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreen()),
                      );
                    },
                  ),
                  Divider(height: 32),
                  _buildDrawerItem(
                    icon: Icons.logout_rounded,
                    title: 'Déconnexion',
                    onTap: _logout,
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header personnalisé
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage: AssetImage('assets/profile.jpg'),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Dayliho',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenu principal
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carte de bienvenue
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.secondary, AppColors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenue !',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Découvrez vos séances réservées',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Section des séances
                    Row(
                      children: [
                        Text(
                          'Mes Séances',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Spacer(),
                        if (seances.isNotEmpty)
                          Text(
                            '${seances.length} séance${seances.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Liste des séances
                    if (isLoading)
                      Center(
                        child: Column(
                          children: [
                            SizedBox(height: 40),
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Chargement des séances...',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (seances.isEmpty)
                      _buildEmptyState()
                    else
                      Container(
                        height: 320,
                        child: PageView.builder(
                          itemCount: seances.length,
                          controller: PageController(viewportFraction: 0.85),
                          itemBuilder: (context, index) {
                            return ReservationItem(seance: seances[index]);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Aucune séance réservée',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Explorez nos séances disponibles pour commencer votre parcours',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}