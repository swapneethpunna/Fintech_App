import 'package:backtesting_app/utils/app_theme.dart';
import 'package:backtesting_app/utils/form_state_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/ui_helpers.dart';

class BacktestParamsSection extends StatelessWidget {
  final BacktestFormModel form;
  final VoidCallback onChanged;

  const BacktestParamsSection(
      {super.key, required this.form, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Backtest Parameters',
            style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text('Configure the test period, timing, and target parameters',
            style: GoogleFonts.dmSans(
                fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        // Responsive grid
        LayoutBuilder(builder: (ctx, constraints) {
          final wide = constraints.maxWidth > 860;
          if (wide) {
            return Wrap(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child:
                            _TestPeriodCard(form: form, onChanged: onChanged)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _TimingCard(form: form, onChanged: onChanged)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _TargetsCard(form: form, onChanged: onChanged)),
                  ],
                ),
              ],
            );
          }
          return Column(children: [
            _TestPeriodCard(form: form, onChanged: onChanged),
            const SizedBox(height: 16),
            _TimingCard(form: form, onChanged: onChanged),
            const SizedBox(height: 16),
            _TargetsCard(form: form, onChanged: onChanged),
          ]);
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Test Period card
// ─────────────────────────────────────────────────────────────────
class _TestPeriodCard extends StatelessWidget {
  final BacktestFormModel form;
  final VoidCallback onChanged;

  const _TestPeriodCard({required this.form, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _ParamCard(
      icon: Icons.calendar_month_outlined,
      iconBg: const Color(0xFFFFF3E0),
      iconColor: Colors.orange,
      title: 'Test Period',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel('TIME PERIOD'),
          const SizedBox(height: 6),
          StyledDropdown<String>(
            value: form.timePeriod,
            items: const [
              'Custom',
              '1 Month',
              '3 Months',
              '6 Months',
              '1 Year'
            ],
            onChanged: (v) {
              if (v != null) {
                form.timePeriod = v;
                onChanged();
              }
            },
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FieldLabel('FROM DATE'),
                const SizedBox(height: 6),
                _DatePicker(
                  date: form.fromDate,
                  onChanged: (d) {
                    form.fromDate = d;
                    onChanged();
                  },
                ),
              ],
            )),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FieldLabel('TO DATE'),
                const SizedBox(height: 6),
                _DatePicker(
                  date: form.toDate,
                  onChanged: (d) {
                    form.toDate = d;
                    onChanged();
                  },
                ),
              ],
            )),
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Timing card
// ─────────────────────────────────────────────────────────────────
class _TimingCard extends StatelessWidget {
  final BacktestFormModel form;
  final VoidCallback onChanged;

  const _TimingCard({required this.form, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _ParamCard(
      icon: Icons.access_time_outlined,
      iconBg: const Color(0xFFFFF3E0),
      iconColor: Colors.orange,
      title: 'Timing',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── NO OF TIMES + EXPIRY (wraps on small screens) ──
          Wrap(
            spacing: 20,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              _labeled(
                "NO OF TIMES",
                DoubleStepper(
                  value: double.parse(form.noOfTimes.toString()),
                  width: 120,
                  onChanged: (v) {
                    form.noOfTimes = v.toInt();
                    onChanged();
                  },
                ),
              ),
              _labeled(
                "EXPIRY",
                _SegmentToggle(
                  options: const ['Weekly', 'Monthly'],
                  selected: form.expiry,
                  onChanged: (v) {
                    form.expiry = v;
                    onChanged();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── ENTRY TIME + EXIT TIME (wraps on small screens) ──
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('ENTRY TIME'),
                    const SizedBox(height: 6),
                    _TimePicker(
                      value: form.entryTime,
                      onChanged: (t) {
                        form.entryTime = t;
                        onChanged();
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('EXIT TIME'),
                    const SizedBox(height: 6),
                    _TimePicker(
                      value: form.exitTime,
                      onChanged: (t) {
                        form.exitTime = t;
                        onChanged();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── DAY selector ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FieldLabel('DAY'),
              const SizedBox(height: 6),
              _DaySelector(days: form.days, onChanged: onChanged),
            ],
          ),
        ],
      ),
    );
  }

  Widget _labeled(String label, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [FieldLabel(label), const SizedBox(height: 4), child],
      );
}

// ─────────────────────────────────────────────────────────────────
//  Targets card
// ─────────────────────────────────────────────────────────────────
class _TargetsCard extends StatefulWidget {
  final BacktestFormModel form;
  final VoidCallback onChanged;

  const _TargetsCard({
    required this.form,
    required this.onChanged,
  });

  @override
  State<_TargetsCard> createState() => _TargetsSectionState();
}

class _TargetsSectionState extends State<_TargetsCard> {
  late final TextEditingController _targetCtrl;
  late final TextEditingController _slCtrl;

  @override
  void initState() {
    super.initState();
    _targetCtrl = TextEditingController(text: widget.form.target ?? '');
    _slCtrl = TextEditingController(text: widget.form.stopLoss ?? '');
  }

  @override
  void dispose() {
    _targetCtrl.dispose();
    _slCtrl.dispose();
    super.dispose();
  }

  void _toggleUnit(bool inRupees) {
    setState(() => widget.form.targetInRupees = inRupees);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final inRupees = widget.form.targetInRupees;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ParamCard(
          icon: Icons.gps_fixed_outlined,
          iconBg: const Color(0xFFE3F2FD),
          iconColor: Colors.blue,
          title: 'Targets',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── ₹ / % pill toggle ─────────────────────────────
              _UnitToggle(
                inRupees: inRupees,
                onChanged: _toggleUnit,
              ),
              const SizedBox(height: 20),

              // ── Target + Stop Loss fields side by side ────────
              Row(
                children: [
                  Expanded(
                    child: _AmountField(
                      label: 'TARGET',
                      controller: _targetCtrl,
                      inRupees: inRupees,
                      onValueChanged: (v) {
                        widget.form.target = v.isEmpty ? null : v;
                        widget.onChanged();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _AmountField(
                      label: 'STOP LOSS',
                      controller: _slCtrl,
                      inRupees: inRupees,
                      onValueChanged: (v) {
                        widget.form.stopLoss = v.isEmpty ? null : v;
                        widget.onChanged();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Shared param card wrapper
// ─────────────────────────────────────────────────────────────────
class _ParamCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final Widget child;

  const _ParamCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(icon, size: 15, color: iconColor),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: GoogleFonts.dmSans(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ]),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────
//  Small helpers inside the  timing card
// ─────────────────────────────────────────────────────────────────
class _SegmentToggle extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const _SegmentToggle(
      {required this.options, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
        height: 37,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: options.map((o) {
            final sel = o == selected;
            return GestureDetector(
              onTap: () => onChanged(o),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 84,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: sel ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  o,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
}

class _DaySelector extends StatelessWidget {
  final List<bool> days;
  final VoidCallback onChanged;
  static const _labels = ['M', 'T', 'W', 'T', 'F'];

  const _DaySelector({required this.days, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final allSelected = days.every((d) => d);
    return Wrap(
      spacing: 6,
      children: [
        ...List.generate(5, (i) {
          final sel = days[i];
          return GestureDetector(
            onTap: () {
              days[i] = !days[i];
              onChanged();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: sel ? AppColors.accent : AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: sel ? AppColors.accent : AppColors.border),
              ),
              child: Center(
                child: Text(_labels[i],
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: sel ? Colors.white : AppColors.textSecondary)),
              ),
            ),
          );
        }),
        GestureDetector(
          onTap: () {
            final newVal = !allSelected;
            for (int i = 0; i < 5; i++) days[i] = newVal;
            onChanged();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('ALL',
                style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _DatePicker({required this.date, required this.onChanged});

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () async {
          final p = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2000),
            lastDate: DateTime(2030),
          );
          if (p != null) onChanged(p);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(children: [
            Expanded(
                child: Text(_fmt(date),
                    style: GoogleFonts.dmSans(
                        fontSize: 13, color: AppColors.textPrimary))),
            const Icon(Icons.calendar_today,
                size: 13, color: AppColors.textHint),
          ]),
        ),
      );
}

class _TimePicker extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _TimePicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () async {
          final parts = value.split(':');
          final t = TimeOfDay(
            hour: int.tryParse(parts.first) ?? 9,
            minute: int.tryParse(parts.last) ?? 15,
          );
          final p = await showTimePicker(context: context, initialTime: t);
          if (p != null) {
            final h = p.hour.toString().padLeft(2, '0');
            final m = p.minute.toString().padLeft(2, '0');
            onChanged('$h:$m');
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(children: [
            Expanded(
                child: Text(value,
                    style: GoogleFonts.dmSans(
                        fontSize: 13, color: AppColors.textPrimary))),
            const Icon(Icons.access_time, size: 13, color: AppColors.textHint),
          ]),
        ),
      );
}

class _UnitToggle extends StatelessWidget {
  final bool inRupees;
  final ValueChanged<bool> onChanged;

  const _UnitToggle({required this.inRupees, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Pill(
            label: '₹',
            selected: inRupees,
            onTap: () => onChanged(true),
          ),
          _Pill(
            label: '%',
            selected: !inRupees,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 48,
        height: double.infinity,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool inRupees;
  final ValueChanged<String> onValueChanged;

  const _AmountField({
    required this.label,
    required this.controller,
    required this.inRupees,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.textHint.withOpacity(0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 10),
          _TextField(
            controller: controller,
            prefix: inRupees ? '₹' : '%',
            onChanged: onValueChanged,
          ),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String prefix;
  final ValueChanged<String> onChanged;

  const _TextField({
    required this.controller,
    required this.prefix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        height: 36,
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            prefixText: '$prefix ',
            prefixStyle: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            hintText: '0',
            hintStyle: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textHint,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(
                color: AppColors.borderFocus,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
