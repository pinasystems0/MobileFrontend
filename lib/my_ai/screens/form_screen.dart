import 'package:flutter/material.dart';
import 'package:pina/services/session_service.dart';

import '../config/widget_configs.dart';
import '../models/widget_model.dart';
import '../services/myai_api_service.dart';
import '../widgets/history_sidebar.dart';
import '../widgets/myai_glass_widgets.dart';
import '../widgets/widget_response_formatters.dart';

class FormScreen extends StatefulWidget {
  final WidgetModel widgetItem;
  final String userEmail;

  const FormScreen({
    super.key,
    required this.widgetItem,
    required this.userEmail,
  });

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final MyAiApiService _service = myAiService;
  final TextEditingController _inputController = TextEditingController();

  String _output = '';
  bool _isLoading = false;
  int _historyRefreshToken = 0;
  String? _userId;

  WidgetConfig get _presentation => resolveWidgetConfigForWidget(widget.widgetItem);

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final userId = await SessionService.getUserId();
    if (!mounted) return;
    setState(() => _userId = userId);
  }

  Future<void> _saveHistory(String prompt, String content) async {
    await _service.saveHistory(widget.userEmail, {
      'type': _presentation.type,
      'widgetType': widget.widgetItem.widgetName,
      'widgetName': widget.widgetItem.widgetName,
      'widgetKey': widget.widgetItem.widgetKey,
      'prompt': prompt,
      'content': content,
      'modelName': widget.widgetItem.widgetName,
      'inputParams': {
        'apiEndpoint': _presentation.apiEndpoint,
        'inputType': _presentation.inputType,
        'screenType': _presentation.screenType,
        'outputTemplate': _presentation.outputTemplate,
      },
    });
  }

  Future<void> _execute() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter input first.')),
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
        userId: _userId,
      );

      final rendered = formatWidgetOutput(
        extractReadableWidgetOutput(result),
        _presentation,
      );

      if (!mounted) return;
      setState(() => _output = rendered);

      await _saveHistory(input, rendered);
      if (mounted) {
        setState(() => _historyRefreshToken += 1);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', 'Operation failed: '),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyHistory(Map<String, dynamic> history) {
    setState(() {
      _inputController.text = history['prompt']?.toString() ?? '';
      _output = history['content']?.toString() ?? '';
    });
  }

  void _openHistorySheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: HistorySidebar(
          userEmail: widget.userEmail,
          widgetType: widget.widgetItem.widgetName,
          refreshToken: _historyRefreshToken,
          onHistorySelected: _applyHistory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return MyAiGlassScreen(
      // ✅ FIX 1: Force correct title from widget name
      title: widget.widgetItem.widgetName.isNotEmpty
          ? widget.widgetItem.widgetName
          : _presentation.heading,
      subtitle: _presentation.description,
      actions: [
        _FormHeaderAction(
          icon: Icons.history_rounded,
          onPressed: _openHistorySheet,
        ),
      ],
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: viewInsets),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                MyAiMetaChip(icon: Icons.edit_note_rounded, label: _presentation.screenType),
                MyAiMetaChip(icon: Icons.category_rounded, label: _presentation.category),
                MyAiMetaChip(icon: Icons.output_rounded, label: _presentation.outputTitle),
              ],
            ),
            const SizedBox(height: 18),
            MyAiGlassPanel(
              child: TextField(
                controller: _inputController,
                enabled: !_isLoading,
                minLines: 6,
                maxLines: 10,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: _presentation.inputLabel,
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.72)),
                  // ✅ OPTIONAL IMPROVEMENT: Safe hint text
                  hintText: _presentation.inputLabel.isNotEmpty
                      ? 'Enter ${_presentation.inputLabel.toLowerCase()}...'
                      : 'Enter your input...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.52)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: MyAiGradientButton(
                onPressed: _isLoading ? null : _execute,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    else
                      const Icon(Icons.play_arrow_rounded, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      // ✅ FIX 2: Use widget name for button text
                      _isLoading ? 'Processing...' : 'Run ${widget.widgetItem.widgetName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            MyAiGlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _presentation.outputTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    _output.isEmpty
                        ? 'Your formatted result will appear here.'
                        : _output,
                    style: TextStyle(
                      color: Colors.white.withOpacity(_output.isEmpty ? 0.72 : 1),
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
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

class _FormHeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _FormHeaderAction({
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