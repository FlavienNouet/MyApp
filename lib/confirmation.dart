import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmationScreen extends StatefulWidget {
  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
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
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchBookedSeances(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
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
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(seance['description']),
                  subtitle: Text("Du ${seance['dateDebut']} au ${seance['dateFin']}"),
                  leading: Icon(Icons.fitness_center, color: Colors.deepPurple),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
