import 'package:chateo_app/core/presentation/widgets/app_input_phone_number.dart';
import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/core/utils/themes/app_colors.dart';
import 'package:chateo_app/generated/locale_keys.g.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../manager/contacts_bloc.dart';

class PutContactWidget extends StatefulWidget {
  const PutContactWidget({super.key});

  @override
  State<PutContactWidget> createState() => _PutContactWidgetState();
}

class _PutContactWidgetState extends State<PutContactWidget> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '## ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  bool _isSubmitEnabled = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_validateInputs);
    _phoneNumberController.addListener(_validateInputs);
  }

  void _validateInputs() {
    final hasFirstName = _firstNameController.text.trim().isNotEmpty;
    final hasPhone = _phoneMaskFormatter.getUnmaskedText().length == 9;
    final enabled = hasFirstName && hasPhone;
    if (enabled != _isSubmitEnabled) {
      setState(() {
        _isSubmitEnabled = enabled;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final unmaskedPhone = _phoneMaskFormatter.getUnmaskedText();
    final fullPhone = '+998$unmaskedPhone';

    context.read<ContactsBloc>().add(
      PutContactRequested(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: fullPhone,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<ContactsBloc, ContactsState>(
      listener: (context, state) {
        if (state is ContactPutSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Контакт успешно добавлен'),
              backgroundColor: AccentColor.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is ContactsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AccentColor.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          top: 12.h,
          bottom: 24.h + bottomInset,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Drag Handle ─────────────────────────────────────────────
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: context.appColors.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // ── Title ───────────────────────────────────────────────────
              Text(
                'Добавить контакт',
                style: context.appTextStyle.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 24.h),

              // ── First Name (TextFormField styled as in profile_page) ───
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  hintText: LocaleKeys.more_profileElement_firstName.tr(),
                ),
              ),

              SizedBox(height: 8.h),

              // ── Last Name (TextFormField styled as in profile_page) ────
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  hintText: LocaleKeys.more_profileElement_lastName.tr(),
                ),
              ),

              SizedBox(height: 12.h),

              // ── Phone Number Input ──────────────────────────────────────
              AppInputPhoneNumber(
                controller: _phoneNumberController,
                maskTextInputFormatter: _phoneMaskFormatter,
                onChanged: (_) => _validateInputs(),
              ),

              SizedBox(height: 24.h),

              // ── Save Button ─────────────────────────────────────────────
              ElevatedButton(
                onPressed: _isSubmitEnabled ? _onSubmit : null,
                child: Text(
                  LocaleKeys.save.tr(),
                  style: context.appTextStyle.headlineSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
