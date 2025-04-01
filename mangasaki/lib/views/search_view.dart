import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mangasaki/widgets/manga_widget.dart';

import '../widgets/simplemanga_widget.dart';

class MangaSearchView extends StatefulWidget {
  @override
  _MangaSearchViewState createState() => _MangaSearchViewState();
}

class _MangaSearchViewState extends State<MangaSearchView> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _mangaResults = [];
  bool _isLoading = false;
  bool _showGenres = false;
  bool _showGenresMobile = false;
  int _lastPage = 1;
  int _currentPage = 1;
  bool _showPanel = false;

  @override
  void initState() {
    super.initState();
    _loadRandomMangas();
  }

  void _retryFetchMangas() {
    setState(() {
      _loadRandomMangas();
      _mangaResults.clear();
    });
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

  Map<int, int> genreStates = {}; // 0: no seleccionado, 1: incluido, 2: excluido
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

    final String orderBy = orderByMap[selectedOrderBy] ?? 'mal_id';
    final String status = selectedStatus ?? '';
    try {
      String url = 'https://api.jikan.moe/v4/manga?q=${_searchController.text}';

      if (includedGenres.isNotEmpty) url += '&genres=$includedGenres';
      if (excludedGenres.isNotEmpty) url += '&genres_exclude=$excludedGenres';
      if (orderBy.isNotEmpty) url += '&order_by=$orderBy';
      if (status != "Default") url += '&status=$status';
      if (_currentPage > 1) url += '&page=$_currentPage';

      final response = await http.get(Uri.parse(url));


      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _mangaResults = data['data'] ?? [];
          _lastPage = data['pagination']['last_visible_page'] ?? 1;
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

  // Esto es un widget que hace que se pueda filtrar en la version mobile
  Widget _buildSlidingPanel() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _showPanel ? 300 : 0, // Altura animada
      curve: Curves.easeInOut,
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: _showPanel
          ? ClipRRect(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 300,
              maxHeight: 400,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => setState(() => _showPanel = false),
                  ),
                ),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(labelText: 'Search...'),
                ),
                SizedBox(height: 10),

                // Status y Order By en la misma fila
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        hint: Text('Status'),
                        value: selectedStatus == 'Default' ? null : selectedStatus,
                        onChanged: (value) => setState(() => selectedStatus = value),
                        items: ['Default', 'publishing', 'complete', 'hiatus']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                      ),
                    ),
                    SizedBox(width: 10), // Espaciado entre los Dropdowns
                    Expanded(
                      child: DropdownButton<String>(
                        hint: Text('Order By'),
                        value: selectedOrderBy == 'Default' ? null : selectedOrderBy,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedOrderBy = value);
                          }
                        },
                        items: ['Default', 'Title', 'Score', 'Rank', 'Popularity']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () =>
                          setState(() => _showGenresMobile = !_showGenresMobile),
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

                if (_showGenresMobile) ...[
                  SizedBox(height: 10),
                  // Scroll para géneros
                  Container(
                    height: 100,
                    child: SingleChildScrollView(
                      child: Wrap(
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
                              label: Text(
                                genre['name'],
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      )
          : SizedBox.shrink(),
    );
  }



  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 800;
          return Scaffold(
            appBar: AppBar(
              title: Text('Manga Search'),
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1.0),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.black,
                ),
              ),
              actions: isMobile
                  ? [
                IconButton(
                  icon: Icon(Icons.filter_alt),
                  onPressed: () => setState(() => _showPanel = !_showPanel),
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _retryFetchMangas,
                )
              ]
                  : [IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _retryFetchMangas,
              )],
            ),
            body: Column(
              children: [
                _buildSlidingPanel(),
                if (!isMobile)
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
                          value: selectedStatus == 'Default'
                              ? null
                              : selectedStatus,
                          onChanged: (value) =>
                              setState(() => selectedStatus = value),
                          items: [
                            'Default',
                            'publishing',
                            'complete',
                            'hiatus',
                            'discontinued',
                            'upcoming'
                          ]
                              .map((e) =>
                              DropdownMenuItem(value: e,
                                  child: Text(e)))
                              .toList(),
                        ),
                        SizedBox(width: 10),
                        DropdownButton<String>(
                          hint: Text('Order By'),
                          value: selectedOrderBy == 'Default'
                              ? null
                              : selectedOrderBy, // Oculta "Default"
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedOrderBy = value);
                            }
                          },
                          items: [
                            'Default',
                            'Title',
                            'Score',
                            'Rank',
                            'Popularity'
                          ]
                              .map((e) =>
                              DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                              .toList(),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () =>
                              setState(() => _showGenres = !_showGenres),
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
                          label: Text(genre['name'], style: TextStyle(
                              fontSize: 12)),
                        ),
                      );
                    }).toList(),
                  ),
                _isLoading
                    ? CircularProgressIndicator()
                    : Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return _mangaResults.isEmpty
                          ? FutureBuilder<List<dynamic>>(
                        future: _loadRandomMangas(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                                child: Text('No random mangas found.'));
                          } else {
                            final randomMangas = snapshot.data!;
                            return ListView.builder(
                              itemCount: 24,
                              itemBuilder: (context, index) {
                                final manga = randomMangas[index];
                                if (manga['entry'] is List &&
                                    manga['entry'].isNotEmpty) {
                                  final firstEntry = manga['entry'][0];
                                  final image = firstEntry['images']?['jpg']?['image_url'] ??
                                      'https://picsum.photos/200/300';
                                  return SimpleMangaWidget(
                                    id: firstEntry['mal_id'],
                                    title: firstEntry['title'],
                                    imageUrl: image,
                                  );
                                } else {
                                  return SizedBox();
                                }
                              },
                            );
                          }
                        },
                      )
                          : ListView.builder(
                        itemCount: _mangaResults.length,
                        itemBuilder: (context, index) {
                          final manga = _mangaResults[index];
                          List<String> generos = [];

                          for (var genre in manga["genres"]) {
                            generos.add(genre['name']);
                          }
                          for (var genre in manga["themes"]) {
                            generos.add(genre["name"]);
                          }
                          for (var genre in manga["demographics"]) {
                            generos.add(genre["name"]);
                          }

                          double width = constraints.maxWidth;

                          return SizedBox(
                            height: 200,
                            child: width < 800
                                ? MangaWidgetMobile(
                              imageUrl: manga['images']['jpg']['image_url'],
                              status: manga['status'],
                              score: manga['score'] ?? 0,
                              rank: manga['rank'] ?? 99999,
                              title: manga['title'],
                              description: manga["synopsis"] ?? "Description not yet available",
                              chapters: manga["chapters"] ?? -1,
                              genres: generos,
                            )
                                : MangaWidget(
                              imageUrl: manga['images']['jpg']['image_url'],
                              status: manga['status'],
                              score: manga['score'] ?? 0,
                              rank: manga['rank'] ?? 99999,
                              title: manga['title'],
                              description: manga["synopsis"] ?? "Description not yet available",
                              chapters: manga["chapters"] ?? -1,
                              genres: generos,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.first_page),
                      onPressed: _currentPage > 1 ? () => _changePage(1) : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.navigate_before),
                      onPressed: _currentPage > 1 ? () =>
                          _changePage(_currentPage - 1) : null,
                    ),
                    Text('Page $_currentPage of $_lastPage'),
                    IconButton(
                      icon: Icon(Icons.navigate_next),
                      onPressed: _currentPage < _lastPage ? () =>
                          _changePage(_currentPage + 1) : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.last_page),
                      onPressed: _currentPage < _lastPage ? () =>
                          _changePage(_lastPage) : null,
                    ),
                  ],
                ),
              ],
            ),
          );
        });
    }


  void _changePage(int newPage) {
    if (newPage >= 1 && newPage <= _lastPage) {
      setState(() => _currentPage = newPage);
      _searchManga();
    }
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
