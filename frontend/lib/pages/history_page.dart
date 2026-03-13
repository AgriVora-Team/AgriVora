import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _isLoading = true;
  String? _errorMsg;
  List<dynamic> _historyItems = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final result = await ApiService.getUserHistory();
      if (!mounted) return;

      setState(() {
        _historyItems = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMsg = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final bottomPad = media.padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF2E8D5),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_fields.png',
              fit: BoxFit.cover,
            ),
          ),
          _buildTopHeader(context),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: _HistoryWaveClipper(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: double.infinity,
                  height: size.height * 0.88,
                  padding: EdgeInsets.fromLTRB(16, 120, 16, bottomPad + 70),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2E8D5).withOpacity(0.68),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_showDashboard) _buildSummaryDashboard(),
                      if (_showDashboard) const SizedBox(height: 16),
                      Expanded(child: _buildContent()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _showDashboard =>
      !_isLoading && _historyItems.isNotEmpty && _errorMsg == null;

  Widget _buildTopHeader(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 55,
      left: 24,
      right: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Prediction History",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Your Soil & Crop Analysis Records",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 8,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: const Icon(Icons.history, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryDashboard() {
    final topCrop = _getTopCrop();
    final lastSync = _getLastSyncDate();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Analytics Overview",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1B1B1B),
              ),
            ),
            InkWell(
              onTap: _loadHistory,
              child: const Icon(
                Icons.refresh,
                color: Color(0xFF2E7D32),
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMiniCard(
                Icons.analytics,
                "Total Predicts",
                _historyItems.length.toString(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: _buildMiniCard(Icons.eco, "Top Crop", topCrop)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMiniCard(Icons.healing, "Avg Health", "Good"),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniCard(Icons.event, "Last Analysis", lastSync),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3EA).withOpacity(0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B1B1B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return _buildLoadingState();
    if (_errorMsg != null) return _buildErrorState();
    if (_historyItems.isEmpty) return _buildEmptyState();

    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(top: 4, bottom: 20),
      itemCount: _historyItems.length,
      itemBuilder: (context, index) {
        final item = _historyItems[index] as Map<String, dynamic>;
        return _buildHistoryCard(item);
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFF2E7D32)),
          SizedBox(height: 16),
          Text(
            "Loading history...",
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
            const SizedBox(height: 16),
            const Text(
              "Failed to Load",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMsg!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadHistory,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text("Retry", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.analytics_outlined,
              size: 50,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Analysis Records Yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B1B1B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Start a soil analysis to generate\ncrop recommendations.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/manual-soil');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Start Analysis",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final isTexture = item.containsKey("texture");
    final dateInfo = _extractDateTime(item);
    final accent = isTexture
        ? const Color(0xFF795548)
        : const Color(0xFF2E7D32);
    final icon = isTexture ? Icons.science_rounded : Icons.eco_rounded;
    final type = isTexture ? "Soil Analysis" : "Crop Recommendation";
    final topCrop = _extractCardTopCrop(item);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {},
      onLongPress: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF3EA).withOpacity(0.65),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: accent,
                        ),
                      ),
                      Text(
                        "${dateInfo["date"]} • ${dateInfo["time"]}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Good",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 10),
            if (isTexture) ...[
              _infoField("Soil Texture", item['texture']?.toString() ?? 'N/A'),
              _infoField(
                "Water Capacity",
                item['water_capacity']?.toString() ?? 'N/A',
              ),
              _infoField("Drainage", item['drainage']?.toString() ?? 'N/A'),
            ] else ...[
              Row(
                children: [
                  Expanded(child: _infoField("Top Crop", topCrop)),
                  Expanded(child: _infoField("Suitability", "92%")),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _infoField(
                      "Soil pH",
                      item['ph']?.toString() ?? 'N/A',
                    ),
                  ),
                  Expanded(
                    child: _infoField(
                      "Soil Type",
                      item['soil_type']?.toString() ?? 'Unknown',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B1B1B),
            ),
          ),
        ],
      ),
    );
  }

  String _getTopCrop() {
    final Map<String, int> counts = {};

    for (final item in _historyItems) {
      if (item['results'] != null &&
          item['results'] is List &&
          (item['results'] as List).isNotEmpty) {
        final crop = (item['results'] as List).first.toString();
        counts[crop] = (counts[crop] ?? 0) + 1;
      } else if (item['crop'] != null) {
        final crop = item['crop'].toString();
        counts[crop] = (counts[crop] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) return "None";
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String _getLastSyncDate() {
    if (_historyItems.isEmpty) return "N/A";

    final first = _historyItems.first as Map<String, dynamic>;
    if (!first.containsKey("createdAt")) return "N/A";

    try {
      if (first['createdAt'] is String) {
        final dt = DateTime.parse(first['createdAt']).toLocal();
        return "${dt.day}/${dt.month}/${dt.year}";
      }

      if (first['createdAt'] is Map && first['createdAt']['_seconds'] != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch(
          first['createdAt']['_seconds'] * 1000,
        ).toLocal();
        return "${dt.day}/${dt.month}/${dt.year}";
      }
    } catch (_) {}

    return "N/A";
  }

  Map<String, String> _extractDateTime(Map<String, dynamic> item) {
    String dateStr = "Unknown Date";
    String timeStr = "";

    if (!item.containsKey("createdAt")) {
      return {"date": dateStr, "time": timeStr};
    }

    try {
      if (item['createdAt'] is String) {
        final dt = DateTime.parse(item['createdAt']).toLocal();
        dateStr = "${dt.day}/${dt.month}/${dt.year}";
        timeStr = "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
      } else if (item['createdAt'] is Map &&
          item['createdAt']['_seconds'] != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch(
          item['createdAt']['_seconds'] * 1000,
        ).toLocal();
        dateStr = "${dt.day}/${dt.month}/${dt.year}";
        timeStr = "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
      }
    } catch (_) {}

    return {"date": dateStr, "time": timeStr};
  }

  String _extractCardTopCrop(Map<String, dynamic> item) {
    if (item['results'] != null &&
        item['results'] is List &&
        (item['results'] as List).isNotEmpty) {
      return (item['results'] as List).first.toString();
    }

    if (item['crop'] != null) {
      return item['crop'].toString();
    }

    return "N/A";
  }
}

class _HistoryWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 115);
    path.quadraticBezierTo(size.width * 0.22, 35, size.width * 0.52, 98);
    path.quadraticBezierTo(size.width * 0.82, 160, size.width, 85);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
