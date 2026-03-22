import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/section_heading_widget.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const String _recentSearchesKey = 'recent_searches';

  final TextEditingController _searchController = TextEditingController();

  final List<String> _recentSearches = <String>[];

  final List<_PopularTopic> _popularTopics = const <_PopularTopic>[
    _PopularTopic(
      name: 'Black Holes',
      query: 'black holes',
      assetPath: 'assets/popular/black_holes.jpg',
    ),
    _PopularTopic(
      name: 'Earth',
      query: 'earth',
      assetPath: 'assets/popular/earth.jpg',
    ),
    _PopularTopic(
      name: 'Galaxies',
      query: 'galaxies',
      assetPath: 'assets/popular/galaxies.jpg',
    ),
    _PopularTopic(
      name: 'Mars',
      query: 'mars',
      assetPath: 'assets/popular/mars.jpg',
    ),
    _PopularTopic(
      name: 'Nebulae',
      query: 'nebulae',
      assetPath: 'assets/popular/nebulae.jpg',
    ),
    _PopularTopic(
      name: 'Saturn',
      query: 'saturn',
      assetPath: 'assets/popular/saturn.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> saved =
        prefs.getStringList(_recentSearchesKey) ?? <String>[];

    if (!mounted) {
      return;
    }

    setState(() {
      _recentSearches
        ..clear()
        ..addAll(saved);
    });
  }

  Future<void> _saveRecentSearch(String query) async {
    final String normalized = query.trim();
    if (normalized.isEmpty) {
      return;
    }

    _recentSearches.removeWhere(
      (String item) => item.toLowerCase() == normalized.toLowerCase(),
    );
    _recentSearches.insert(0, normalized);

    if (_recentSearches.length > 4) {
      _recentSearches.removeRange(4, _recentSearches.length);
    }

    setState(() {});

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, _recentSearches);
  }

  Future<void> _performSearch(String query) async {
    final String normalized = query.trim();
    if (normalized.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    await _saveRecentSearch(normalized);

    if (!mounted) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            SearchResultsScreen(query: normalized),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: _performSearch,
      decoration: InputDecoration(
        hintText: 'Search NASA images and videos...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        filled: true,
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SectionHeadingWidget(text: 'Recent Searches', fontSize: 20),
        const SizedBox(height: 8),
        if (_recentSearches.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No recent searches yet'),
          )
        else
          Column(
            children: _recentSearches
                .map(
                  (String search) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.history),
                    title: Text(search),
                    onTap: () {
                      _performSearch(search);
                    },
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildPopularTopics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SectionHeadingWidget(
          text: 'Explore Popular Topics',
          fontSize: 20,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _popularTopics.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemBuilder: (BuildContext context, int index) {
            final _PopularTopic topic = _popularTopics[index];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _searchController.text = topic.query;
                _performSearch(topic.query);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Image.asset(topic.assetPath, fit: BoxFit.cover),
                    Container(color: Colors.black26),
                    Center(
                      child: Text(
                        topic.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _buildSearchBar(),
        const SizedBox(height: 20),
        _buildRecentSearches(),
        const SizedBox(height: 20),
        _buildPopularTopics(),
      ],
    );
  }
}

class _PopularTopic {
  final String name;
  final String query;
  final String assetPath;

  const _PopularTopic({
    required this.name,
    required this.query,
    required this.assetPath,
  });
}
