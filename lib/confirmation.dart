import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'historique.dart';
import 'reserv.dart';// Import des écrans
import 'main.dart'; // Assurez-vous d'importer votre écran principal
import 'profile.dart';


class ConfirmationScreen extends StatefulWidget {
  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  List<dynamic> _bookedSeances = [];

  // Fonction pour récupérer les séances réservées
  Future<void> getBookedSeances(int idUtilisateur) async {
    final response = await http.get(
      Uri.parse('http://localhost:1234/user/getBookedSeances?id_utilisateur=$idUtilisateur'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _bookedSeances = json.decode(response.body); // Mise à jour des séances réservées
      });
    } else {
      print('Erreur de récupération des séances réservées');
    }
  }

  @override
  void initState() {
    super.initState();
    int idUtilisateur = 1; // Remplacez ceci par l'ID de l'utilisateur
    getBookedSeances(idUtilisateur); // Récupère les séances réservées à l'initialisation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation de Réservation'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: _bookedSeances.isEmpty
            ? CircularProgressIndicator()
            : ListView.builder(
                itemCount: _bookedSeances.length,
                itemBuilder: (context, index) {
                  var seance = _bookedSeances[index];
                  return ListTile(
                    title: Text(seance['description']),
                    subtitle: Text("Du ${seance['dateDebut']} au ${seance['dateFin']}"),
                  );
                },
              ),
      ),
    );
  }
}