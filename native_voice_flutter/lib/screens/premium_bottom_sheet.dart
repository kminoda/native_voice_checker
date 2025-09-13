import 'package:flutter/material.dart';

Future<void> showPremiumBottomSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: false,
    builder: (context) {
      final surface = Theme.of(context).colorScheme.surface;
      final subtle = Colors.white60;

      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header visual
              const _HeaderArt(),
              const SizedBox(height: 16),

              // Title & subtitle
              const Text(
                'プレミアムプラン',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'ネイティブの練習に集中できる最適な環境を。広告なしで快適、音声生成は回数制限なく使い放題。',
                style: TextStyle(color: subtle, height: 1.4),
              ),
              const SizedBox(height: 16),

              // Features card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  children: const [
                    _FeatureRow(icon: Icons.block, label: '広告なし'),
                    SizedBox(height: 12),
                    _FeatureRow(icon: Icons.all_inclusive_rounded, label: '音声回数制限なし'),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Monthly plan CTA (subscription only)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('サブスクの購入は後日対応予定です')),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text('月額プランに登録 (準備中)', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Secondary actions
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('閉じる'),
                ),
              ),

              const SizedBox(height: 4),
              Text(
                'サブスクリプションのみ対応（単発購入は非対応）。価格と購入フローは後日公開予定です。',
                style: TextStyle(color: subtle, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _HeaderArt extends StatelessWidget {
  const _HeaderArt();

  @override
  Widget build(BuildContext context) {
    final border = BorderRadius.circular(16);
    return ClipRRect(
      borderRadius: border,
      child: Container(
        height: 148,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1F2937), Color(0xFF374151)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.workspace_premium_rounded,
                color: Colors.amber.shade300,
                size: 72,
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Row(
                children: const [
                  Icon(Icons.stars_rounded, color: Colors.white70, size: 18),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '快適な学習体験をアップグレード',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.lightGreenAccent, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
