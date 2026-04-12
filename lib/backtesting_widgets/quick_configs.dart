import 'package:backtesting_app/utils/app_data.dart';
import 'package:backtesting_app/utils/app_theme.dart';
import 'package:backtesting_app/utils/form_state_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// We can Replace with SVG/icons later if needed
const _icons = ['📈', '📊', '🔵', '📉', '📈'];

class QuickConfigsSection extends StatelessWidget {
  final BacktestFormModel form;
  final VoidCallback onChanged;

  const QuickConfigsSection({
    super.key,
    required this.form,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = AppData.quickConfigs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK CONFIGURATIONS',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 14),

        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            double cardWidth;
            if (width < 600) {
              cardWidth = width * 0.8; // mobile
            } else if (width < 1000) {
              cardWidth = (width / 2) - 12; // tablet (2 per row)
            } else if (width < 1400) {
              cardWidth = (width / 5) - 12; // small desktop (3 per row)
            } else {
              cardWidth = (width / 5) - 12; // large desktop (4 per row)
            }

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(items.length, (i) {
                return SizedBox(
                  width: cardWidth,
                  child: _buildCard(
                    context,
                    items[i],
                    i,
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context,
    String name,
    int i,
  ) {
    final selected = form.quickConfig == name;

    return GestureDetector(
      onTap: () {
        form.quickConfig = selected ? null : name;
        onChanged();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            if (!selected)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// LEFT TEXT
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// RIGHT ICON BOX
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                _icons[i], // safe indexing
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
