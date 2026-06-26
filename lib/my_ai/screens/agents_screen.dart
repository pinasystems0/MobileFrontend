import 'package:flutter/material.dart';

import '../widgets/myai_glass_widgets.dart';
import 'list_screen.dart';

class AgentsScreen extends StatelessWidget {
  const AgentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const agents = <_AgentDescriptor>[
      _AgentDescriptor(
        title: 'Research Agent',
        subtitle: 'Aggregates findings, summaries, and action-ready notes for complex topics.',
        category: 'Research',
        status: 'Coming Soon',
      ),
      _AgentDescriptor(
        title: 'Study Coach',
        subtitle: 'Guides revision plans, chapter sequencing, and quick review routines.',
        category: 'Study',
        status: 'Coming Soon',
      ),
      _AgentDescriptor(
        title: 'Workflow Agent',
        subtitle: 'Chains widgets together into reusable upload, analysis, and response flows.',
        category: 'Automation',
        status: 'Architecture Ready',
      ),
    ];

    return ListScreen(
      title: 'Agents',
      subtitle: 'A separate section for future multi-step assistants that can plug into the same shared-screen system.',
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const MyAiGlassPanel(
            child: Text(
              'Agents are separated from widgets so future autonomous workflows can scale without overloading the core MyAI home screen.',
              style: TextStyle(color: Colors.white, height: 1.5),
            ),
          ),
          const SizedBox(height: 18),
          for (final agent in agents)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MyAiGlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        MyAiMetaChip(icon: Icons.smart_toy_rounded, label: agent.category),
                        MyAiMetaChip(icon: Icons.bolt_rounded, label: agent.status),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      agent.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      agent.subtitle,
                      style: TextStyle(color: Colors.white.withOpacity(0.74), height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AgentDescriptor {
  final String title;
  final String subtitle;
  final String category;
  final String status;

  const _AgentDescriptor({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.status,
  });
}
