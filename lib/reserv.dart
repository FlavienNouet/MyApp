import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'historique.dart';
import 'confirmation.dart';

// Import des écrans
import 'main.dart'; // Assurez-vous d'importer votre écran principal
import 'profile.dart'; // Assurez-vous d'importer votre écran de profil

// Ecran de réservation
class ReservationScreen extends StatelessWidget {
  final dynamic video;

  ReservationScreen({required this.video});

  Future<void> bookSeance(int idUtilisateur, int idSeance) async {
    final url = Uri.parse('http://localhost:1234/user/bookSeance');
    
    // Requête POST pour réserver la séance
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id_utilisateur': idUtilisateur,
        'id_seance': idSeance,
      }),
    );

    if (response.statusCode == 200) {
      print('Séance réservée avec succès!');
    } else {
      print('Erreur lors de la réservation');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Remplacez ceci par l'ID de l'utilisateur
    int idUtilisateur = 1; // Exemple d'ID utilisateur
    int idSeance = video['id']; // L'ID de la séance

    return Scaffold(
      appBar: AppBar(
        title: Text('Réservation'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent], // Dégradé violet
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            width: 350,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,  // Boîte blanche
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Détails de la séance',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 20),
                // Description
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.description, color: Colors.deepPurple, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        video['description'] ?? 'Description indisponible',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                // Date de début et fin
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.date_range, color: Colors.deepPurple, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Du ${video['dateDebut']} au ${video['dateFin']}",
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                // Lieu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, color: Colors.deepPurple, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        video['lieu'] ?? 'Lieu non spécifié',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                // Nombre de places disponibles
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.event_seat, color: Colors.deepPurple, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Places disponibles: ${video['nombrePlaces'] ?? 'N/A'}",
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                // Bouton de réservation
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Confirmer la réservation et appeler la fonction bookSeance
                      await bookSeance(idUtilisateur, idSeance);

                      // Redirection vers la page de confirmation
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ConfirmationScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Confirmer la réservation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
