// import 'dart:convert';
// import 'package:crypto/crypto.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Marvel Character & Creator Search',
//       theme: ThemeData(
//         primaryColor: Colors.red,
//         colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red),
//         scaffoldBackgroundColor: const Color.fromARGB(255, 52, 34, 34),
//         textTheme: const TextTheme(
//           bodyMedium: TextStyle(color: Colors.white),
//         ),
//       ),
//       home: const SearchScreen(),
//     );
//   }
// }

// class MarvelApi {
//   static const String publicKey = '2773056a4ad55356f3e9604384e05462';
//   static const String privateKey = '6fa4c391abf04dd08a09f61f73b26e73dff8a53a';
//   static const String baseUrl = 'https://gateway.marvel.com/v1/public';

//   static String _generateHash(int timestamp) {
//     final bytes = utf8.encode('$timestamp$privateKey$publicKey');
//     return md5.convert(bytes).toString();
//   }

//   static Future<List<dynamic>> searchCharacters(String name) async {
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final hash = _generateHash(timestamp);
//     final url = Uri.parse(
//       '$baseUrl/characters?nameStartsWith=$name&apikey=$publicKey&ts=$timestamp&hash=$hash',
//     );
//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)['data']['results'] as List<dynamic>;
//     } else {
//       throw Exception('Failed to load characters');
//     }
//   }

//   static Future<List<dynamic>> searchCreators(String name) async {
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final hash = _generateHash(timestamp);
//     final url = Uri.parse(
//       '$baseUrl/creators?nameStartsWith=$name&apikey=$publicKey&ts=$timestamp&hash=$hash',
//     );
//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)['data']['results'] as List<dynamic>;
//     } else {
//       throw Exception('Failed to load creators');
//     }
//   }

//   static Future<Map<String, dynamic>> getCharacterDetails(int id) async {
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final hash = _generateHash(timestamp);
//     final url = Uri.parse(
//       '$baseUrl/characters/$id?apikey=$publicKey&ts=$timestamp&hash=$hash',
//     );
//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)['data']['results'][0];
//     } else {
//       throw Exception('Failed to load character details');
//     }
//   }

//   static Future<Map<String, dynamic>> getCreatorDetails(int id) async {
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final hash = _generateHash(timestamp);
//     final url = Uri.parse(
//       '$baseUrl/creators/$id?apikey=$publicKey&ts=$timestamp&hash=$hash',
//     );
//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)['data']['results'][0];
//     } else {
//       throw Exception('Failed to load creator details');
//     }
//   }
// }

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _characterController = TextEditingController();
//   final TextEditingController _creatorController = TextEditingController();
//   List<dynamic> _characterResults = [];
//   List<dynamic> _creatorResults = [];

//   void _searchCharacters() async {
//     final results = await MarvelApi.searchCharacters(_characterController.text);
//     setState(() {
//       _characterResults = results;
//     });
//   }

//   void _searchCreators() async {
//     final results = await MarvelApi.searchCreators(_creatorController.text);
//     setState(() {
//       _creatorResults = results;
//     });
//   }

//   void _showProfile(BuildContext context, int id, bool isCharacter) async {
//     final details = isCharacter
//         ? await MarvelApi.getCharacterDetails(id)
//         : await MarvelApi.getCreatorDetails(id);

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProfileScreen(details: details, isCharacter: isCharacter),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Marvel Character & Creator Search'),
//         backgroundColor: Colors.red,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _buildSearchBar(_characterController, 'Search Characters', _searchCharacters),
//             _buildSearchBar(_creatorController, 'Search Creators', _searchCreators),
//             const SizedBox(height: 16),
//             Expanded(
//               child: ListView(
//                 children: [
//                   _buildResultsSection('Character Results', _characterResults, true),
//                   _buildResultsSection('Creator Results', _creatorResults, false),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchBar(TextEditingController controller, String label, VoidCallback onSearch) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: controller,
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 labelText: label,
//                 labelStyle: const TextStyle(color: Colors.redAccent),
//                 border: const OutlineInputBorder(),
//                 filled: true,
//                 fillColor: Colors.grey[900],
//               ),
//             ),
//           ),
//           IconButton(
//             onPressed: onSearch,
//             icon: const Icon(Icons.search, color: Colors.red),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildResultsSection(String title, List<dynamic> results, bool isCharacter) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
//         ),
//         const SizedBox(height: 8),
//         for (var result in results)
//           ListTile(
//             title: Text(
//               isCharacter ? result['name'] : result['fullName'],
//               style: const TextStyle(color: Colors.white),
//             ),
//             onTap: () => _showProfile(context, result['id'], isCharacter),
//             trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),
//           ),
//       ],
//     );
//   }
// }

// class ProfileScreen extends StatelessWidget {
//   final Map<String, dynamic> details;
//   final bool isCharacter;

//   const ProfileScreen({super.key, required this.details, required this.isCharacter});

//   @override
//   Widget build(BuildContext context) {
//     final name = isCharacter ? details['name'] : details['fullName'];
//     final description = details['description'] ?? 'No description available';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(name),
//         backgroundColor: Colors.red,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               name,
//               style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.redAccent),
//             ),
//             const SizedBox(height: 8),
//             Text(description, style: const TextStyle(color: Colors.white)),
//             const SizedBox(height: 16),
//             const Text('Additional Information:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent)),
//             Text(isCharacter ? 'Events, series, and stories will go here.' : 'Works created will go here.', style: const TextStyle(color: Colors.white)),
//           ],
//         ),
//       ),
//     );
//   }
// }
//import 'dart:convert';
// import 'package:crypto/crypto.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Marvel Character & Creator Search',
//       theme: ThemeData(
//         primaryColor: Colors.red,
//         colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red),
//         scaffoldBackgroundColor: const Color.fromARGB(255, 52, 34, 34),
//         textTheme: const TextTheme(
//           bodyMedium: TextStyle(color: Colors.white),
//         ),
//       ),
//       home: const SearchScreen(),
//     );
//   }
// }

// class MarvelApi {
//   static const String publicKey = '2773056a4ad55356f3e9604384e05462';
//   static const String privateKey = '6fa4c391abf04dd08a09f61f73b26e73dff8a53a';
//   static const String baseUrl = 'https://gateway.marvel.com/v1/public';

//   static String _generateHash(int timestamp) {
//     final bytes = utf8.encode('$timestamp$privateKey$publicKey');
//     return md5.convert(bytes).toString();
//   }

//   static Future<List<dynamic>> searchCharacters(String name) async {
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final hash = _generateHash(timestamp);
//     final url = Uri.parse(
//       '$baseUrl/characters?nameStartsWith=$name&apikey=$publicKey&ts=$timestamp&hash=$hash',
//     );
//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)['data']['results'] as List<dynamic>;
//     } else {
//       throw Exception('Failed to load characters');
//     }
//   }

//   static Future<List<dynamic>> searchCreators(String name) async {
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final hash = _generateHash(timestamp);
//     final url = Uri.parse(
//       '$baseUrl/creators?nameStartsWith=$name&apikey=$publicKey&ts=$timestamp&hash=$hash',
//     );
//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)['data']['results'] as List<dynamic>;
//     } else {
//       throw Exception('Failed to load creators');
//     }
//   }

//   static Future<Map<String, dynamic>> getCharacterDetails(int id) async {
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final hash = _generateHash(timestamp);
//     final url = Uri.parse(
//       '$baseUrl/characters/$id?apikey=$publicKey&ts=$timestamp&hash=$hash',
//     );
//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)['data']['results'][0];
//     } else {
//       throw Exception('Failed to load character details');
//     }
//   }

//   static Future<Map<String, dynamic>> getCreatorDetails(int id) async {
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final hash = _generateHash(timestamp);
//     final url = Uri.parse(
//       '$baseUrl/creators/$id?apikey=$publicKey&ts=$timestamp&hash=$hash',
//     );
//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)['data']['results'][0];
//     } else {
//       throw Exception('Failed to load creator details');
//     }
//   }
// }

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _characterController = TextEditingController();
//   final TextEditingController _creatorController = TextEditingController();
//   List<dynamic> _characterResults = [];
//   List<dynamic> _creatorResults = [];

//   void _searchCharacters() async {
//     final results = await MarvelApi.searchCharacters(_characterController.text);
//     setState(() {
//       _characterResults = results;
//     });
//   }

//   void _searchCreators() async {
//     final results = await MarvelApi.searchCreators(_creatorController.text);
//     setState(() {
//       _creatorResults = results;
//     });
//   }

//   void _showProfile(BuildContext context, int id, bool isCharacter) async {
//     final details = isCharacter
//         ? await MarvelApi.getCharacterDetails(id)
//         : await MarvelApi.getCreatorDetails(id);

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProfileScreen(details: details, isCharacter: isCharacter),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Marvel Character & Creator Search'),
//         backgroundColor: Colors.red,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _buildSearchBar(_characterController, 'Search Characters', _searchCharacters),
//             _buildSearchBar(_creatorController, 'Search Creators', _searchCreators),
//             const SizedBox(height: 16),
//             Expanded(
//               child: ListView(
//                 children: [
//                   _buildResultsSection('Character Results', _characterResults, true),
//                   _buildResultsSection('Creator Results', _creatorResults, false),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchBar(TextEditingController controller, String label, VoidCallback onSearch) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: controller,
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 labelText: label,
//                 labelStyle: const TextStyle(color: Colors.redAccent),
//                 border: const OutlineInputBorder(),
//                 filled: true,
//                 fillColor: Colors.grey[900],
//               ),
//             ),
//           ),
//           IconButton(
//             onPressed: onSearch,
//             icon: const Icon(Icons.search, color: Colors.red),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildResultsSection(String title, List<dynamic> results, bool isCharacter) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
//         ),
//         const SizedBox(height: 8),
//         for (var result in results)
//           ListTile(
//             title: Text(
//               isCharacter ? result['name'] : result['fullName'],
//               style: const TextStyle(color: Colors.white),
//             ),
//             onTap: () => _showProfile(context, result['id'], isCharacter),
//             trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),
//           ),
//       ],
//     );
//   }
// }

// class ProfileScreen extends StatelessWidget {
//   final Map<String, dynamic> details;
//   final bool isCharacter;

//   const ProfileScreen({super.key, required this.details, required this.isCharacter});

//   @override
//   Widget build(BuildContext context) {
//     final name = isCharacter ? details['name'] : details['fullName'];
//     final description = details['description'] ?? 'No description available';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(name),
//         backgroundColor: Colors.red,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               name,
//               style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.redAccent),
//             ),
//             const SizedBox(height: 8),
//             Text(description, style: const TextStyle(color: Colors.white)),
//             const SizedBox(height: 16),
//             const Text('Additional Information:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent)),
//             Text(isCharacter ? 'Events, series, and stories will go here.' : 'Works created will go here.', style: const TextStyle(color: Colors.white)),
//           ],
//         ),
//       ),
//     );
//   }
// }

/////
/// Above this is the first checkpoint
///////////////////////////////////////////