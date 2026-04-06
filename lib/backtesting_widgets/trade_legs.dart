import 'package:backtesting_app/utils/app_data.dart';
import 'package:backtesting_app/utils/app_theme.dart';
import 'package:backtesting_app/utils/form_state_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/ui_helpers.dart';

// ════════════════════════════════════════════════════════════════
//  Entry Trade section
// ════════════════════════════════════════════════════════════════
class EntryTradeSection extends StatelessWidget {
  final BacktestFormModel form;
  final VoidCallback onChanged;

  const EntryTradeSection({super.key, required this.form, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(title: 'Entry Trade', subtitle: 'Configure your entry trade'),
        const SizedBox(height: 12),
        _LegCard(
          title: 'Entry Trade',
          icon: Icons.login,
          iconColor: Colors.blue,
          borderColor: Colors.blue,
          legs: form.entryLegs,
          instruments: form.instruments,
          onAddLeg: () { form.entryLegs.add(LegModel(instrument: form.instruments.first, quantity: form.lotSize)); onChanged(); },
          onRemoveLeg: (i) { if (form.entryLegs.length > 1) form.entryLegs.removeAt(i); onChanged(); },
          onReset: () { form.entryLegs = [LegModel(instrument: form.instruments.first, quantity: form.lotSize)]; onChanged(); },
          onIncrement: (i) { form.incrementLegQty(form.entryLegs[i]); onChanged(); },
          onDecrement: (i) { form.decrementLegQty(form.entryLegs[i]); onChanged(); },
          onLegChanged: onChanged,
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Exit Trade section
// ════════════════════════════════════════════════════════════════
class ExitTradeSection extends StatelessWidget {
  final BacktestFormModel form;
  final VoidCallback onChanged;

  const ExitTradeSection({super.key, required this.form, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(title: 'Exit Trade', subtitle: 'Configure your exit trade', optional: true),
        const SizedBox(height: 12),
        _LegCard(
          title: 'Exit Trade',
          icon: Icons.logout,
          iconColor: Colors.red,
          borderColor: Colors.red,
          legs: form.exitLegs,
          instruments: form.instruments,
          onAddLeg: () { form.exitLegs.add(LegModel(instrument: form.instruments.first, quantity: form.lotSize)); onChanged(); },
          onRemoveLeg: (i) { form.exitLegs.removeAt(i); onChanged(); },
          onReset: () { form.exitLegs = []; onChanged(); },
          onIncrement: (i) { form.incrementLegQty(form.exitLegs[i]); onChanged(); },
          onDecrement: (i) { form.decrementLegQty(form.exitLegs[i]); onChanged(); },
          onLegChanged: onChanged,
          allowEmpty: true,
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Shared leg card
// ════════════════════════════════════════════════════════════════
class _LegCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color borderColor;
  final List<LegModel> legs;
  final List<String> instruments;
  final VoidCallback onAddLeg;
  final ValueChanged<int> onRemoveLeg;
  final VoidCallback onReset;
  final ValueChanged<int> onIncrement;
  final ValueChanged<int> onDecrement;
  final VoidCallback onLegChanged;
  final bool allowEmpty;

  const _LegCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.borderColor,
    required this.legs,
    required this.instruments,
    required this.onAddLeg,
    required this.onRemoveLeg,
    required this.onReset,
    required this.onIncrement,
    required this.onDecrement,
    required this.onLegChanged,
    this.allowEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      leftBorderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 6),
            Text(title, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            CountChip('${legs.length} ${legs.length == 1 ? "LEG" : "LEGS"}'),
            const Spacer(),
            SmallTextBtn(icon: Icons.refresh, label: 'Reset', onTap: onReset),
          ]),
          const SizedBox(height: 14),

          // Empty state
          if (legs.isEmpty)
            _EmptyLegs(onAdd: onAddLeg)
          else ...[
            ...List.generate(legs.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LegRow(
                leg: legs[i],
                instruments: instruments,
                canDelete: legs.length > 1 || allowEmpty,
                onIncrement: () => onIncrement(i),
                onDecrement: () => onDecrement(i),
                onDelete: () => onRemoveLeg(i),
                onChanged: onLegChanged,
              ),
            )),
          ],
          const SizedBox(height: 4),
          SmallTextBtn(
            icon: Icons.add,
            label: 'Add Leg',
            onTap: onAddLeg,
            outlined: true,
          ),
        ],
      ),
    );
  }
}

// ── Single leg row ───────────────────────────────────────────────
class _LegRow extends StatelessWidget {
  final LegModel leg;
  final List<String> instruments;
  final bool canDelete;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _LegRow({
    required this.leg,
    required this.instruments,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
    required this.onChanged,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 600;

        return Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Buy / Sell
            _fieldWrapper(
              label: isSmall ? 'SIDE' : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: ['B', 'S'].map((side) {
                  final sel = leg.buySell == side;
                  return GestureDetector(
                    onTap: () {
                      leg.buySell = side;
                      onChanged();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 38,
                      height: 38,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: sel
                            ? (side == 'B' ? Colors.green : Colors.red)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: side == 'B' ? Colors.green : Colors.red,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          side,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: sel
                                ? Colors.white
                                : (side == 'B'
                                    ? Colors.green
                                    : Colors.red),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Instrument
            _fieldWrapper(
              label: isSmall ? 'INSTRUMENT' : null,
              child: SizedBox(
                width: isSmall ? double.infinity : 140,
                child: StyledDropdown<String>(
                  value: instruments.contains(leg.instrument)
                      ? leg.instrument
                      : instruments.first,
                  items: instruments,
                  onChanged: (v) {
                    if (v != null) {
                      leg.instrument = v;
                      onChanged();
                    }
                  },
                ),
              ),
            ),

            // Strike
            _fieldWrapper(
              label: isSmall ? 'STRIKE' : null,
              child: SizedBox(
                width: isSmall ? double.infinity : 130,
                child: StyledDropdown<String>(
                  value: AppData.strikes.contains(leg.strike)
                      ? leg.strike
                      : AppData.strikes.first,
                  items: AppData.strikes,
                  onChanged: (v) {
                    if (v != null) {
                      leg.strike = v;
                      onChanged();
                    }
                  },
                ),
              ),
            ),

            // Qty
            _fieldWrapper(
              label: isSmall ? 'QTY' : null,
              child: _QtyStepper(
                qty: leg.quantity,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
              ),
            ),

            // Delete
            if (canDelete)
              _fieldWrapper(
                label: isSmall ? 'DELETE' : null,
                child: InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _fieldWrapper({String? label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
        child,
      ],
    );
  }
}

// ── Qty stepper ──────────────────────────────────────────────────
class _QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QtyStepper({required this.qty, required this.onIncrement, required this.onDecrement});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn(Icons.remove, onDecrement),
        SizedBox(
          width: 52,
          child: Text('$qty',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        _btn(Icons.add, onIncrement),
      ],
    ),
  );

  Widget _btn(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Icon(icon, size: 13, color: AppColors.textSecondary),
    ),
  );
}

// ── Empty state ──────────────────────────────────────────────────
class _EmptyLegs extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyLegs({required this.onAdd});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 28),
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFFAFAFA),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.layers_outlined, size: 30, color: AppColors.textHint),
        const SizedBox(height: 8),
        Text('No exit legs defined',
            style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500,
                color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text('Add legs to specify exit trade',
            style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textHint)),
        const SizedBox(height: 12),
        SmallTextBtn(icon: Icons.add, label: 'Add Leg', onTap: onAdd, outlined: true),
      ],
    ),
  );
}