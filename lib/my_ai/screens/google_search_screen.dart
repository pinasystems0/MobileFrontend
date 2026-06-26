import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/widget_model.dart';
import '../services/myai_api_service.dart';

class GoogleSearchScreen extends StatefulWidget {
  final WidgetModel widgetItem;
  final String userEmail;

  const GoogleSearchScreen({
    super.key,
    required this.widgetItem,
    required this.userEmail,
  });

  @override
  State<GoogleSearchScreen> createState() => _GoogleSearchScreenState();
}

class _GoogleSearchScreenState extends State<GoogleSearchScreen> {
  final MyAiApiService _service = myAiService;
  final TextEditingController _inputController = TextEditingController();

  String _output = '';
  bool _isLoading = false;

  Future<void> _executeSearch() async {
    final input = _inputController.text.trim();

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a search query')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _output = '';
    });

    try {
      final result = await _service.callWidget(
        widget: widget.widgetItem,
        userEmail: widget.userEmail,
        input: input,
      );

      final data = result['data'] ?? result;

      if (mounted) {
        setState(() {
          _output = jsonEncode(data);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(widget.widgetItem.widgetName),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: viewInsets),
          child: Column(
            children: [
              TextField(
                controller: _inputController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Search query',
                  hintText: 'Enter your search query...',
                  prefixIcon: Icon(Icons.search_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _executeSearch,
                    icon: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.search_rounded),
                    label: Text(
                      _isLoading ? 'Searching...' : 'Search',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Expanded(
                child: Card(
                  elevation: 2,
                  child: _output.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Results will appear here',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: SelectableText(
                            _output,
                            style: const TextStyle(fontSize: 14),
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

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}

