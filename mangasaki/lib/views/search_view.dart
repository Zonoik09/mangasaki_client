import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MangaSearchView extends StatefulWidget {
  @override
  _MangaSearchViewState createState() => _MangaSearchViewState();
}

class _MangaSearchViewState extends State<MangaSearchView> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _mangaResults = [];
  List<dynamic> _mangaRandom = [];
  bool _isLoading = false;
  bool _showGenres = false;

  @override
  void initState() {
    super.initState();
    _loadRandomMangas();
  }

  // Cargar mangas aleatorios
  Future<List<dynamic>> _loadRandomMangas() async {
    try {
      return await getRandomMangas();
    } catch (e) {
      print('Error loading random mangas: $e');
      return [];
    }
  }

  final List<Map<String, dynamic>> genres = [
    {'id': 1, 'name': 'Action'},
    {'id': 2, 'name': 'Adventure'},
    {'id': 3, 'name': 'Cars'},
    {'id': 4, 'name': 'Comedy'},
    {'id': 5, 'name': 'Dementia'},
    {'id': 6, 'name': 'Demons'},
    {'id': 7, 'name': 'Mystery'},
    {'id': 8, 'name': 'Drama'},
    {'id': 9, 'name': 'Ecchi'},
    {'id': 10, 'name': 'Fantasy'},
    {'id': 11, 'name': 'Game'},
    {'id': 12, 'name': 'Hentai'},
    {'id': 13, 'name': 'Historical'},
    {'id': 14, 'name': 'Horror'},
    {'id': 15, 'name': 'Kids'},
    {'id': 16, 'name': 'Magic'},
    {'id': 17, 'name': 'Martial Arts'},
    {'id': 18, 'name': 'Mecha'},
    {'id': 19, 'name': 'Music'},
    {'id': 20, 'name': 'Parody'},
    {'id': 21, 'name': 'Samurai'},
    {'id': 22, 'name': 'Romance'},
    {'id': 23, 'name': 'School'},
    {'id': 24, 'name': 'Sci-Fi'},
    {'id': 25, 'name': 'Shoujo'},
    {'id': 26, 'name': 'Shoujo Ai'},
    {'id': 27, 'name': 'Shounen'},
    {'id': 28, 'name': 'Shounen Ai'},
    {'id': 29, 'name': 'Space'},
    {'id': 30, 'name': 'Sports'},
    {'id': 31, 'name': 'Super Power'},
    {'id': 32, 'name': 'Vampire'}
  ];

  Map<int, int> genreStates =
  {}; // 0: no seleccionado, 1: incluido, 2: excluido
  String? selectedStatus;
  String selectedOrderBy = "Default";

  // Mapeo de los valores del Dropdown a los valores correctos de la API
  final Map<String, String> orderByMap = {
    'Default': 'mal_id',
    'Title': 'title',
    'Score': 'score',
    'Rank': 'rank',
    'Popularity': 'popularity',
  };

  Future<void> _searchManga() async {
    setState(() => _isLoading = true);

    final includedGenres = genreStates.entries
        .where((entry) => entry.value == 1)
        .map((entry) => entry.key)
        .join(',');

    final excludedGenres = genreStates.entries
        .where((entry) => entry.value == 2)
        .map((entry) => entry.key)
        .join(',');

    final String orderBy =
        orderByMap[selectedOrderBy] ?? 'mal_id'; // Conversión con el mapa
    final String status = selectedStatus ?? '';

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.jikan.moe/v4/manga?q=${_searchController.text}'
              '&genres=$includedGenres'
              '&genres_exclude=$excludedGenres'
              '&order_by=$orderBy'
              '&status=$status',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _mangaResults = data['data'] ?? [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manga Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(labelText: 'Search...'),
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  hint: Text('Status'),
                  value: selectedStatus == 'Default' ? null : selectedStatus,
                  onChanged: (value) => setState(() => selectedStatus = value),
                  items: [
                    'Default',
                    'publishing',
                    'complete',
                    'hiatus',
                    'discontinued',
                    'upcoming'
                  ]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  hint: Text(
                      'Order By'), // Esto se mostrará cuando no haya selección
                  value: selectedOrderBy == 'Default'
                      ? null
                      : selectedOrderBy, // Oculta "Default"
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedOrderBy = value);
                    }
                  },
                  items: ['Default', 'Title', 'Score', 'Rank', 'Popularity']
                      .map((e) =>
                      DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                      .toList(),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _showGenres = !_showGenres),
                  icon: Icon(Icons.filter_list),
                  label: Text('Genres'),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _searchManga,
                  icon: Icon(Icons.search),
                  label: Text('Filter'),
                ),
              ],
            ),
          ),
          if (_showGenres)
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: genres.map((genre) {
                int state = genreStates[genre['id']] ?? 0;
                IconData icon = state == 1
                    ? Icons.check_circle
                    : state == 2
                    ? Icons.cancel
                    : Icons.circle;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      genreStates[genre['id']] = (state + 1) % 3;
                    });
                  },
                  child: Chip(
                    avatar: Icon(icon,
                        color: state == 0
                            ? Colors.grey
                            : state == 1
                            ? Colors.green
                            : Colors.red),
                    label: Text(genre['name'], style: TextStyle(fontSize: 12)),
                  ),
                );
              }).toList(),
            ),
          _isLoading
              ? CircularProgressIndicator()
              : Expanded(
            child: _mangaResults.isEmpty
                ? FutureBuilder<List<dynamic>>(
              future: _loadRandomMangas(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No random mangas found.'));
                } else {
                  final randomMangas = snapshot.data!;
                  return ListView.builder(
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      final manga = randomMangas[index];
                      if (manga['entry'] is List && manga['entry'].isNotEmpty) {
                        final firstEntry = manga['entry'][0];
                        final imageUrl = firstEntry['images']?['jpg']?['image_url'] ??
                            'https://picsum.photos/200/300';
                        return ListTile(
                          leading: Image.network(
                            imageUrl,
                            width: 50,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                          title: Text(firstEntry['title'] ?? 'No title'),
                          subtitle: Text(
                              'Score: ${firstEntry['score'] ?? 'N/A'}'),
                        );
                      } else {
                        return SizedBox(); // En caso de que no haya mangas en 'entry'
                      }
                    }
                  );
                }
              },
            )
                : ListView.builder(
              itemCount: _mangaResults.length,
              itemBuilder: (context, index) {
                final manga = _mangaResults[index];
                return ListTile(
                  leading: Image.network(
                    manga['images']['jpg']['image_url'],
                    width: 50,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                  title: Text(manga['title']),
                  subtitle:
                  Text('Score: ${manga['score'] ?? 'N/A'}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>> getRandomMangas() async {
    final response = await http.get(
        Uri.parse('https://api.jikan.moe/v4/recommendations/manga'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load mangas');
    }
  }
}



