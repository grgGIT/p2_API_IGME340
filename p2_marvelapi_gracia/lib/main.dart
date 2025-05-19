import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

const String publicKey = '2773056a4ad55356f3e9604384e05462';
const String privateKey = '6fa4c391abf04dd08a09f61f73b26e73dff8a53a';
const String baseUrl = 'https://gateway.marvel.com/v1/public';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marvel Search',
      theme: ThemeData(
        primaryColor: Colors.red,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red).copyWith(
          secondary: Colors.amber,
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 52, 34, 34),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          displayLarge: TextStyle(fontFamily: 'MightySans', color: Colors.white),
          displayMedium: TextStyle(fontFamily: 'Jackpot', color: Colors.white),
          labelLarge: TextStyle(fontFamily: 'Adventure', color: Colors.white),
        ),
      ),
      home: const SearchScreen(),
    );
  }
}
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _results = [];
  String _searchType = 'Characters';
  bool _hasSearched = false;
  bool _isLoading = false;
  String? _gifUrl;

  @override
  void initState() {
    super.initState();
    _fetchRandomGif();
  }

  Future<void> _fetchRandomGif() async {
    final url = Uri.parse('https://api.giphy.com/v1/gifs/random?api_key=TVuw2BunbafGQpCJVjrI0vPmV20qqndi&tag=Marvel');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _gifUrl = data['data']['images']['original']['url'];
        });
      } else {
        print('Failed to load GIF: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _search() async {
    setState(() {
      _isLoading = true;
    });

    List<dynamic> results;
    try {
      switch (_searchType) {
        case 'Characters':
          results = await MarvelApi.searchCharacters(_searchController.text);
          break;
        case 'Creators':
          results = await MarvelApi.searchCreators(_searchController.text);
          break;
        case 'Comics':
          results = await MarvelApi.searchComics(_searchController.text);
          break;
        case 'Events':
          results = await MarvelApi.searchEvents(_searchController.text);
          break;
        case 'Series':
          results = await MarvelApi.searchSeries(_searchController.text);
          break;
        default:
          results = [];
      }
    } catch (e) {
      results = [];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() {
      _results = results;
      _hasSearched = true;
      _isLoading = false;
    });
  }

  void _resetSearch() {
    setState(() {
      _searchController.clear();
      _results = [];
      _hasSearched = false;
      _fetchRandomGif(); // Fetch a new GIF when returning to the main menu
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'Marvel Search',
          style: TextStyle(
            fontFamily: 'MightySans',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: !_hasSearched
              ? DecorationImage(
                  image: AssetImage('images/mbg.jpeg'), // Background image
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5), // Adjust transparency
                    BlendMode.dstATop,
                  ),
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (!_hasSearched)
                Image.asset('images/marvel-comics-logo.png', height: 50),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Search $_searchType',
                        labelStyle: const TextStyle(color: Colors.redAccent),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[900],
                        suffixIcon: IconButton(
                          onPressed: _search,
                          icon: const Icon(Icons.search, color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (!_hasSearched)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: DropdownButton<String>(
                    value: _searchType,
                    items: <String>['Characters', 'Creators', 'Comics', 'Events', 'Series'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _searchType = newValue!;
                      });
                    },
                    dropdownColor: Colors.grey[900],
                    underline: Container(),
                    iconEnabledColor: Colors.redAccent,
                  ),
                ),
              const SizedBox(height: 16),
              if (_gifUrl != null && !_hasSearched)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: Image.network(_gifUrl!, fit: BoxFit.cover),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.red),
                            SizedBox(height: 16),
                            Text(
                              'Gathering heroes, villains, and legends alike...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final result = _results[index];
                          final name = result['title'] ?? result['name'] ?? result['fullName'] ?? 'Unknown';
                          final thumbnail = result['thumbnail'];
                          final imageUrl = (thumbnail != null && thumbnail['path'] != null)
                              ? '${thumbnail['path']}.${thumbnail['extension']}'
                              : 'https://via.placeholder.com/50';

                          return GestureDetector(
                            onTap: () => _showProfile(context, result['id'], _searchType),
                            child: ListTile(
                              leading: Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                              title: Text(name, style: const TextStyle(color: Colors.white)),
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),
                            ),
                          );
                        },
                      ),
              ),
              if (_hasSearched)
                ElevatedButton(
                  onPressed: _resetSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    textStyle: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  child: const Text('Back to Main Menu', style: TextStyle(fontFamily: 'Adventure', color: Colors.white)),
                ),
              if (!_hasSearched)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      launch('https://developer.marvel.com/docs#!/public/getIssueEventsCollection_get_10');
                    },
                    child: const Text(
                      'All API use and IP of Marvel Comics',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
//runs the fucntions to get the data that gets displayed in the profile content
  void _showProfile(BuildContext context, int id, String type) async {
    Map<String, dynamic> details;
    try {
      switch (type) {
        case 'Characters':
          details = await MarvelApi.getCharacterDetails(id);
          break;
        case 'Creators':
          details = await MarvelApi.getCreatorDetails(id);
          break;
        case 'Comics':
          details = await MarvelApi.getComicDetails(id);
          break;
        case 'Events':
          details = await MarvelApi.getEventDetails(id);
          break;
        case 'Series':
          details = await MarvelApi.getSeriesDetails(id);
          break;
        default:
          details = {};
      }
    } catch (e) {
      details = {};
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(details: details, type: type),
      ),
    );
  }

//creates result lists and then their respective profiles
class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> details;
  final String type;

  const ProfileScreen({super.key, required this.details, required this.type});

  @override
  Widget build(BuildContext context) {
    final name = details['title'] ?? details['name'] ?? details['fullName'] ?? 'Unknown';
    final description = details['description'] ?? 'No description available';
    final thumbnail = details['thumbnail'];
    final imageUrl = (thumbnail != null && thumbnail['path'] != null)
        ? '${thumbnail['path']}.${thumbnail['extension']}'
        : 'https://via.placeholder.com/300';

    final creators = details['creators']?['items'] as List<dynamic>? ?? [];
    final characters = details['characters']?['items'] as List<dynamic>? ?? [];
    final events = details['events']?['items'] as List<dynamic>? ?? [];
    final stories = details['stories']?['items'] as List<dynamic>? ?? [];
    final series = details['series']?['items'] as List<dynamic>? ?? [];
    final comics = details['comics']?['items'] as List<dynamic>? ?? [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400.0,
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: Container(
    margin: const EdgeInsets.all(8.0), // Optional: Add some margin
    decoration: BoxDecoration(
      color: Colors.grey[700], // Gray background for the bubble
      shape: BoxShape.circle,
    ),
    child: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  ),

            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                name,
                style: const TextStyle(fontFamily: 'Jackpot', color: Colors.white),
              ),
              background: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.redAccent),
                      ),
                      const SizedBox(height: 8),
                      Text(description, style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 16),
                      if (type == 'Characters' || type == 'Creators') ...[
                        _buildSection('Creators', creators, context),
                        _buildSection('Comics', comics, context),
                        _buildSection('Events', events, context),
                        _buildSection('Series', series, context),
                        _buildSection('Stories', stories, context),
                      ],
                      if (type == 'Comics' || type == 'Series') ...[
                        _buildSection('Creators', creators, context),
                        _buildSection('Characters', characters, context),
                        _buildSection('Events', events, context),
                        _buildSection('Stories', stories, context),
                      ],
                      if (type == 'Events') ...[
                        _buildSection('Characters', characters, context),
                        _buildSection('Creators', creators, context),
                        _buildSection('Comics', comics, context),
                        _buildSection('Series', series, context),
                        _buildSection('Stories', stories, context),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
//works on the search result entries and what gets displayed before clicking on them
  Widget _buildSection(String title, List<dynamic> items, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontFamily: 'Adventure', color: Colors.redAccent)),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Text('None found', style: TextStyle(color: Colors.white)),
          ...items.map((item) {
            final itemName = item['name'] ?? item['title'] ?? 'Unknown';
            final itemThumbnail = item['thumbnail'];
            final itemImageUrl = (itemThumbnail != null && itemThumbnail['path'] != null)
                ? '${itemThumbnail['path']}.${itemThumbnail['extension']}'
                : null;

            return ListTile(
              leading: itemImageUrl != null
                  ? Image.network(itemImageUrl, width: 50, height: 50, fit: BoxFit.cover)
                  : null,
              title: Text(itemName, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
        ],
      ),
    );
  }
}
//uses all of the functions in here to access the separate parts of the API for display purposes
class MarvelApi {
  static const String publicKey = '2773056a4ad55356f3e9604384e05462';

  static String _generateHash(int timestamp) {
    final bytes = utf8.encode('$timestamp$privateKey$publicKey');
    return md5.convert(bytes).toString();
  }

  static Future<List<dynamic>> searchCharacters(String name) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = _generateHash(timestamp);
    final url = Uri.parse(
      '$baseUrl/characters?nameStartsWith=$name&limit=100&apikey=$publicKey&ts=$timestamp&hash=$hash',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data); // Debugging: Print the response
        return data['data']['results'] as List<dynamic>;
      } else {
        print('Failed to load characters: ${response.statusCode}');
        throw Exception('Failed to load characters');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  static Future<List<dynamic>> searchCreators(String name) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = _generateHash(timestamp);
    final url = Uri.parse(
      '$baseUrl/creators?nameStartsWith=$name&limit=100&apikey=$publicKey&ts=$timestamp&hash=$hash',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data); // Debugging: Print the response
        return data['data']['results'] as List<dynamic>;
      } else {
        print('Failed to load creators: ${response.statusCode}');
        throw Exception('Failed to load creators');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  static Future<List<dynamic>> searchComics(String name) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = _generateHash(timestamp);
    final url = Uri.parse(
      '$baseUrl/comics?titleStartsWith=$name&limit=100&apikey=$publicKey&ts=$timestamp&hash=$hash',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data); // Debugging: Print the response
        return data['data']['results'] as List<dynamic>;
      } else {
        print('Failed to load comics: ${response.statusCode}');
        throw Exception('Failed to load comics');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  static Future<List<dynamic>> searchEvents(String name) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = _generateHash(timestamp);
    final url = Uri.parse(
      '$baseUrl/events?nameStartsWith=$name&limit=100&apikey=$publicKey&ts=$timestamp&hash=$hash',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data); // Debugging: Print the response
        return data['data']['results'] as List<dynamic>;
      } else {
        print('Failed to load events: ${response.statusCode}');
        throw Exception('Failed to load events');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  static Future<List<dynamic>> searchSeries(String name) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = _generateHash(timestamp);
    final url = Uri.parse(
      '$baseUrl/series?titleStartsWith=$name&limit=100&apikey=$publicKey&ts=$timestamp&hash=$hash',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data); // Debugging: Print the response
        return data['data']['results'] as List<dynamic>;
      } else {
        print('Failed to load series: ${response.statusCode}');
        throw Exception('Failed to load series');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getCharacterDetails(int id) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = _generateHash(timestamp);
    final url = Uri.parse(
      '$baseUrl/characters/$id?apikey=$publicKey&ts=$timestamp&hash=$hash',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data']['results'][0];
      } else {
        throw Exception('Failed to load character details');
      }
    } catch (e) {
      print('Error: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> getCreatorDetails(int id) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = _generateHash(timestamp);
    final url = Uri.parse(
      '$baseUrl/creators/$id?apikey=$publicKey&ts=$timestamp&hash=$hash',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data']['results'][0];
      } else {
        throw Exception('Failed to load creator details');
      }
    } catch (e) {
      print('Error: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> getComicDetails(int id) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = _generateHash(timestamp);
    final url = Uri.parse(
      '$baseUrl/comics/$id?apikey=$publicKey&ts=$timestamp&hash=$hash',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data']['results'][0];
      } else {
        throw Exception('Failed to load comic details');
      }
    } catch (e) {
      print('Error: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> getEventDetails(int id) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = _generateHash(timestamp);
    final url = Uri.parse(
      '$baseUrl/events/$id?apikey=$publicKey&ts=$timestamp&hash=$hash',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data']['results'][0];
      } else {
        throw Exception('Failed to load event details');
      }
    } catch (e) {
      print('Error: $e');
      return {};
    }
  }

  
  static Future<Map<String, dynamic>> getSeriesDetails(int id) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = _generateHash(timestamp);
    final url = Uri.parse(
      '$baseUrl/series/$id?apikey=$publicKey&ts=$timestamp&hash=$hash',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data']['results'][0];
      } else {
        throw Exception('Failed to load series details');
      }
    } catch (e) {
      print('Error: $e');
      return {};
    }
  }
}