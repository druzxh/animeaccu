import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'anime_detail_page.dart';

class RecommendationPage extends StatefulWidget {
  @override
  _RecommendationPageState createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  List animeList = [];

  @override
  void initState() {
    super.initState();
    fetchAnimeRecommendations();
  }

  Future<void> fetchAnimeRecommendations() async {
    final response = await http.get(Uri.parse('https://api.jikan.moe/v4/recommendations/anime'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        animeList = data['data'];
      });
    } else {
      throw Exception('Failed to load anime recommendations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recommendations Anime'),
      ),
      body: animeList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        padding: EdgeInsets.all(8.0),
        itemCount: animeList.length,
        itemBuilder: (context, index) {
          final anime = animeList[index];
          final entry = anime['entry'][0]; // Ambil entri pertama
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnimeDetailPage(
                    title: entry['title'],
                    imageUrl: entry['images']['jpg']['large_image_url'] ?? 'No image',
                    type: 'N/A',
                    synopsis: anime['content'] ?? 'No synopsis available',
                    background: anime['content'] ?? 'No background available',
                    score: 'N/A',
                    // url: entry['url'], // Tambahkan URL jika ingin
                  ),
                ),
              );
            },
            child: Card(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      entry['images']['jpg']['image_url'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black54,
                      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry['title'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Text(
                          //   'No type',
                          //   style: TextStyle(color: Colors.white),
                          // ),
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
    );
  }
}
