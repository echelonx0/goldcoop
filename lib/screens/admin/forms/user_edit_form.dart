import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';
import '../services/admin_service.dart';

void showUserEditSheet(
  BuildContext context,
  UserModel user,
  VoidCallback onSave,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => UserEditBottomSheet(user: user, onSave: onSave),
  );
}

class UserEditBottomSheet extends StatefulWidget {
  final UserModel user;
  final VoidCallback onSave;

  const UserEditBottomSheet({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<UserEditBottomSheet> createState() => _UserEditBottomSheetState();
}

class _UserEditBottomSheetState extends State<UserEditBottomSheet>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _balanceController;
  late TextEditingController _investedController;
  late TextEditingController _returnsController;
  late TextEditingController _tokensController;

  late KYCStatus _kycStatus;
  late AccountStatus _accountStatus;

  bool _isSaving = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    final fp = widget.user.financialProfile;
    _balanceController = TextEditingController(
      text: fp.accountBalance.toString(),
    );
    _investedController = TextEditingController(
      text: fp.totalInvested.toString(),
    );
    _returnsController = TextEditingController(
      text: fp.totalReturns.toString(),
    );
    _tokensController = TextEditingController(text: fp.tokenBalance.toString());

    _kycStatus = widget.user.kycStatus;
    _accountStatus = widget.user.accountStatus;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _investedController.dispose();
    _returnsController.dispose();
    _tokensController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ==================== ENUM HELPER ====================
  String _getEnumName(dynamic enumValue) {
    return enumValue.toString().split('.').last;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA), // Premium background
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Premium drag handle
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Expanded(
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            DelayedDisplay(
                              delay: const Duration(milliseconds: 100),
                              child: _buildUserHeader(),
                            ),
                            const SizedBox(height: 24),
                            DelayedDisplay(
                              delay: const Duration(milliseconds: 200),
                              child: _buildFinancialSection(),
                            ),
                            const SizedBox(height: 20),
                            DelayedDisplay(
                              delay: const Duration(milliseconds: 300),
                              child: _buildStatusSection(),
                            ),
                            const SizedBox(height: 100), // Space for button
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),

                _buildSaveButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.deepNavy, AppColors.deepNavy.withAlpha(230)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withAlpha(38),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withAlpha(50),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.user.displayName.isNotEmpty
                        ? widget.user.displayName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.user.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withAlpha(204),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withAlpha(50)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fingerprint,
                  size: 14,
                  color: Colors.white.withAlpha(204),
                ),
                const SizedBox(width: 6),
                Text(
                  "UID: ${widget.user.uid.substring(0, 8)}...",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(204),
                    fontFamily: "monospace",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Financial Profile", Icons.account_balance_wallet),
            const SizedBox(height: 20),
            _buildPremiumField(
              controller: _balanceController,
              label: "Account Balance",
              prefix: "₦",
              icon: Icons.wallet,
              color: AppColors.primaryOrange,
            ),
            const SizedBox(height: 16),
            _buildPremiumField(
              controller: _investedController,
              label: "Total Invested",
              prefix: "₦",
              icon: Icons.trending_up,
              color: const Color(0xFF00B4D8),
            ),
            const SizedBox(height: 16),
            _buildPremiumField(
              controller: _returnsController,
              label: "Total Returns",
              prefix: "₦",
              icon: Icons.show_chart,
              color: const Color(0xFF10B981),
            ),
            const SizedBox(height: 16),
            _buildPremiumField(
              controller: _tokensController,
              label: "Token Balance",
              prefix: null,
              icon: Icons.token,
              color: const Color(0xFFF59E0B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Account Status", Icons.verified_user),
          const SizedBox(height: 20),
          _buildPremiumDropdown(
            value: _kycStatus,
            label: "KYC Status",
            icon: Icons.badge,
            items: KYCStatus.values,
            onChanged: (v) => setState(() => _kycStatus = v!),
            getColor: _getKycColor,
          ),
          const SizedBox(height: 16),
          _buildPremiumDropdown(
            value: _accountStatus,
            label: "Account Status",
            icon: Icons.account_circle,
            items: AccountStatus.values,
            onChanged: (v) => setState(() => _accountStatus = v!),
            getColor: _getAccountStatusColor,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.deepNavy.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.deepNavy),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.deepNavy,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumField({
    required TextEditingController controller,
    required String label,
    required String? prefix,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
          validator: (v) {
            if (v!.isEmpty) return "Required";
            if (double.tryParse(v) == null) return "Invalid number";
            return null;
          },
          decoration: InputDecoration(
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            prefixText: prefix,
            prefixStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumDropdown<T>({
    required T value,
    required String label,
    required IconData icon,
    required List<T> items,
    required void Function(T?) onChanged,
    required Color Function(T) getColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: getColor(value).withAlpha(50), width: 1),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: getColor(value).withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: getColor(value)),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: items.map((e) {
              final color = getColor(e);
              final enumName = _getEnumName(e);
              return DropdownMenuItem(
                value: e,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      enumName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: AppColors.primaryOrange.withAlpha(76),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _isSaving ? null : _handleSave,
            child: _isSaving
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        "Save Changes",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Color _getKycColor(KYCStatus status) {
    switch (status) {
      case KYCStatus.pending:
        return const Color(0xFF9CA3AF);
      case KYCStatus.verified:
        return const Color(0xFF10B981);
      case KYCStatus.rejected:
        return const Color(0xFFEF4444);
      case KYCStatus.submitted:
        return const Color(0xFF10B981);
      case KYCStatus.expired:
        return const Color(0xFFEF4444);
    }
  }

  Color _getAccountStatusColor(AccountStatus status) {
    switch (status) {
      case AccountStatus.active:
        return const Color(0xFF10B981);
      case AccountStatus.suspended:
        return const Color(0xFF9CA3AF);
      case AccountStatus.closed:
        return const Color(0xFF6B7280);
      case AccountStatus.locked:
        return const Color(0xFFEF4444);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await _adminService.updateUserFinancials(
        uid: widget.user.uid,
        accountBalance: double.parse(_balanceController.text),
        totalInvested: double.parse(_investedController.text),
        totalReturns: double.parse(_returnsController.text),
        tokenBalance: int.parse(_tokensController.text),
      );

      await _adminService.updateUserKYC(
        uid: widget.user.uid,
        status: _kycStatus,
      );

      await _adminService.updateUserStatus(
        uid: widget.user.uid,
        status: _accountStatus,
      );

      if (!mounted) return;

      setState(() => _isSaving = false);
      Navigator.pop(context);
      widget.onSave();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "User updated successfully",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: AppColors.tealSuccess,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Error: ${e.toString()}",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
