import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'historique.dart';
import 'reserv.dart'; // Import des écrans
import 'main.dart'; // Assurez-vous d'importer votre écran principal
import 'profile.dart'; // Assurez-vous d'importer votre écran de profil
import 'confirmation.dart';
import 'détails.dart';

// Ecran Principal avec la navigation
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Index de la page actuellement affichée

  // Liste des pages à afficher dans la navigation
  final List<Widget> _pages = [
    HistoryScreen(),
    HomeContent(),
    ConfirmationScreen(), // Ajout de la page confirmation ici
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Affiche la page correspondant à l'index courant
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Séances'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Mes Réservations'),
        ],
        currentIndex: _currentIndex, // Index actuel dans la barre de navigation
        onTap: (int index) {
          setState(() {
            _currentIndex = index; // Met à jour l'index lorsqu'un élément est sélectionné
          });
        },
      ),
    );
  }
}

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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // **Titre en haut**
            Text(
              seance['titre'] ?? 'Titre indisponible',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 8),

            // **Bouton Voir le détail**
            ElevatedButton(
              onPressed: () {
                // Navigation vers la page de détails en passant les données de la séance
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsScreen(seance: seance),
                  ),
                );
              },
              child: Text("Voir le détail"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late List<dynamic> seances = []; // Liste des séances

  @override
  void initState() {
    super.initState();
    fetchSeances();
  }

  Future<void> fetchSeances() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId'); // Récupération de l'ID utilisateur en tant qu'entier

      if (userId == null) {
        throw Exception('Utilisateur non trouvé');
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:1234/video/getBookedSeances/$userId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          seances = jsonDecode(response.body);
        });
      } else {
        throw Exception('Échec de la récupération des séances');
      }
    } catch (e) {
      print('Erreur : $e');
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');  // Enlever aussi l'ID de l'utilisateur

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.grey[850],
        child: Column(
          children: [
            SizedBox(height: 50),
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.white54),
            ListTile(
              leading: Icon(Icons.person, color: Colors.white),
              title: Text('Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text('Déconnexion', style: TextStyle(color: Colors.white)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Column(
                children: [
                  Row(
                    children: [
                      Builder(
                        builder: (context) => GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('assets/profile.jpg'),
                          ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Dayliho',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  Container(
                    width: 300,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage('assets/home.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Bienvenue', style: TextStyle(fontSize: 22, color: Colors.white)),
                  ),
                  SizedBox(height: 20),

                  // **CARROUSEL DES SÉANCES**
                  Expanded(
                    child: seances.isEmpty
                        ? Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : PageView.builder(
                            itemCount: seances.length,
                            controller: PageController(viewportFraction: 0.85),
                            itemBuilder: (context, index) {
                              return AnimatedBuilder(
                                animation: PageController(viewportFraction: 0.85),
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 0.9, // Effet de zoom
                                    child: ReservationItem(seance: seances[index]),
                                  );
                                },
                              );
                            },
                          ),
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
