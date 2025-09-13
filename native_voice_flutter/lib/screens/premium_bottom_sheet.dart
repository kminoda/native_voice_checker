import 'package:flutter/material.dart';
import 'package:native_voice_flutter/l10n/app_localizations.dart';
import 'package:native_voice_flutter/services/premium_service.dart';
import 'package:flutter/services.dart';

Future<void> showPremiumBottomSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      final surface = Theme.of(context).colorScheme.surface;
      final subtle = Colors.white60;

      return FractionallySizedBox(
        heightFactor: 0.75,
        child: _PremiumSheet(surface: surface, subtle: subtle),
      );
    },
  );
}

class _PremiumSheet extends StatefulWidget {
  const _PremiumSheet({required this.surface, required this.subtle});
  final Color surface;
  final Color subtle;

  @override
  State<_PremiumSheet> createState() => _PremiumSheetState();
}

class _PremiumSheetState extends State<_PremiumSheet> {
  final PremiumService _svc = PremiumService.instance;

  @override
  void initState() {
    super.initState();
    _svc.addListener(_onUpdate);
    // Best-effort configure/price
    _svc.ensureConfigured();
  }

  @override
  void dispose() {
    _svc.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = _svc.isPremium;
    final isLoading = _svc.isLoading;
    final price = _svc.price; // like "¥480"

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeaderArt(),
            const SizedBox(height: 16),

            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.premiumPlan,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                if (isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.6)),
                    ),
                    child: Text(AppLocalizations.of(context)!.subscribed, style: const TextStyle(color: Colors.greenAccent)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.premiumDescription,
              style: TextStyle(color: widget.subtle, height: 1.4),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                children: [
                  _FeatureRow(icon: Icons.block, label: AppLocalizations.of(context)!.featureNoAds),
                  const SizedBox(height: 12),
                  _FeatureRow(icon: Icons.all_inclusive_rounded, label: AppLocalizations.of(context)!.featureUnlimited),
                ],
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isPremium || isLoading
                    ? null
                    : () async {
                        HapticFeedback.mediumImpact();
                        final ok = await _svc.purchaseMonthly();
                        if (ok) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.thanksPremium)),
                          );
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.purchaseFailed)),
                          );
                        }
                      },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    isPremium
                        ? AppLocalizations.of(context)!.subscribed
                        : (isLoading
                            ? AppLocalizations.of(context)!.processing
                            : (price != null
                                ? AppLocalizations.of(context)!.subscribeMonthlyWithPrice(price)
                                : AppLocalizations.of(context)!.subscribeMonthly)),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        HapticFeedback.selectionClick();
                        final ok = await _svc.restore();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? AppLocalizations.of(context)!.restoreSuccess
                                : AppLocalizations.of(context)!.restoreFailed),
                          ),
                        );
                      },
                child: Text(AppLocalizations.of(context)!.restorePurchases),
              ),
            ),

            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.subscriptionNote,
              style: TextStyle(color: widget.subtle, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
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
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.white70, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Builder(
                      builder: (context) => Text(
                        AppLocalizations.of(context)!.upgradeTagline,
                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
