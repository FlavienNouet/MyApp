import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'reserv.dart';
// Import des écrans
import 'main.dart'; // Assurez-vous d'importer votre écran principal
import 'profile.dart'; 
import 'confirmation.dart';// Assurez-vous d'importer votre écran de profil


// Ecran d'Historique
class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _videos = []; // Liste des vidéos
  String _searchText = ''; // Texte de recherche

  @override
  void initState() {
    super.initState();
    _fetchVideos(); // Récupère les vidéos au démarrage
  }

  // Fonction pour récupérer les vidéos depuis l'API
  Future<void> _fetchVideos() async {
    final response = await http.get(Uri.parse('http://localhost:1234/video/getVideos'));
    if (response.statusCode == 200) {
      setState(() {
        _videos = json.decode(response.body); // Mise à jour des vidéos
      });
    } else {
      print('Erreur de chargement des vidéos');
    }
  }

  // Filtre les vidéos selon le texte de recherche
  List<dynamic> _filteredVideos() {
    if (_searchText.isEmpty) {
      return _videos;
    } else {
      return _videos.where((video) =>
          video['description'].toString().toLowerCase().contains(_searchText.toLowerCase())).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Historique', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false, // Désactive le bouton de retour automatique
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
        child: Column(
          children: [
            Expanded(
              child: _videos.isEmpty
                  ? Center(child: CircularProgressIndicator()) // Affiche un indicateur de chargement
                  : ListView.builder(
                      itemCount: _filteredVideos().length,
                      itemBuilder: (context, index) {
                        var video = _filteredVideos()[index];
                        return VideoItem(video: video); // Utilisation d'un widget séparé pour chaque vidéo
                      },
                    ),
            ),
            // Barre de recherche
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (text) {
                  setState(() {
                    _searchText = text; // Met à jour le texte de recherche
                  });
                },
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Widget pour afficher une vidéo dans la liste
class VideoItem extends StatelessWidget {
  final dynamic video;

  VideoItem({required this.video});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black),
        boxShadow: [
          BoxShadow(color: Colors.black54, blurRadius: 4, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            video['description'] ?? 'Description indisponible',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.date_range, color: Colors.black, size: 16),
              SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Du ${video['dateDebut'] ?? 'N/A'}", style: TextStyle(color: Colors.black, fontSize: 14)),
                  Text("au ${video['dateFin'] ?? 'N/A'}", style: TextStyle(color: Colors.black, fontSize: 14)),
                ],
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.black, size: 16),
              SizedBox(width: 5),
              Text(video['lieu'] ?? 'Lieu non spécifié', style: TextStyle(color: Colors.black, fontSize: 14)),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.event_seat, color: Colors.black, size: 16),
              SizedBox(width: 5),
              Text("Places disponibles: ${video['nombrePlaces'] ?? 'N/A'}", style: TextStyle(color: Colors.black, fontSize: 14)),
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReservationScreen(video: video)), // Redirection vers l'écran de réservation
              );
            },
            child: Text('Réserver'),
          ),
        ],
      ),
    );
  }
}