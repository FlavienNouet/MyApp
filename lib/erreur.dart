import 'package:flutter/material.dart';
import 'home_screen.dart'; // Importez votre fichier home-screen.dart si nécessaire

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
                  MaterialPageRoute(builder: (context) => HomeScreen()), // Vérifiez que HomeScreen est correctement défini
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
