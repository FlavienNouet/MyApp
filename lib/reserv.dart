import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'confirmation.dart';
import 'home_screen.dart';

class ReservationScreen extends StatelessWidget {
  final dynamic video;

  ReservationScreen({required this.video});

  Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    return userId;
  }

  Future<void> bookSeance(int userId, int seanceId, BuildContext context) async {
    final url = Uri.parse('http://localhost:1234/video/bookSeance/$userId/$seanceId');

    try {
      print("🔹 Tentative de réservation pour user:$userId, séance:$seanceId");
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print("🔹 Réponse du serveur - Status: ${response.statusCode}, Body: ${response.body}");

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          print("✅ Réservation confirmée");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CheckPage()),
          );
        } else {
          throw Exception(responseData['message'] ?? "Échec de la réservation");
        }
      } else {
        throw Exception("Erreur HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("🚨 Erreur: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ErreurPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int idSeance = video['id'];

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Réservation',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF2D3748),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.event_seat,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Détails de la séance',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Vérifiez les informations avant de confirmer',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Details Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  buildModernDetailRow(
                    Icons.description_outlined,
                    'Description',
                    video['description'] ?? 'Description indisponible',
                    Color(0xFF4F46E5),
                  ),
                  Divider(height: 32, color: Colors.grey.withOpacity(0.2)),
                  buildModernDetailRow(
                    Icons.calendar_today_outlined,
                    'Période',
                    "Du ${video['dateDebut']} au ${video['dateFin']}",
                    Color(0xFF059669),
                  ),
                  Divider(height: 32, color: Colors.grey.withOpacity(0.2)),
                  buildModernDetailRow(
                    Icons.location_on_outlined,
                    'Lieu',
                    video['lieu'] ?? 'Lieu non spécifié',
                    Color(0xFFDC2626),
                  ),
                  Divider(height: 32, color: Colors.grey.withOpacity(0.2)),
                  buildModernDetailRow(
                    Icons.people_outline,
                    'Places disponibles',
                    "${video['nombrePlaces'] ?? 'N/A'}",
                    Color(0xFFD97706),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32),
            
            // Confirmation Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF667EEA).withOpacity(0.4),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  int? idUtilisateur = await getUserId();
                  if (idUtilisateur != null) {
                    await bookSeance(idUtilisateur, idSeance, context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur : utilisateur non identifié'),
                        backgroundColor: Color(0xFFDC2626),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Confirmer la réservation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Security notice
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFF0EA5E9).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF0EA5E9),
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Votre réservation sera confirmée instantanément',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF0369A1),
                        fontWeight: FontWeight.w500,
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

  Widget buildModernDetailRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Page en cas d'erreur de réservation
class ErreurPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error Icon
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Color(0xFFDC2626).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: Color(0xFFDC2626),
                    size: 64,
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Error Message
                Text(
                  'Oops !',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                
                SizedBox(height: 12),
                
                Text(
                  'Séance déjà réservée',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626),
                  ),
                ),
                
                SizedBox(height: 16),
                
                Text(
                  'Cette séance a déjà été réservée par un autre utilisateur. Veuillez choisir une autre séance.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                
                SizedBox(height: 48),
                
                // Return Button
                Container(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFDC2626),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Retour à l\'accueil',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Page en cas de succès de la réservation
class CheckPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Animation Container
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Color(0xFF059669).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF059669),
                    size: 64,
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Success Message
                Text(
                  'Parfait !',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                
                SizedBox(height: 12),
                
                Text(
                  'Séance réservée avec succès',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF059669),
                  ),
                ),
                
                SizedBox(height: 16),
                
                Text(
                  'Votre réservation a été confirmée. Vous recevrez bientôt un email de confirmation avec tous les détails.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                
                SizedBox(height: 48),
                
                // Return Button
                Container(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF059669),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Retour à l\'accueil',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
            
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}