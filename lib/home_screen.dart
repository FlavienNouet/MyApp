import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart'
;
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
  int _currentIndex = 1;
  final List<Widget> _pages = [
    HistoryScreen(),
    HomeContent(),
    Center(child: Text('Tchat', style: TextStyle(color: Colors.white, fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Tchat'),
        ],
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// ==================== HISTORIQUE SCREEN ====================

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _videos = [];
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    final response = await http.get(Uri.parse('http://localhost:1234/video/getVideos'));
    if (response.statusCode == 200) {
      setState(() {
        _videos = json.decode(response.body);
      });
    } else {
      print('Erreur de chargement des vidéos');
    }
  }

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
    return Container(
      color: Colors.black,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: _videos.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredVideos().length,
                    itemBuilder: (context, index) {
                      var video = _filteredVideos()[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.black54, blurRadius: 4, spreadRadius: 2),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video['description'] ?? 'Description indisponible',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.date_range, color: Colors.white, size: 16),
                                SizedBox(width: 5),
                                Text(
                                  "Du ${video['dateDebut'] ?? 'N/A'} au ${video['dateFin'] ?? 'N/A'}",
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.white, size: 16),
                                SizedBox(width: 5),
                                Text(
                                  video['lieu'] ?? 'Lieu non spécifié',
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(Icons.event_seat, color: Colors.white, size: 16),
                                SizedBox(width: 5),
                                Text(
                                  "Places disponibles: ${video['nombrePlaces'] ?? 'N/A'}",
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
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
                  _searchText = text;
                });
              },
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ==================== HOME SCREEN CONTENT ====================

class HomeContent extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    // Supprimer le token de session
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Supprime le token enregistré

    // Rediriger vers la page de connexion
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
              backgroundImage: AssetImage('../assets/profile.jpg'),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.white54),
            ListTile(
              leading: Icon(Icons.person, color: Colors.white),
              title: Text('Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text('Déconnexion', style: TextStyle(color: Colors.white)),
              onTap: () {
                _logout(context); // Appeler la fonction de déconnexion
              },
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
                          Scaffold.of(context).openDrawer();
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage('../assets/profile.jpg'),
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
                      image: AssetImage('../assets/home.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('welcome', style: TextStyle(fontSize: 22, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}