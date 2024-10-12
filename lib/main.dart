import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pages/top_anime_page.dart';
import 'pages/anime_detail_page.dart';
import 'pages/recommendation_anime_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AnimeApp());
}

class AnimeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeAnimePage(),
    RecommendationPage(),
    TopAnimePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recommend_outlined),
            label: 'Recommend...',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Top Anime',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeAnimePage extends StatefulWidget {
  @override
  _HomeAnimePageState createState() => _HomeAnimePageState();
}

class _HomeAnimePageState extends State<HomeAnimePage> {
  List animeList = [];
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    fetchAnimeSeasonNow();
  }

  Future<void> fetchAnimeSeasonNow() async {
    final response = await http.get(Uri.parse('https://api.jikan.moe/v4/seasons/now'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        animeList = data['data'];
      });
    } else {
      throw Exception('Failed to load anime');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Season Now'),
      ),
      body: animeList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            itemCount: animeList.length,
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final anime = animeList[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnimeDetailPage(
                        title: anime['title'],
                        imageUrl: anime['images']['jpg']['large_image_url'],
                        type: anime['type'],
                        synopsis: anime['synopsis'] ?? 'No synopsis available',
                        background: anime['background'] ?? 'No background available',
                        score: anime['score'].toString() ?? 'N/A',
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(10),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          anime['images']['jpg']['large_image_url'],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black54,
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                anime['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    anime['type'],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${anime['score'] ?? 'N/A'}',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      const SizedBox(width: 5),
                                      const Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Container(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Coming soon!')),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrange,
                                      padding: EdgeInsets.symmetric(vertical: 15),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Watch Now'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SmoothPageIndicator(
              controller: _pageController,
              count: animeList.length,
              effect: const ExpandingDotsEffect(
                activeDotColor: Colors.deepOrange,
                dotColor: Colors.white,
                dotHeight: 8,
                dotWidth: 8,
                spacing: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
