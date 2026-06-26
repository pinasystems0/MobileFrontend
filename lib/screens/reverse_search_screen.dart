import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pina/credit/toolmanagerscreen.dart';
import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class ReverseSearchScreen extends StatefulWidget {
  const ReverseSearchScreen({super.key});

  @override
  State<ReverseSearchScreen> createState() => _ReverseSearchScreenState();
}

class _ReverseSearchScreenState extends State<ReverseSearchScreen> {
  final GlobalKey<ToolManagerScreenState> toolManagerKey =
      GlobalKey<ToolManagerScreenState>();

  late TextEditingController _imageUrlController;
  bool _isLoading = false;
  bool _hasSearched = false;
  List<dynamic> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _imageUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _performReverseSearch() async {
    if (_imageUrlController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
      _hasSearched = true;
    });

    try {
      if (await SessionService.getUserId() == null) {
        throw Exception("User not logged in");
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.authUrl}/api/image-search'),
        headers: await SessionService.authHeaders(includeJsonContentType: true),
        body: jsonEncode({
          "query": _imageUrlController.text.trim(),
        }),
      );

      if (response.statusCode == 402) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Insufficient Balance! Please buy credits."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final payload = (data['data'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};

        setState(() {
          _searchResults = payload['results'] ?? [];
        });
        toolManagerKey.currentState?.fetchBalance();
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TemplateBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Reverse Image Search'),
          backgroundColor: TemplateTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ToolManagerScreen(
                    key: toolManagerKey,
                    requiredCredits: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _imageUrlController,
                    maxLines: null,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Enter Image URL',
                      hintText: 'https://example.com/image.jpg',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: Icon(
                        Icons.link,
                        color: TemplateTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading || _imageUrlController.text.isEmpty
                          ? null
                          : _performReverseSearch,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(
                        _isLoading ? "Searching..." : "Find Similar Images",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TemplateTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Builder(
                      builder: (context) {
                        if (_isLoading) {
                          return Center(
                            child: Text(
                              "Searching...",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          );
                        }
                        if (_hasSearched && _searchResults.isEmpty) {
                          return const Center(
                            child: Text(
                              "No similar results found.",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        if (!_hasSearched && _searchResults.isEmpty) {
                          return Center(
                            child: Text(
                              "Enter an image URL to start.",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            final title = result['title'] ?? 'Similar Image';
                            final url = result['pageUrl'] ?? '';
                            final thumb = result['imageUrl'] ?? '';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: TemplateTheme.border,
                                ),
                              ),
                              child: ListTile(
                                leading: thumb.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          thumb,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, o, s) =>
                                              const Icon(Icons.image),
                                        ),
                                      )
                                    : const Icon(Icons.link),
                                title: Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  url,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}