// ui_helpers.dart — Reusable small widgets used across all sections.

import 'package:backtesting_app/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────
//  Field label  (e.g. "INDICATOR", "PERIOD")
// ─────────────────────────────────────────────────────────────────
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.dmSans(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
      color: AppColors.textHint,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
//  Styled bordered dropdown
// ─────────────────────────────────────────────────────────────────
class StyledDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final double? width;

  const StyledDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Widget dd = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButton<T>(
        value: items.contains(value) ? value : items.first,
        underline: const SizedBox(),
        isDense: true,
        isExpanded: width == null,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        items: items.map((i) => DropdownMenuItem<T>(value: i, child: Text('$i'))).toList(),
        onChanged: onChanged,
      ),
    );
    return width != null ? SizedBox(width: width, child: dd) : dd;
  }
}

// ─────────────────────────────────────────────────────────────────
//  +/– period stepper
// ─────────────────────────────────────────────────────────────────
class PeriodStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const PeriodStepper({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove, () => onChanged(value > 1 ? value - 1 : 1)),
          SizedBox(
            width: 34,
            child: Text('$value',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          _btn(Icons.add, () => onChanged(value + 1)),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Icon(icon, size: 13, color: AppColors.textSecondary),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
//  Section card with optional colored left border
// ─────────────────────────────────────────────────────────────────
class SectionCard extends StatelessWidget {
  final Widget child;
  final Color? leftBorderColor;
  final EdgeInsets padding;

  const SectionCard({
    super.key,
    required this.child,
    this.leftBorderColor,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final inner = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );

    if (leftBorderColor == null) return inner;

    return Stack(
      children: [
        // The main card shifted right by 3px to leave room for the border bar
        Padding(
          padding: const EdgeInsets.only(left: 3),
          child: inner,
        ),
        // Colored left border bar — uses Positioned.fill so it stretches
        // to the full height of the Stack without needing IntrinsicHeight
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: 3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: leftBorderColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  OPTIONAL badge
// ─────────────────────────────────────────────────────────────────
class OptionalBadge extends StatelessWidget {
  const OptionalBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(0.12),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: Colors.orange.withOpacity(0.35)),
    ),
    child: Text(
      'OPTIONAL',
      style: GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Colors.orange,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
//  Section heading row
// ─────────────────────────────────────────────────────────────────
class SectionHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool optional;

  const SectionHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          )),
        if (optional) ...[const SizedBox(width: 8), const OptionalBadge()],
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(subtitle!,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        if (trailing != null) ...[const Spacer(), trailing!],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Count chip  e.g. "1 CONDITION"
// ─────────────────────────────────────────────────────────────────
class CountChip extends StatelessWidget {
  final String text;
  const CountChip(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFFEEEEEE),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
//  Small icon text button  (Reset, Add Condition …)
// ─────────────────────────────────────────────────────────────────
class SmallTextBtn extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool outlined;

  const SmallTextBtn({
    super.key,
    this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textSecondary,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: 4)],
        Text(label, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
      ],
    );

    if (outlined) {
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.4)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: GoogleFonts.dmSans(fontSize: 12),
        ),
        child: child,
      );
    }

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: child,
    );
  }
}