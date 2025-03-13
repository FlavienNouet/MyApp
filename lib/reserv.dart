import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'confirmation.dart';

class ReservationScreen extends StatelessWidget {
  final dynamic video;

  ReservationScreen({required this.video});

  Future<void> bookSeance(int userId, int seanceId, BuildContext context) async {
    final url = Uri.parse('http://localhost:1234/video/bookSeance/$userId/$seanceId');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // 🔹 Stocke seanceId avec SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('seanceId', seanceId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Séance réservée avec succès !')),
        );

        // 🔹 Navigue vers ConfirmationScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ConfirmationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la réservation : ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de se connecter au serveur. Vérifiez votre connexion.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int idUtilisateur = 1; // Remplace avec l'ID utilisateur réel
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
                      await bookSeance(idUtilisateur, idSeance, context);
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
