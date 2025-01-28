import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page d\'accueil'),
      ),
      body: Center(
        child: Text(
          'Bienvenue dans votre espace personnel!',
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: 0, // Indice de l'élément sélectionné actuellement
        onTap: (int index) {
          // Gérer les clics sur les différents éléments ici
          // Par exemple, vous pouvez utiliser Navigator pour naviguer vers différentes pages
          // ou simplement mettre à jour l'état de votre application.
        },
      ),
    );
  }
}
