import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../models/scan_history_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  List<ScanHistoryModel> _history = [];
  bool _loadingHistory = false;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _loadingHistory = true);
    final data = await _authService.getHistory();
    setState(() {
      _history = data.map((e) => ScanHistoryModel.fromJson(e)).toList();
      _loadingHistory = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Banana Classifier'),
        backgroundColor: Colors.yellow,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${auth.user?.name ?? ''}!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Scan History', style: TextStyle(fontSize: 16)),
            const Divider(),
            Expanded(
              child: _loadingHistory
                  ? const Center(child: CircularProgressIndicator())
                  : _history.isEmpty
                  ? const Center(child: Text('No scan history yet'))
                  : ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final item = _history[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.local_florist,
                            color: Colors.yellow,
                          ),
                          title: Text(item.result),
                          subtitle: Text(
                            'Confidence: ${(item.confidence * 100).toStringAsFixed(1)}%',
                          ),
                          trailing: Text(item.createdAt.substring(0, 10)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Hook up camera + Python model later
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Camera coming soon!')));
        },
        backgroundColor: Colors.yellow,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scan Banana'),
      ),
    );
  }
}
