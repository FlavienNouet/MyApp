import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}


class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _videos = [];

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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.all(16),
      child: _videos.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: (_videos.length / 2).ceil(), // Nombre de lignes nécessaires
              itemBuilder: (context, index) {
                int startIndex = index * 2;
                int endIndex = startIndex + 2;
                if (endIndex > _videos.length) endIndex = _videos.length;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _videos.sublist(startIndex, endIndex).map((video) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.all(8),
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
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}




class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dayliho',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('../assets/profile.jpg'),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  'START',
                  style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
