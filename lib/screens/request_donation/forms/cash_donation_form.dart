import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/cubit/cash_donation_cubit.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/cubit/cash_donation_state.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/widgets/donation_card.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/widgets/compact_text_field.dart';

class CashDonationForm extends StatelessWidget {
  const CashDonationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CashDonationCubit(),
      child: const _CashDonationFormBody(),
    );
  }
}

class _CashDonationFormBody extends StatelessWidget {
  const _CashDonationFormBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CashDonationCubit, CashDonationState>(
      listener: (context, state) {
        if (state.status == DonationSubmitStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Request submitted!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state.status == DonationSubmitStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
          context.read<CashDonationCubit>().clearError();
        }
      },
      builder: (context, state) {
        final cubit = context.read<CashDonationCubit>();
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          children: [
            // Basic Info
            DonationCard(
              icon: Icons.info_outline,
              iconColor: Color(0xFF1E88E5),
              title: 'Basic Information',
              child: Column(
                children: [
                  CompactTextField(
                    label: 'Title',
                    hint: 'e.g., Help for medical emergency',
                    value: state.title,
                    onChanged: cubit.updateTitle,
                  ),
                  SizedBox(height: 12),
                  CompactTextField(
                    label: 'Description',
                    hint: 'Explain why you need assistance...',
                    value: state.description,
                    maxLines: 3,
                    onChanged: cubit.updateDescription,
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

            // Amount
            DonationCard(
              icon: Icons.currency_rupee,
              iconColor: Color(0xFF43A047),
              title: 'Amount Details',
              child: Column(
                children: [
                  CompactTextField(
                    label: 'Amount Needed (₹)',
                    hint: '0.00',
                    value: state.amount,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: Icons.currency_rupee,
                    onChanged: cubit.updateAmount,
                  ),
                  SizedBox(height: 12),
                  CompactTextField(
                    label: 'UPI ID',
                    hint: 'yourname@upi',
                    value: state.upiId,
                    prefixIcon: Icons.account_balance_wallet,
                    onChanged: cubit.updateUpiId,
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

            // Photos
            DonationCard(
              icon: Icons.camera_alt,
              iconColor: Color(0xFFFF7043),
              title: 'Proof Images (Optional)',
              child: _ImagePicker(
                images: state.images,
                onPick: cubit.pickImages,
                onRemove: cubit.removeImage,
              ),
            ),
            SizedBox(height: 12),

            // Deadline
            DonationCard(
              icon: Icons.calendar_today,
              iconColor: Color(0xFF7B1FA2),
              title: 'Deadline (Optional)',
              child: _DeadlinePicker(
                deadline: state.deadline,
                onSelect: cubit.setDeadline,
              ),
            ),
            SizedBox(height: 24),

            // Submit
            _SubmitButton(
              isLoading: state.status == DonationSubmitStatus.loading,
              onPressed: cubit.submit,
            ),
            SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

class _ImagePicker extends StatelessWidget {
  final List<File> images;
  final VoidCallback onPick;
  final Function(int) onRemove;

  const _ImagePicker({
    required this.images,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (images.isNotEmpty) ...[
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (_, i) => Container(
                margin: EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        images[i],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => onRemove(i),
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
        ],
        InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[50],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  color: Color(0xFF1E88E5),
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  images.isEmpty ? 'Upload Photos' : 'Add More',
                  style: TextStyle(
                    color: Color(0xFF1E88E5),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DeadlinePicker extends StatelessWidget {
  final DateTime? deadline;
  final Function(DateTime?) onSelect;

  const _DeadlinePicker({required this.deadline, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(Duration(days: 7)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 365)),
        );
        if (date != null) onSelect(date);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            Icon(
              Icons.event,
              color: deadline != null ? Color(0xFF7B1FA2) : Colors.grey,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              deadline != null
                  ? '${deadline!.day}/${deadline!.month}/${deadline!.year}'
                  : 'Select deadline',
              style: TextStyle(
                color: deadline != null ? Colors.grey[800] : Colors.grey[500],
                fontSize: 14,
              ),
            ),
            Spacer(),
            if (deadline != null)
              GestureDetector(
                onTap: () => onSelect(null),
                child: Icon(Icons.close, color: Colors.grey, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14),
        backgroundColor: Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send, size: 18),
                SizedBox(width: 8),
                Text(
                  'SUBMIT REQUEST',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
    );
  }
}
