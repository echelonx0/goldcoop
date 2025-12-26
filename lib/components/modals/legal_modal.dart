// lib/components/modals/legal_modal.dart
// Animated modal for displaying Terms & Conditions and Privacy Policy

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/legal_content.dart';
import '../../core/theme/app_colors.dart';

/// Type of legal document to display
enum LegalDocumentType { terms, privacy }

/// Animated modal for displaying legal documents (Terms & Privacy)
class LegalModal extends StatefulWidget {
  final LegalDocumentType type;

  const LegalModal({super.key, required this.type});

  /// Shows the legal modal as a bottom sheet
  static Future<void> show(BuildContext context, LegalDocumentType type) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LegalModal(type: type),
    );
  }

  @override
  State<LegalModal> createState() => _LegalModalState();
}

class _LegalModalState extends State<LegalModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollIndicator = true;

  // Content based on type
  String get _title => widget.type == LegalDocumentType.terms
      ? LegalContent.termsTitle
      : LegalContent.privacyTitle;

  List<LegalSection> get _sections => widget.type == LegalDocumentType.terms
      ? LegalContent.termsSections
      : LegalContent.privacySections;

  DateTime get _effectiveDate => widget.type == LegalDocumentType.terms
      ? LegalContent.termsEffectiveDate
      : LegalContent.privacyEffectiveDate;

  DateTime get _lastUpdated => widget.type == LegalDocumentType.terms
      ? LegalContent.termsLastUpdated
      : LegalContent.privacyLastUpdated;

  String get _webUrl => widget.type == LegalDocumentType.terms
      ? LegalContent.termsUrl
      : LegalContent.privacyUrl;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _scrollController.addListener(_onScroll);
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && _showScrollIndicator) {
      setState(() => _showScrollIndicator = false);
    } else if (_scrollController.offset <= 50 && !_showScrollIndicator) {
      setState(() => _showScrollIndicator = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl() async {
    final uri = Uri.parse(_webUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppBorderRadius.large),
              topRight: Radius.circular(AppBorderRadius.large),
            ),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(),
              Expanded(child: _buildContent()),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.borderLight,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.deepNavy.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppBorderRadius.small),
                ),
                child: Icon(
                  widget.type == LegalDocumentType.terms
                      ? Icons.description_outlined
                      : Icons.privacy_tip_outlined,
                  color: AppColors.deepNavy,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: AppTextTheme.heading2.copyWith(
                        color: AppColors.deepNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      LegalContent.companyName,
                      style: AppTextTheme.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDateInfo(),
        ],
      ),
    );
  }

  Widget _buildDateInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.backgroundNeutral,
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Effective: ${_formatDate(_effectiveDate)}',
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(width: 1, height: 12, color: AppColors.borderLight),
          const SizedBox(width: AppSpacing.md),
          Icon(Icons.update_outlined, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Updated: ${_formatDate(_lastUpdated)}',
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final section = _sections[index];
                  return _buildSection(section, index);
                }, childCount: _sections.length),
              ),
            ),
          ],
        ),
        // Scroll indicator
        if (_showScrollIndicator)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildScrollIndicator(),
          ),
      ],
    );
  }

  Widget _buildSection(LegalSection section, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: AppTextTheme.heading3.copyWith(
                color: AppColors.deepNavy,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              section.content.trim(),
              style: AppTextTheme.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollIndicator() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundWhite.withAlpha(0),
            AppColors.backgroundWhite,
          ],
        ),
      ),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1000),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 4 * (0.5 - (value - 0.5).abs())),
              child: child,
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textTertiary,
                size: 20,
              ),
              Text(
                'Scroll for more',
                style: AppTextTheme.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.navyAccent.withAlpha(12),
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
                border: Border.all(color: AppColors.navyAccent.withAlpha(25)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.navyAccent,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'For the latest updates, visit ${LegalContent.websiteUrl}',
                      style: AppTextTheme.bodySmall.copyWith(
                        color: AppColors.navyAccent,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _launchUrl,
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Web'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.deepNavy,
                      side: BorderSide(color: AppColors.borderLight),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.small,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.small,
                        ),
                      ),
                    ),
                    child: const Text(
                      'I Understand',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
