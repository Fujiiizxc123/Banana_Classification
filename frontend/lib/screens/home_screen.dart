import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();
  List<ScanHistoryModel> _history = [];
  bool _loadingHistory = false;
  XFile? _selectedImage;

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

  // Launch camera
  Future<void> _openCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (photo != null) {
        setState(() => _selectedImage = photo);
        _showScanPreview(photo);
      }
    } catch (e) {
      _showErrorSnackbar('Could not open camera: $e');
    }
  }

  // Open gallery
  Future<void> _openGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null) {
        setState(() => _selectedImage = image);
        _showScanPreview(image);
      }
    } catch (e) {
      _showErrorSnackbar('Could not open gallery: $e');
    }
  }

  // Show bottom sheet with image preview + classify button
  void _showScanPreview(XFile image) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Banana Preview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF237227),
              ),
            ),

            const SizedBox(height: 16),

            // Image preview
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(image.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Coming soon banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD786).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFFFAA00).withOpacity(0.4),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Color(0xFFFFAA00), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'AI classification coming soon! Image captured successfully.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF237227),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Classify button (disabled — AI coming soon)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: null, // ← disabled until AI is ready
                  icon: const Icon(Icons.psychology_outlined),
                  label: const Text(
                    'Classify Banana (Coming Soon)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF519A66),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFF519A66).withOpacity(0.4),
                    disabledForegroundColor: Colors.white70,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Retake button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showImageSourceSheet();
                  },
                  icon: const Icon(Icons.refresh_rounded,
                      color: Color(0xFF237227)),
                  label: const Text(
                    'Retake / Choose Another',
                    style: TextStyle(
                      color: Color(0xFF237227),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF237227)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  // Show source picker: Camera or Gallery
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF237227),
              ),
            ),
            const SizedBox(height: 24),

            // Camera option
            _buildSourceOption(
              icon: Icons.camera_alt_rounded,
              label: 'Take a Photo',
              subtitle: 'Use your camera',
              onTap: () {
                Navigator.pop(ctx);
                _openCamera();
              },
            ),
            const SizedBox(height: 12),

            // Gallery option
            _buildSourceOption(
              icon: Icons.photo_library_rounded,
              label: 'Choose from Gallery',
              subtitle: 'Pick an existing photo',
              onTap: () {
                Navigator.pop(ctx);
                _openGallery();
              },
            ),

            const SizedBox(height: 12),

            // Cancel
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFF519A66),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD786).withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF519A66).withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF237227),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFFFD786), size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF237227),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF519A66),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Color(0xFF519A66), size: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            color: Color(0xFF237227),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF519A66)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFAA00),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Sign Out',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF237227),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD786),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text('🍌',
                                    style: TextStyle(fontSize: 22)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'BananaAI',
                              style: TextStyle(
                                color: Color(0xFFFFD786),
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _showLogoutDialog(context, auth),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF519A66).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: Color(0xFFFFD786),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Hello, ${auth.user?.name.split(' ').first ?? 'User'}! 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ready to classify some bananas?',
                      style: TextStyle(
                        color: Color(0xFF519A66),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        _buildStatCard(
                          '${_history.length}',
                          'Total Scans',
                          Icons.document_scanner_outlined,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          _history.isEmpty
                              ? 'N/A'
                              : _history.first.result,
                          'Last Result',
                          Icons.check_circle_outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Scan button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: GestureDetector(
              onTap: _showImageSourceSheet,
              child: Container(
                width: double.infinity,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFAA00), Color(0xFFFFD786)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFAA00).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_rounded,
                        color: Color(0xFF237227), size: 26),
                    SizedBox(width: 10),
                    Text(
                      'Scan a Banana',
                      style: TextStyle(
                        color: Color(0xFF237227),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // History header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scan History',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF237227),
                  ),
                ),
                GestureDetector(
                  onTap: _fetchHistory,
                  child: const Row(
                    children: [
                      Icon(Icons.refresh_rounded,
                          color: Color(0xFF519A66), size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Refresh',
                        style: TextStyle(
                          color: Color(0xFF519A66),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // History list
          Expanded(
            child: _loadingHistory
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF237227),
                    ),
                  )
                : _history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD786)
                                    .withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text('🍌',
                                    style: TextStyle(fontSize: 36)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No scans yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF237227),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tap "Scan a Banana" to get started',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF519A66),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(24, 0, 24, 32),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          return _buildHistoryCard(_history[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF519A66).withOpacity(0.25),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFFD786), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFFFFD786),
                      fontSize: 11,
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

  Widget _buildHistoryCard(ScanHistoryModel item) {
    final confidence = (item.confidence * 100).toStringAsFixed(1);
    final isHighConfidence = item.confidence >= 0.8;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD786).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🍌', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.result,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF237227),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.createdAt.length >= 10
                      ? item.createdAt.substring(0, 10)
                      : item.createdAt,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF519A66),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isHighConfidence
                  ? const Color(0xFF237227).withOpacity(0.1)
                  : const Color(0xFFFFAA00).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$confidence%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isHighConfidence
                    ? const Color(0xFF237227)
                    : const Color(0xFFFFAA00),
              ),
            ),
          ),
        ],
      ),
    );
  }
}