import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/app_strings.dart';

class EditProfileDialog extends StatefulWidget {
  final UserModel user;
  final void Function(String name, String email, String phone) onSave;

  const EditProfileDialog({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onSave(_nameController.text, _emailController.text, _phoneController.text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppStrings.editProfile),
      content: SingleChildScrollView(child: _buildForm()),
      actions: _buildActions(context),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: AppStrings.nameLabel),
            validator: AppValidators.validateName,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: AppStrings.emailLabel),
            validator: AppValidators.validateEmail,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(labelText: AppStrings.phoneLabel),
            validator: AppValidators.validatePhone,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(AppStrings.cancel),
      ),
      ElevatedButton(
        onPressed: _submit,
        child: Text(AppStrings.save),
      ),
    ];
  }
}
