import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/session_service.dart';
import '../models/study_content_model.dart';
import '../services/myai_api_service.dart';
import '../widgets/myai_glass_widgets.dart';

class ReadyContentScreen extends StatefulWidget {
  final String? userEmail;

  const ReadyContentScreen({
    super.key,
    this.userEmail,
  });

  @override
  State<ReadyContentScreen> createState() => _ReadyContentScreenState();
}

class _ReadyContentScreenState extends State<ReadyContentScreen> {
  final MyAiApiService _service = myAiService;

  List<StudyContentModel> _content = <StudyContentModel>[];
  bool _loading = false;
  String? _userEmail;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContent(showLoader: true);
  }

  Future<String> _resolveUserEmail() async {
    final directEmail = widget.userEmail?.trim() ?? '';
    if (directEmail.isNotEmpty) {
      _userEmail = directEmail;
      return directEmail;
    }

    final sessionEmail = (await SessionService.getUserEmail())?.trim() ?? '';
    if (sessionEmail.isNotEmpty) {
      _userEmail = sessionEmail;
      return sessionEmail;
    }

    throw Exception('User email is missing.');
  }

  Future<void> _loadContent({bool showLoader = false}) async {
    if (showLoader && mounted) {
      setState(() => _loading = true);
    }

    try {
      final email = _userEmail ?? await _resolveUserEmail();
      final response = await _service.getContent(
        email,
        status: 'completed',
        limit: 200,
      );
      final content = response
          .whereType<Map>()
          .map((item) => StudyContentModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _content = content;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _getUserFriendlyErrorMessage(error);
      });
    } finally {
      if (showLoader && mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _getUserFriendlyErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('<!doctype') ||
        errorString.contains('html') && errorString.contains('formatexception')) {
      return 'Server error. Please try again later.';
    }

    if (error is FormatException) {
      if (errorString.contains('<!doctype') || errorString.contains('html')) {
        return 'Unable to load content. Server responded with an error page.';
      }
      return 'Unable to process server response. Please try again.';
    }

    if (errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'No internet connection. Please check your network.';
    }

    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    return 'Unable to load ready content. Please try again.';
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openPdf(StudyContentModel item) async {
    final pdfUrl = item.pdfUrl.trim();
    if (pdfUrl.isEmpty) {
      _showMessage('PDF not available for this item.');
      return;
    }

    final uri = Uri.tryParse(pdfUrl);
    final hasValidScheme =
        uri != null && (uri.scheme.toLowerCase() == 'http' || uri.scheme.toLowerCase() == 'https');

    if (!hasValidScheme) {
      _showMessage('Invalid PDF link.');
      return;
    }

    final opened = await launchUrl(uri!, mode: LaunchMode.externalApplication);
    if (!opened) {
      _showMessage('Could not open PDF.');
    }
  }

  List<_ChapterBundle> _buildChapterBundles() {
    final grouped = <String, _ChapterBundle>{};

    for (final item in _content) {
      final key = [
        item.board,
        item.standard,
        item.subjectName,
        item.chapterName,
      ].join('|');

      grouped.putIfAbsent(
        key,
        () => _ChapterBundle(
          board: item.board,
          standard: item.standard,
          subjectName: item.subjectName,
          chapterName: item.chapterName,
        ),
      );
      grouped[key]!.items.add(item);
    }

    final bundles = grouped.values.toList(growable: false);
    bundles.sort((a, b) {
      final subjectCompare = a.subjectName.toLowerCase().compareTo(b.subjectName.toLowerCase());
      if (subjectCompare != 0) return subjectCompare;
      return a.chapterName.toLowerCase().compareTo(b.chapterName.toLowerCase());
    });
    return bundles;
  }

  String _sectionTitle(String key) {
    switch (key) {
      case 'summary':
        return 'Chapter Summary';
      case 'notes':
        return 'Short Notes';
      case 'mcq':
        return 'MCQ Test';
      case 'test':
        return 'Practice Questions';
      default:
        return key;
    }
  }

  Widget _buildHeroPanel() {
    final chapterCount = _buildChapterBundles().length;
    final pdfCount = _content.where((item) => item.hasPdf).length;

    return MyAiGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Study PDFs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap the PDF icon to open or download each study file. Raw content is hidden in this screen.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.76),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MyAiMetaChip(icon: Icons.menu_book_rounded, label: '$chapterCount chapters'),
              MyAiMetaChip(icon: Icons.picture_as_pdf_rounded, label: '$pdfCount PDFs'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPdfRow(StudyContentModel item, {required bool isLast}) {
    final canOpen = item.hasPdf;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            title: Text(
              _sectionTitle(item.sectionKey),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                canOpen ? 'Open PDF' : 'PDF URL missing',
                style: TextStyle(
                  color: canOpen ? const Color(0xFF9BE7FF) : Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),
            trailing: IconButton(
              onPressed: canOpen ? () => _openPdf(item) : null,
              icon: Icon(
                Icons.picture_as_pdf_rounded,
                size: 30,
                color: canOpen ? const Color(0xFFFF6B6B) : Colors.white38,
              ),
              tooltip: canOpen ? 'Open PDF' : 'PDF unavailable',
            ),
          ),
        ),
        if (!isLast) const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildChapterCard(_ChapterBundle bundle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: MyAiGlassPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bundle.subjectName,
              style: const TextStyle(
                color: Color(0xFF9BE7FF),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              bundle.chapterName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${bundle.board}  •  ${bundle.standard}',
              style: TextStyle(color: Colors.white.withOpacity(0.72)),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16),
            ...bundle.sortedItems.asMap().entries.map(
              (entry) => _buildPdfRow(
                entry.value,
                isLast: entry.key == bundle.sortedItems.length - 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _content.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_error != null && _content.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.white.withOpacity(0.6),
              ),
              const SizedBox(height: 20),
              const Text(
                'Unable to load ready content',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              MyAiGradientButton(
                onPressed: () => _loadContent(showLoader: true),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bundles = _buildChapterBundles();
    if (bundles.isEmpty) {
      return const MyAiEmptyState(
        icon: Icons.picture_as_pdf_outlined,
        title: 'No study PDFs yet',
        subtitle: 'PDFs will appear here after the web batch job stores completed content with valid PDF URLs.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadContent(showLoader: false),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeroPanel(),
          const SizedBox(height: 18),
          ...bundles.map(_buildChapterCard),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyAiGlassScreen(
      title: 'Ready Content',
      subtitle: 'Open study PDFs fetched from the backend.',
      actions: [
        _ReadyContentAction(
          icon: Icons.refresh_rounded,
          onPressed: () => _loadContent(showLoader: true),
        ),
      ],
      child: _buildBody(),
    );
  }
}

class _ChapterBundle {
  final String board;
  final String standard;
  final String subjectName;
  final String chapterName;
  final List<StudyContentModel> items = <StudyContentModel>[];

  _ChapterBundle({
    required this.board,
    required this.standard,
    required this.subjectName,
    required this.chapterName,
  });

  List<StudyContentModel> get sortedItems {
    const order = ['summary', 'notes', 'mcq', 'test'];
    return items.toList()
      ..sort((a, b) {
        final indexA = order.indexOf(a.sectionKey);
        final indexB = order.indexOf(b.sectionKey);
        if (indexA == -1 && indexB == -1) return a.sectionKey.compareTo(b.sectionKey);
        if (indexA == -1) return 1;
        if (indexB == -1) return -1;
        return indexA.compareTo(indexB);
      });
  }
}

class _ReadyContentAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ReadyContentAction({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
