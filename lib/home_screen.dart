import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Import des écrans
import 'main.dart'; // Assurez-vous d'importer votre écran principal
import 'profile.dart'; // Assurez-vous d'importer votre écran de profil

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}

// Ecran Principal avec la navigation
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Index de la page actuellement affichée

  // Liste des pages à afficher dans la navigation
  final List<Widget> _pages = [
    HistoryScreen(), // Ecran d'historique
    HomeContent(), // Contenu de l'accueil
    Center(child: Text('Test', style: TextStyle(color: Colors.white, fontSize: 24))), // Exemple de page
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
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Réservation'),
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
              Text("Du ${video['dateDebut'] ?? 'N/A'} au ${video['dateFin'] ?? 'N/A'}", style: TextStyle(color: Colors.black, fontSize: 14)),
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

// Ecran d'accueil avec le menu latéral
class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // Fonction de déconnexion
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Supprime le token de session

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Redirection vers l'écran de connexion
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
              backgroundImage: AssetImage('../assets/profile.jpg'), // Image de profil
            ),
            SizedBox(height: 20),
            Divider(color: Colors.white54),
            ListTile(
              leading: Icon(Icons.person, color: Colors.white),
              title: Text('Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()), // Navigue vers l'écran de profil
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text('Déconnexion', style: TextStyle(color: Colors.white)),
              onTap: _logout, // Déconnexion
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(color: Colors.black),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            child: Column(
              children: [
                Row(
                  children: [
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer(); // Ouvre le menu latéral
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage('../assets/profile.jpg'), // Image de profil
                        ),
                      ),
                    ),
                    Spacer(),
                    Text('Dayliho', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                SizedBox(height: 50),
                Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage('../assets/home.jpg'), // Image de fond
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Bienvenue', style: TextStyle(fontSize: 22, color: Colors.white)), // Bouton d'accueil
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Ecran de réservation
class ReservationScreen extends StatelessWidget {
  final dynamic video;

  ReservationScreen({required this.video});

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {
                print('Réservation confirmée pour: ${video['description']}'); // Simule la réservation
              },
              child: Text('Confirmer la réservation'),
            ),
          ],
        ),
      ),
    );
  }
}
