import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'anime_detail_page.dart';

class TopAnimePage extends StatefulWidget {
  @override
  _TopAnimePageState createState() => _TopAnimePageState();
}

class _TopAnimePageState extends State<TopAnimePage> {
  List animeList = [];

  @override
  void initState() {
    super.initState();
    fetchTopAnime();
  }

  Future<void> fetchTopAnime() async {
    final response = await http.get(Uri.parse('https://api.jikan.moe/v4/top/anime'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        animeList = data['data'];
      });
    } else {
      throw Exception('Failed to load top anime');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Anime'),
      ),
      body: animeList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: animeList.length,
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
                    type: anime['type'] ?? 'Unknown',
                    synopsis: anime['synopsis'] ?? 'No synopsis available',
                    background: anime['background'] ?? 'No background available',
                    score: anime['score'] != null
                        ? anime['score'].toString()
                        : 'N/A',
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        anime['images']['jpg']['large_image_url'],
                        height: 175,
                        width: 125,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Data anime
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Judul
                          Text(
                            anime['title'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Genre
                          Text(
                            anime['genres'] != null
                                ? anime['genres'].map((g) => g['name']).join(', ')
                                : 'No genres available',
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                          const SizedBox(height: 4),
                          // Rating
                          Row(
                            children: [
                              Text(
                                '${anime['score'] != null ? anime['score'].toString() : 'N/A'}',
                                style: const TextStyle(color: Colors.black),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.star,
                                color: Colors.blueAccent,
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            anime['synopsis'] != null
                                ? anime['synopsis']
                                : 'No synopsis available',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Coming soon!')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Watch Now'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
