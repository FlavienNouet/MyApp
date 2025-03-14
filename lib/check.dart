import 'package:flutter/material.dart';
import 'home_screen.dart';

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
                  MaterialPageRoute(builder: (context) => HomeScreen()), // Assurez-vous que HomeScreen est correctement défini
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
