import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cloud_done,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('API Connection',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ApiService.base,
                            style: const TextStyle(
                                fontFamily: 'monospace', fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'All your data is stored on your Hostinger server. '
                    'This web app reads and writes directly to the API — no local storage.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('About',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _Row(label: 'App', value: 'My Assistant'),
                  const _Row(label: 'Version', value: '1.0.0'),
                  const _Row(label: 'Platform', value: 'Flutter Web'),
                  const _Row(label: 'Hosted at',
                      value: 'app.sanlabs.in/assistant'),
                  const _Row(label: 'Backend',
                      value: 'Hostinger MySQL + PHP API'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.phone_android,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('Mobile App',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The Android app stores data locally (offline-first) and syncs '
                    'to this same server via the Push/Pull buttons in Settings.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
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

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
              child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
