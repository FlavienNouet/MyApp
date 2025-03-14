import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  final dynamic seance;

  DetailsScreen({required this.seance});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la Séance'),
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
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            // **Boîte blanche contenant toutes les informations**
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                  // **Titre de la séance**
                  Text(
                    seance['titre'] ?? 'Titre indisponible',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 16),

                  // **Description de la séance**
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.fitness_center, color: Colors.black, size: 16),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          seance['description'] ?? 'Description indisponible',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // **Date et heures de la séance**
                  Row(
                    children: [
                      Icon(Icons.date_range, color: Colors.black, size: 16),
                      SizedBox(width: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Du ${seance['dateDebut'] ?? 'N/A'}", style: TextStyle(color: Colors.black, fontSize: 16)),
                          Text("au ${seance['dateFin'] ?? 'N/A'}", style: TextStyle(color: Colors.black, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // **Lieu de la séance**
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.black, size: 16),
                      SizedBox(width: 5),
                      Text(
                        seance['lieu'] ?? 'Lieu non spécifié',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // **Nombre de places disponibles**
                  Row(
                    children: [
                      Icon(Icons.event_seat, color: Colors.black, size: 16),
                      SizedBox(width: 5),
                      Text(
                        "Places disponibles: ${seance['nombrePlaces'] ?? 'N/A'}",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
