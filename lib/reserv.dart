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
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${video['description']}'),
            SizedBox(height: 10),
            Text('Date: Du ${video['dateDebut']} au ${video['dateFin']}'),
            SizedBox(height: 10),
            Text('Lieu: ${video['lieu']}'),
            SizedBox(height: 10),
            Text('Places disponibles: ${video['nombrePlaces']}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Confirmer la réservation et appeler la fonction bookSeance
                await bookSeance(idUtilisateur, idSeance);

                // Redirection vers la page de confirmation
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConfirmationScreen()),
                );
              },
              child: Text('Confirmer la réservation'),
            ),
          ],
        ),
      ),
    );
  }
}