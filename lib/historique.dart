import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'reserv.dart';
import 'main.dart';
import 'profile.dart';
import 'confirmation.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with TickerProviderStateMixin {
  List<dynamic> _videos = [];
  String _searchText = '';
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fetchVideos();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchVideos() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:1234/video/getVideos'));
      if (response.statusCode == 200) {
        setState(() {
          _videos = json.decode(response.body);
          _isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Erreur de chargement des séances');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Erreur de connexion');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  List<dynamic> _filteredVideos() {
    if (_searchText.isEmpty) {
      return _videos;
    } else {
      return _videos.where((video) =>
          video['description'].toString().toLowerCase().contains(_searchText.toLowerCase()) ||
          video['titre'].toString().toLowerCase().contains(_searchText.toLowerCase()) ||
          video['lieu'].toString().toLowerCase().contains(_searchText.toLowerCase())).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Séances Disponibles',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Color(0xFFE9ECEF),
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche moderne
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Color(0xFFE9ECEF), width: 1),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher par titre, description ou lieu...',
                  hintStyle: TextStyle(color: Color(0xFF6C757D), fontSize: 15),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF6C757D), size: 22),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                style: TextStyle(fontSize: 15, color: Color(0xFF2C3E50)),
                onChanged: (text) {
                  setState(() {
                    _searchText = text;
                  });
                },
              ),
            ),
          ),
          // Contenu principal
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _videos.isEmpty
                    ? _buildEmptyState()
                    : _buildVideosList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'Chargement des séances...',
            style: TextStyle(
              color: Color(0xFF6C757D),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Color(0xFFBDC3C7),
          ),
          SizedBox(height: 20),
          Text(
            'Aucune séance disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Revenez plus tard pour voir les nouvelles séances',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6C757D),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVideosList() {
    final filteredVideos = _filteredVideos();
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // En-tête avec compteur
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Text(
                  '${filteredVideos.length} séance${filteredVideos.length > 1 ? 's' : ''} trouvée${filteredVideos.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Color(0xFF6C757D),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Liste des vidéos
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: filteredVideos.length,
              separatorBuilder: (context, index) => SizedBox(height: 15),
              itemBuilder: (context, index) {
                var video = filteredVideos[index];
                return VideoItem(
                  video: video,
                  index: index,
                  animationController: _animationController,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VideoItem extends StatelessWidget {
  final dynamic video;
  final int index;
  final AnimationController animationController;

  VideoItem({
    required this.video,
    required this.index,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final animation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Interval((index * 0.1).clamp(0.0, 1.0), 1.0, curve: Curves.easeOut),
    ));

    return SlideTransition(
      position: animation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF000000).withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReservationScreen(video: video)),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec titre et statut
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          video['titre'] ?? 'Titre indisponible',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C3E50),
                            height: 1.3,
                          ),
                        ),
                      ),
                      _buildAvailabilityChip(),
                    ],
                  ),
                  SizedBox(height: 15),
                  
                  // Description
                  if (video['description'] != null && video['description'].toString().isNotEmpty)
                    _buildInfoRow(
                      Icons.description_outlined,
                      video['description'],
                      Color(0xFF6C757D),
                    ),
                  
                  SizedBox(height: 12),
                  
                  // Informations en colonnes
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.calendar_today_outlined,
                              "Du ${_formatDate(video['dateDebut'])}",
                              Color(0xFF2C3E50),
                            ),
                            SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.calendar_today_outlined,
                              "au ${_formatDate(video['dateFin'])}",
                              Color(0xFF2C3E50),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.location_on_outlined,
                              video['lieu'] ?? 'Lieu non spécifié',
                              Color(0xFF2C3E50),
                            ),
                            SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.people_outline,
                              "${video['nombrePlaces'] ?? 'N/A'} places",
                              Color(0xFF2C3E50),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Bouton de réservation
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ReservationScreen(video: video)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3498DB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Réserver cette séance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Color(0xFF6C757D),
          size: 18,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityChip() {
    final places = video['nombrePlaces'];
    bool isAvailable = places != null && places > 0;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAvailable ? Color(0xFFE8F5E8) : Color(0xFFFFF2F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAvailable ? Color(0xFF4CAF50) : Color(0xFFE57373),
          width: 1,
        ),
      ),
      child: Text(
        isAvailable ? 'Disponible' : 'Complet',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isAvailable ? Color(0xFF2E7D32) : Color(0xFFC62828),
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      DateTime parsedDate = DateTime.parse(date.toString());
      return "${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}";
    } catch (e) {
      return date.toString();
    }
  }
}