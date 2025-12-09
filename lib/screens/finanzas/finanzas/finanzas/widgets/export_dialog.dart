import 'package:flutter/material.dart';
import 'finance_colors.dart';
import '../models/financial_models.dart';


class ExportDialog extends StatefulWidget {
  const ExportDialog({super.key});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  ExportOption? _selectedOption;

  void _submit() {
    if (_selectedOption != null) {
      Navigator.of(context).pop(_selectedOption);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final dialogWidth = isSmallScreen ? constraints.maxWidth * 0.85 : 350.0;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            width: dialogWidth,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header (Close button only, aligned right)
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 24,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  
                  // Options
                  _buildRadioOption(ExportOption.excel, 'Exportar en Excel'),
                  const SizedBox(height: 12),
                  _buildRadioOption(ExportOption.pdf, 'Exportar PDF'),
                  const SizedBox(height: 12),
                  _buildRadioOption(ExportOption.print, 'Imprimir'),
                  
                  const SizedBox(height: 32),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedOption != null ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kFPrimaryBlue, // Cyan color
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Exportar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRadioOption(ExportOption value, String label) {
    return InkWell(
      onTap: () => setState(() => _selectedOption = value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Radio<ExportOption>(
              value: value,
              groupValue: _selectedOption,
              onChanged: (ExportOption? newValue) {
                setState(() => _selectedOption = newValue);
              },
              activeColor: Colors.black,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


