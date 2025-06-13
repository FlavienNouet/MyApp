import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmationScreen extends StatefulWidget {
  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<dynamic> _bookedSeances = [];
  bool _isLoading = true;
  String? _errorMessage;

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
    _loadBookedSeances();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadBookedSeances() async {
    try {
      final seances = await fetchBookedSeances();
      setState(() {
        _bookedSeances = seances;
        _isLoading = false;
        _errorMessage = null;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _animationController.reset();
    await _loadBookedSeances();
  }

  // Fonction pour récupérer les séances réservées
  Future<List<dynamic>> fetchBookedSeances() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      if (userId == null) {
        throw Exception('Veuillez vous connecter pour voir vos réservations');
      }

      final response = await http.get(
        Uri.parse('http://localhost:1234/video/getBookedSeances/${userId.toString()}'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return []; // Pas de réservations trouvées
      } else {
        throw Exception('Erreur lors de la récupération des réservations');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('connection')) {
        throw Exception('Impossible de se connecter au serveur');
      }
      rethrow;
    }
  }

  // Fonction pour supprimer une réservation
  Future<void> _deleteReservation(int seanceId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final response = await http.delete(
        Uri.parse('http://localhost:1234/video/deleteReservation/$userId/$seanceId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Suppression réussie, actualiser la liste
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Réservation supprimée avec succès'),
              ],
            ),
            backgroundColor: Color(0xFF27AE60),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        
        // Recharger les données
        await _refreshData();
      } else {
        throw Exception('Erreur lors de la suppression de la réservation');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Erreur: ${e.toString().replaceAll('Exception: ', '')}'),
              ),
            ],
          ),
          backgroundColor: Color(0xFFE74C3C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // Fonction pour afficher la boîte de dialogue de confirmation
  Future<void> _showDeleteConfirmationDialog(dynamic seance) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF39C12),
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Confirmer la suppression',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Êtes-vous sûr de vouloir supprimer cette réservation ?',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6C757D),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(0xFFE9ECEF),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      seance['titre'] ?? 'Titre indisponible',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Lieu: ${seance['lieu'] ?? 'Non spécifié'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C757D),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Cette action est irréversible.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFE74C3C),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF6C757D),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Annuler',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteReservation(seance['id']);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE74C3C),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Supprimer',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Mes Réservations',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF2C3E50)),
            onPressed: _refreshData,
            tooltip: 'Actualiser',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Color(0xFFE9ECEF),
            height: 1.0,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_errorMessage != null) {
      return _buildErrorState();
    } else if (_bookedSeances.isEmpty) {
      return _buildEmptyState();
    } else {
      return _buildReservationsList();
    }
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
            'Chargement de vos réservations...',
            style: TextStyle(
              color: Color(0xFF6C757D),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFFFF2F2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_outline,
                size: 50,
                color: Color(0xFFE74C3C),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Oups ! Une erreur s\'est produite',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Erreur inconnue',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6C757D),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _refreshData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3498DB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Réessayer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.event_available,
                size: 60,
                color: Color(0xFF6C757D),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Aucune réservation',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Vous n\'avez pas encore réservé de séances.\nExplorez nos séances disponibles !',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6C757D),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationsList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // En-tête avec statistiques
          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF3498DB).withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.event_available,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_bookedSeances.length} réservation${_bookedSeances.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Vos séances réservées',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Liste des réservations
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: _bookedSeances.length,
              separatorBuilder: (context, index) => SizedBox(height: 15),
              itemBuilder: (context, index) {
                return ReservationItem(
                  seance: _bookedSeances[index],
                  index: index,
                  animationController: _animationController,
                  onDelete: () => _showDeleteConfirmationDialog(_bookedSeances[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ReservationItem extends StatelessWidget {
  final dynamic seance;
  final int index;
  final AnimationController animationController;
  final VoidCallback onDelete;

  ReservationItem({
    required this.seance,
    required this.index,
    required this.animationController,
    required this.onDelete,
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
          border: Border.all(color: Color(0xFF27AE60), width: 2),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF27AE60).withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec titre et badge de confirmation
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      seance['titre'] ?? 'Titre indisponible',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C3E50),
                        height: 1.3,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F5E8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color(0xFF27AE60),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Color(0xFF27AE60),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Réservé',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              
              // Description
              if (seance['description'] != null && seance['description'].toString().isNotEmpty)
                _buildInfoRow(
                  Icons.description_outlined,
                  seance['description'],
                  Color(0xFF6C757D),
                ),
              
              SizedBox(height: 12),
              
              // Informations organisées en grille
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoRow(
                            Icons.calendar_today_outlined,
                            "Du ${_formatDate(seance['dateDebut'])}",
                            Color(0xFF2C3E50),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: _buildInfoRow(
                            Icons.location_on_outlined,
                            seance['lieu'] ?? 'Lieu non spécifié',
                            Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoRow(
                            Icons.calendar_today_outlined,
                            "au ${_formatDate(seance['dateFin'])}",
                            Color(0xFF2C3E50),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: _buildInfoRow(
                            Icons.people_outline,
                            "${seance['nombrePlaces'] ?? 'N/A'} places",
                            Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showDetailsDialog(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF3498DB),
                        side: BorderSide(color: Color(0xFF3498DB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Détails',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE74C3C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_outline, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Supprimer',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
          size: 16,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              height: 1.4,
            ),
          ),
        ),
      ],
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

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF3498DB)),
              SizedBox(width: 8),
              Text('Détails de la séance'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                seance['titre'] ?? 'Titre indisponible',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(seance['description'] ?? 'Aucune description'),
              SizedBox(height: 12),
              Text('Lieu: ${seance['lieu'] ?? 'Non spécifié'}'),
              Text('Du: ${_formatDate(seance['dateDebut'])}'),
              Text('Au: ${_formatDate(seance['dateFin'])}'),
              Text('Places: ${seance['nombrePlaces'] ?? 'N/A'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}