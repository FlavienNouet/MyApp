import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmationScreen extends StatefulWidget {
  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  // Fonction pour récupérer les séances réservées
  Future<List<dynamic>> fetchBookedSeances() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('ID utilisateur introuvable');
      }

      final response = await http.get(
        Uri.parse('http://localhost:1234/video/getBookedSeances/$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des séances');
      }
    } catch (e) {
      throw Exception('Impossible de se connecter au serveur');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Réservations'),
        backgroundColor: Colors.deepPurple, // Utilisation d'une couleur cohérente avec HistoryScreen
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
        child: FutureBuilder<List<dynamic>>(
          future: fetchBookedSeances(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); // Affichage du loader en attendant les données
            } else if (snapshot.hasError) {
              return Center(child: Text("Erreur : ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("Aucune séance réservée"));
            }

            var seances = snapshot.data!;
            return ListView.builder(
              itemCount: seances.length,
              itemBuilder: (context, index) {
                var seance = seances[index];
                return ReservationItem(seance: seance); // Appel à un widget personnalisé pour chaque réservation
              },
            );
          },
        ),
      ),
    );
  }
}

// Widget pour afficher une réservation dans la liste
class ReservationItem extends StatelessWidget {
  final dynamic seance;

  ReservationItem({required this.seance});

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
            seance['description'] ?? 'Description indisponible',
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
                  Text("Du ${seance['dateDebut'] ?? 'N/A'}", style: TextStyle(color: Colors.black, fontSize: 14)),
                  Text("au ${seance['dateFin'] ?? 'N/A'}", style: TextStyle(color: Colors.black, fontSize: 14)),
                ],
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.black, size: 16),
              SizedBox(width: 5),
              Text(seance['lieu'] ?? 'Lieu non spécifié', style: TextStyle(color: Colors.black, fontSize: 14)),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.event_seat, color: Colors.black, size: 16),
              SizedBox(width: 5),
              Text("Places disponibles: ${seance['nombrePlaces'] ?? 'N/A'}", style: TextStyle(color: Colors.black, fontSize: 14)),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
