import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String apiUrl = 'https://digi-api.com/api/v1/digimon?pageSize=20';

  Future<List<dynamic>> fetchDigimonsJSON() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['content'] != null ? List.from(data['content']) : [];
      } else {
        throw Exception('Failed to load combat styles');
      }
    } catch (e) {
      throw Exception('Error fetching combat styles: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls: DIGIMON"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchDigimonsJSON(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No description available"));
          } else {
            final digimons = snapshot.data!;
            return ExpandedTileList.builder(
              itemCount: digimons.length,
              itemBuilder: (context, index, controller) {
                var digimon = digimons[index];
                return ExpandedTile(
                  controller: controller,
                  title: Text(digimon['name'] ?? 'Unknown'),
                  leading: digimon['image'] != null
                      ? Image.network(
                          digimon['image'],
                          width: 50,
                          height: 50,
                        )
                      : const Icon(Icons.image),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Link: ${digimon['href'] ?? 'No link available'}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: digimon['image'] != null
                              ? Image.network(
                                  digimon['image'],
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image, size: 50),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
