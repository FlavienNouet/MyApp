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
    int? userId = prefs.getInt('userId'); // Récupérer comme int
    return userId; // Retourne un int? potentiellement nul
  }

  Future<void> bookSeance(int userId, int seanceId, BuildContext context) async {
  final url = Uri.parse('http://10.0.2.2:1234/video/bookSeance/$userId/$seanceId');

  try {
    print("🔹 Tentative de réservation pour user:$userId, séance:$seanceId");
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    print("🔹 Réponse du serveur - Status: ${response.statusCode}, Body: ${response.body}");

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      if (responseData['success'] == true) { // Adaptez selon votre API
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
      appBar: AppBar(
        title: Text('Réservation'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            width: 350,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 2)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Détails de la séance',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                SizedBox(height: 20),
                buildDetailRow(Icons.description, video['description'] ?? 'Description indisponible'),
                buildDetailRow(Icons.date_range, "Du ${video['dateDebut']} au ${video['dateFin']}"),
                buildDetailRow(Icons.location_on, video['lieu'] ?? 'Lieu non spécifié'),
                buildDetailRow(Icons.event_seat, "Places disponibles: ${video['nombrePlaces'] ?? 'N/A'}"),
                SizedBox(height: 25),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      int? idUtilisateur = await getUserId();
                      if (idUtilisateur != null) {
                        await bookSeance(idUtilisateur, idSeance, context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur : utilisateur non identifié')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      'Confirmer la réservation',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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

  Widget buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepPurple, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

// Page en cas d'erreur de réservation
class ErreurPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red, // Fond rouge
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Séance déjà réservée', // Message en blanc
              style: TextStyle(
                color: Colors.white, // Couleur du texte en blanc
                fontSize: 24, // Taille du texte
                fontWeight: FontWeight.bold, // Texte en gras
              ),
            ),
            SizedBox(height: 30), // Espacement entre le texte et le bouton
            ElevatedButton(
              onPressed: () {
                // Retour à la page d'accueil
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()), // Retour à l'accueil
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                'Retour à l\'accueil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red, // Couleur du texte du bouton
                ),
              ),
            ),
          ],
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
      backgroundColor: Colors.green, // Fond vert
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Séance réservée avec succès', // Message en blanc
              style: TextStyle(
                color: Colors.white, // Couleur du texte
                fontSize: 24, // Taille du texte
                fontWeight: FontWeight.bold, // Gras
              ),
            ),
            SizedBox(height: 30), // Espacement entre le texte et le bouton
            ElevatedButton(
              onPressed: () {
                // Retour à la page d'accueil
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()), // Retour à l'accueil
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                'Retour à l\'accueil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // Couleur du texte du bouton
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
