import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../services/admin_service.dart';

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
    transitionAnimationController: AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 300),
    ),
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

class _UserEditBottomSheetState extends State<UserEditBottomSheet> {
  final AdminService _adminService = AdminService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _balanceController;
  late TextEditingController _investedController;
  late TextEditingController _returnsController;
  late TextEditingController _tokensController;

  late KYCStatus _kycStatus;
  late AccountStatus _accountStatus;

  bool _isSaving = false;

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
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _investedController.dispose();
    _returnsController.dispose();
    _tokensController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.only(top: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUserHeader(),
                        const SizedBox(height: 24),
                        _sectionTitle("Financial Details"),

                        _buildField(_balanceController, "Account Balance", "₦"),
                        _spacer(),
                        _buildField(_investedController, "Total Invested", "₦"),
                        _spacer(),
                        _buildField(_returnsController, "Total Returns", "₦"),
                        _spacer(),
                        _buildField(_tokensController, "Token Balance", null),

                        const SizedBox(height: 24),
                        _sectionTitle("Account Status"),
                        _spacer(),

                        _buildKycDropdown(),
                        _spacer(),
                        _buildStatusDropdown(),
                        const SizedBox(height: 80), // space for the save button
                      ],
                    ),
                  ),
                ),
              ),

              _buildSaveButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTextTheme.heading2.copyWith(
        color: AppColors.deepNavy,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildUserHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.user.displayName,
          style: AppTextTheme.heading2.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.deepNavy,
          ),
        ),
        Text(
          widget.user.email,
          style: AppTextTheme.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          "UID: ${widget.user.uid}",
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontFamily: "monospace",
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String? prefix,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      validator: (v) {
        if (v!.isEmpty) return "Required";
        if (double.tryParse(v) == null) return "Invalid number";
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildKycDropdown() {
    return DropdownButtonFormField<KYCStatus>(
      value: _kycStatus,
      decoration: InputDecoration(
        labelText: "KYC Status",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: KYCStatus.values
          .map(
            (e) =>
                DropdownMenuItem(value: e, child: Text(e.name.toUpperCase())),
          )
          .toList(),
      onChanged: (v) => setState(() => _kycStatus = v!),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<AccountStatus>(
      value: _accountStatus,
      decoration: InputDecoration(
        labelText: "Account Status",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: AccountStatus.values
          .map(
            (e) =>
                DropdownMenuItem(value: e, child: Text(e.name.toUpperCase())),
          )
          .toList(),
      onChanged: (v) => setState(() => _accountStatus = v!),
    );
  }

  Widget _spacer() => const SizedBox(height: 16);

  Widget _buildSaveButton() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _isSaving ? null : _handleSave,
            child: _isSaving
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                : const Text("Save Changes"),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    await _adminService.updateUserFinancials(
      uid: widget.user.uid,
      accountBalance: double.parse(_balanceController.text),
      totalInvested: double.parse(_investedController.text),
      totalReturns: double.parse(_returnsController.text),
      tokenBalance: int.parse(_tokensController.text),
    );

    await _adminService.updateUserKYC(uid: widget.user.uid, status: _kycStatus);

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
        content: const Text("User updated successfully"),
        backgroundColor: AppColors.tealSuccess,
      ),
    );
  }
}
