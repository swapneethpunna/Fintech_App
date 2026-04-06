// conditions_section.dart — Entry Conditions (green border) and Exit Conditions (red border).

import 'package:backtesting_app/models/technical_param_model.dart';
import 'package:backtesting_app/repos/technical_params_repo.dart';
import 'package:backtesting_app/utils/app_theme.dart';
import 'package:backtesting_app/utils/form_state_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/ui_helpers.dart';

const List<String> _kIndicators = [
  "ADX",
  "Aroon Oscillator",
  "ATR",
  "Bollinger Band Lower",
  "Bollinger Band Middle",
  "Bollinger Band Upper",
  "CCI",
  "Close",
  "Day High",
  "Day Low",
  "Day Open",
  "DI Minus",
  "DI Plus",
  "EMA",
  "EMA High",
  "EMA Low",
  "High",
  "Low",
  "MACD",
  "MACD Signal",
  "Momentum",
  "Money Flow Index",
  "Open",
  "Parabolic SAR",
  "Prev Candle Close",
  "ROC",
  "RSI",
  "SMA",
  "SMA High",
  "SMA Low",
  "StdDev",
  "Stocastic K",
  "Super Trend",
  "True Range",
  "Ultimate Oscillator",
  "Williams %R",
];

const List<String> _kOperators = [
  "Greater Than ( > )",
  "Less Than ( < )",
  "Equal To ( = )",
  "Crosses Above",
  "Crosses Below",
];

// ════════════════════════════════════════════════════════════════
//  Public data class – used by the page to build the API payload
// ════════════════════════════════════════════════════════════════

class ConditionRowData {
  final String indicator;
  final String operator;
  final String? compareTo;
  final double val1;
  final double val2;
  final double val3;

  const ConditionRowData({
    required this.indicator,
    required this.operator,
    this.compareTo,
    required this.val1,
    required this.val2,
    required this.val3,
  });

  /// Builds the comma-separated string expected by the API.
  /// Format: "Indicator,val1,val2,val3,Operator,CompareTo,AND"
  /// Values that are 0 / empty are omitted gracefully.
  String toApiString({String conjunction = 'AND'}) {
    final parts = <String>[indicator];
    if (val1 != 0) parts.add(_fmtNum(val1));
    if (val2 != 0) parts.add(_fmtNum(val2));
    if (val3 != 0) parts.add(_fmtNum(val3));
    parts.add(operator);
    if (compareTo != null && compareTo!.isNotEmpty) parts.add(compareTo!);
    parts.add(conjunction);
    return parts.join(',');
  }

  String _fmtNum(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();
}

// ════════════════════════════════════════════════════════════════
//  Per-row mutable state model (internal)
// ════════════════════════════════════════════════════════════════

class _RowState {
  TechnicalParams? data;
  String? error;
  String selectedIndicator;
  String selectedOperator;
  String? selectedCompare;
  double val1;
  double val2;
  double val3;

  _RowState({
    this.selectedIndicator = 'EMA',
    this.selectedOperator = 'Greater Than ( > )',
    this.selectedCompare,
    this.val1 = 0,
    this.val2 = 0,
    this.val3 = 0,
  });

  ConditionRowData toData() => ConditionRowData(
        indicator: selectedIndicator,
        operator: selectedOperator,
        compareTo: selectedCompare,
        val1: val1,
        val2: val2,
        val3: val3,
      );
}

// ════════════════════════════════════════════════════════════════
//  Entry Conditions Section
// ════════════════════════════════════════════════════════════════

class EntryConditionsSection extends StatefulWidget {
  final void Function(List<ConditionRowData> rows)? onConditionsChanged;

  const EntryConditionsSection({super.key, this.onConditionsChanged});

  @override
  State<EntryConditionsSection> createState() => _EntryConditionsSectionState();
}

class _EntryConditionsSectionState extends State<EntryConditionsSection> {
  final TechnicalRepository _repo = TechnicalRepository();

  final List<_RowState> _rows = [];
  final Set<int> _loadingRows = {};

  void _notify() {
    widget.onConditionsChanged?.call(_rows.map((r) => r.toData()).toList());
  }

  @override
  void initState() {
    super.initState();
    _rows.add(_RowState());
    _fetchForRow(0, 'EMA');
  }

  Future<void> _fetchForRow(int index, String indicator) async {
    if (index >= _rows.length) return;
    setState(() {
      _loadingRows.add(index);
      _rows[index].error = null;
    });
    try {
      final result = await _repo.fetchTechnicalParams(indicator);
      if (!mounted || index >= _rows.length) return;
      final b = result.before.isNotEmpty ? result.before.first : null;
      setState(() {
        _rows[index].data = result;
        _rows[index].selectedIndicator = indicator;
        _rows[index].val1 = double.tryParse(b?.aValue1 ?? '') ?? 0;
        _rows[index].val2 = double.tryParse(b?.aValue2 ?? '') ?? 0;
        _rows[index].val3 = double.tryParse(b?.aValue3 ?? '') ?? 0;
        if (result.after.isNotEmpty) {
          _rows[index].selectedCompare = result.after.first.name;
        }
        _loadingRows.remove(index);
      });
      _notify();
    } catch (e) {
      if (!mounted || index >= _rows.length) return;
      setState(() {
        _rows[index].error = e.toString();
        _loadingRows.remove(index);
      });
    }
  }

  void _addRow() {
    setState(() => _rows.add(_RowState()));
    _fetchForRow(_rows.length - 1, 'EMA');
  }

  void _removeRow(int index) {
    if (_rows.length <= 1) return;
    setState(() {
      _rows.removeAt(index);
      _loadingRows.remove(index);
    });
    _notify();
  }

  void _reset() {
    setState(() {
      _rows.clear();
      _loadingRows.clear();
      _rows.add(_RowState());
    });
    _fetchForRow(0, 'EMA');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
            title: 'Entry When', subtitle: 'Define when to enter trades'),
        const SizedBox(height: 12),
        SectionCard(
          leftBorderColor: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────
              LayoutBuilder(
                builder: (context, constraints) {
                  final isSmall = constraints.maxWidth < 600;
                  if (isSmall) {
                    return Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Left section (icon + title + count)
                        Wrap(
                          spacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(Icons.login,
                                size: 15, color: AppColors.primary),
                            Text(
                              'Entry Conditions',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            CountChip(
                              '${_rows.length} CONDITION${_rows.length != 1 ? "S" : ""}',
                            ),
                          ],
                        ),

                        // Right section (Reset button)
                        SmallTextBtn(
                          icon: Icons.refresh,
                          label: 'Reset',
                          onTap: _reset,
                        ),
                      ],
                    );
                  } else {
                    return Row(children: [
                      const Icon(Icons.login,
                          size: 15, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text('Entry Conditions',
                          style: GoogleFonts.dmSans(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      CountChip(
                          '${_rows.length} CONDITION${_rows.length != 1 ? "S" : ""}'),
                      const Spacer(),
                      SmallTextBtn(
                        icon: Icons.refresh,
                        label: 'Reset',
                        onTap: _reset,
                      ),
                    ]);
                  }
                },
              ),
              const SizedBox(height: 14),

              // ── Condition rows ──────────────────────────────
              ...List.generate(_rows.length, (i) {
                final row = _rows[i];
                final loading = _loadingRows.contains(i);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: loading
                      ? const _LoadingRow(accentColor: AppColors.primary)
                      : row.error != null
                          ? _ErrorRow(
                              message: row.error!,
                              accentColor: AppColors.primary)
                          : row.data == null || row.data!.before.isEmpty
                              ? const _EmptyRow(accentColor: AppColors.primary)
                              : _ApiConditionRow(
                                  accentColor: AppColors.primary,
                                  before: row.data!.before.first,
                                  compareOptions: row.data!.after
                                      .map((e) => e.name)
                                      .toList(),
                                  selectedIndicator: row.selectedIndicator,
                                  selectedOperator: row.selectedOperator,
                                  selectedCompare: row.selectedCompare,
                                  val1: row.val1,
                                  val2: row.val2,
                                  val3: row.val3,
                                  canDelete: _rows.length > 1,
                                  onIndicatorChanged: (v) => _fetchForRow(i, v),
                                  onOperatorChanged: (v) {
                                    setState(
                                        () => _rows[i].selectedOperator = v);
                                    _notify();
                                  },
                                  onCompareChanged: (v) {
                                    setState(
                                        () => _rows[i].selectedCompare = v);
                                    _notify();
                                  },
                                  onVal1Changed: (v) {
                                    setState(() => _rows[i].val1 = v);
                                    _notify();
                                  },
                                  onVal2Changed: (v) {
                                    setState(() => _rows[i].val2 = v);
                                    _notify();
                                  },
                                  onVal3Changed: (v) {
                                    setState(() => _rows[i].val3 = v);
                                    _notify();
                                  },
                                  onDelete: () => _removeRow(i),
                                ),
                );
              }),

              const SizedBox(height: 4),

              // ── Bottom actions ──────────────────────────────
              Wrap(children: [
                Padding(
                  padding: const EdgeInsets.only(top:10, bottom:10),
                  child: SmallTextBtn(
                    icon: Icons.add,
                    label: 'Add Condition',
                    onTap: _addRow,
                    outlined: true,
                  ),
                ),
                const SizedBox(width: 10),
                const _AddExitConditionsBtn(),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Exit Conditions Section
// ════════════════════════════════════════════════════════════════

class ExitConditionsSection extends StatefulWidget {
  final BacktestFormModel form;
  final VoidCallback onChanged;

  /// Called whenever any condition row changes.
  final void Function(List<ConditionRowData> rows)? onConditionsChanged;

  const ExitConditionsSection({
    super.key,
    required this.form,
    required this.onChanged,
    this.onConditionsChanged,
  });

  @override
  State<ExitConditionsSection> createState() => _ExitConditionsSectionState();
}

class _ExitConditionsSectionState extends State<ExitConditionsSection> {
  final TechnicalRepository _repo = TechnicalRepository();

  final List<_RowState> _rows = [];
  final Set<int> _loadingRows = {};

  void _notify() {
    widget.onConditionsChanged?.call(_rows.map((r) => r.toData()).toList());
  }

  @override
  void initState() {
    super.initState();
    _rows.add(_RowState(selectedOperator: 'Crosses Below'));
    _fetchForRow(0, 'EMA');
  }

  Future<void> _fetchForRow(int index, String indicator) async {
    if (index >= _rows.length) return;
    setState(() {
      _loadingRows.add(index);
      _rows[index].error = null;
    });
    try {
      final result = await _repo.fetchTechnicalParams(indicator);
      if (!mounted || index >= _rows.length) return;
      final b = result.before.isNotEmpty ? result.before.first : null;
      setState(() {
        _rows[index].data = result;
        _rows[index].selectedIndicator = indicator;
        _rows[index].val1 = double.tryParse(b?.aValue1 ?? '') ?? 0;
        _rows[index].val2 = double.tryParse(b?.aValue2 ?? '') ?? 0;
        _rows[index].val3 = double.tryParse(b?.aValue3 ?? '') ?? 0;
        if (result.after.isNotEmpty) {
          _rows[index].selectedCompare = result.after.first.name;
        }
        _loadingRows.remove(index);
      });
      _notify();
    } catch (e) {
      if (!mounted || index >= _rows.length) return;
      setState(() {
        _rows[index].error = e.toString();
        _loadingRows.remove(index);
      });
    }
  }

  void _addRow() {
    setState(() => _rows.add(_RowState(selectedOperator: 'Crosses Below')));
    _fetchForRow(_rows.length - 1, 'EMA');
  }

  void _removeRow(int index) {
    if (_rows.length <= 1) return;
    setState(() {
      _rows.removeAt(index);
      _loadingRows.remove(index);
    });
    _notify();
  }

  void _reset() {
    setState(() {
      _rows.clear();
      _loadingRows.clear();
      _rows.add(_RowState(selectedOperator: 'Crosses Below'));
    });
    _fetchForRow(0, 'EMA');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          title: 'Exit When',
          subtitle:
              'Define when to exit trades. If left empty, trades will exit based on target/stoploss parameters.',
          optional: true,
        ),
        const SizedBox(height: 12),
        SectionCard(
          leftBorderColor: Colors.red,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  const Icon(Icons.logout, size: 15, color: Colors.red),
                  Text('Exit Conditions',
                      style: GoogleFonts.dmSans(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  CountChip(
                      '${_rows.length} CONDITION${_rows.length != 1 ? "S" : ""}'),
                  SmallTextBtn(
                    icon: Icons.refresh,
                    label: 'Reset',
                    onTap: _reset,
                  ),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Checkbox(
                      value: widget.form.checkSimultaneously,
                      onChanged: (v) {
                        setState(() {
                          widget.form.checkSimultaneously = v ?? false;
                        });
                        widget.onChanged();
                      },
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    Text('Check Entry & Exit simultaneously',
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(width: 4),
                    const Icon(Icons.info_outline,
                        size: 13, color: AppColors.textHint),
                  ]),
                ],
              ),
              const SizedBox(height: 14),

              // ── Condition rows ──────────────────────────────
              ...List.generate(_rows.length, (i) {
                final row = _rows[i];
                final loading = _loadingRows.contains(i);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: loading
                      ? _LoadingRow(accentColor: Colors.red)
                      : row.error != null
                          ? _ErrorRow(
                              message: row.error!, accentColor: Colors.red)
                          : row.data == null || row.data!.before.isEmpty
                              ? _EmptyRow(accentColor: Colors.red)
                              : _ApiConditionRow(
                                  accentColor: Colors.red,
                                  before: row.data!.before.first,
                                  compareOptions: row.data!.after
                                      .map((e) => e.name)
                                      .toList(),
                                  selectedIndicator: row.selectedIndicator,
                                  selectedOperator: row.selectedOperator,
                                  selectedCompare: row.selectedCompare,
                                  val1: row.val1,
                                  val2: row.val2,
                                  val3: row.val3,
                                  canDelete: _rows.length > 1,
                                  onIndicatorChanged: (v) => _fetchForRow(i, v),
                                  onOperatorChanged: (v) {
                                    setState(
                                        () => _rows[i].selectedOperator = v);
                                    _notify();
                                  },
                                  onCompareChanged: (v) {
                                    setState(
                                        () => _rows[i].selectedCompare = v);
                                    _notify();
                                  },
                                  onVal1Changed: (v) {
                                    setState(() => _rows[i].val1 = v);
                                    _notify();
                                  },
                                  onVal2Changed: (v) {
                                    setState(() => _rows[i].val2 = v);
                                    _notify();
                                  },
                                  onVal3Changed: (v) {
                                    setState(() => _rows[i].val3 = v);
                                    _notify();
                                  },
                                  onDelete: () => _removeRow(i),
                                ),
                );
              }),

              const SizedBox(height: 4),
              SmallTextBtn(
                icon: Icons.add,
                label: 'Add Condition',
                onTap: _addRow,
                outlined: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Shared API-driven condition row
// ════════════════════════════════════════════════════════════════

class _ApiConditionRow extends StatelessWidget {
  final Color accentColor;
  final After before;
  final List<String> compareOptions;
  final String selectedIndicator;
  final String selectedOperator;
  final String? selectedCompare;
  final double val1, val2, val3;
  final bool canDelete;
  final ValueChanged<String> onIndicatorChanged;
  final ValueChanged<String> onOperatorChanged;
  final ValueChanged<String> onCompareChanged;
  final ValueChanged<double> onVal1Changed;
  final ValueChanged<double> onVal2Changed;
  final ValueChanged<double> onVal3Changed;
  final VoidCallback onDelete;

  const _ApiConditionRow({
    required this.accentColor,
    required this.before,
    required this.compareOptions,
    required this.selectedIndicator,
    required this.selectedOperator,
    this.selectedCompare,
    required this.val1,
    required this.val2,
    required this.val3,
    required this.canDelete,
    required this.onIndicatorChanged,
    required this.onOperatorChanged,
    required this.onCompareChanged,
    required this.onVal1Changed,
    required this.onVal2Changed,
    required this.onVal3Changed,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor == Colors.red
            ? const Color(0xFFFFF8F8)
            : const Color(0xFFF7FAF7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withOpacity(0.25)),
      ),
      child: LayoutBuilder(builder: (ctx, constraints) {
        if (constraints.maxWidth >= 700) {
          return _WideLayout(
            before: before,
            compareOptions: compareOptions,
            selectedIndicator: selectedIndicator,
            selectedOperator: selectedOperator,
            selectedCompare: selectedCompare,
            val1: val1,
            val2: val2,
            val3: val3,
            canDelete: canDelete,
            onIndicatorChanged: onIndicatorChanged,
            onOperatorChanged: onOperatorChanged,
            onCompareChanged: onCompareChanged,
            onVal1Changed: onVal1Changed,
            onVal2Changed: onVal2Changed,
            onVal3Changed: onVal3Changed,
            onDelete: onDelete,
          );
        }
        return _NarrowLayout(
          before: before,
          compareOptions: compareOptions,
          selectedIndicator: selectedIndicator,
          selectedOperator: selectedOperator,
          selectedCompare: selectedCompare,
          val1: val1,
          val2: val2,
          val3: val3,
          canDelete: canDelete,
          onIndicatorChanged: onIndicatorChanged,
          onOperatorChanged: onOperatorChanged,
          onCompareChanged: onCompareChanged,
          onVal1Changed: onVal1Changed,
          onVal2Changed: onVal2Changed,
          onVal3Changed: onVal3Changed,
          onDelete: onDelete,
        );
      }),
    );
  }
}

// ── Wide layout (≥ 700px) ────────────────────────────────────────
class _WideLayout extends StatelessWidget {
  final After before;
  final List<String> compareOptions;
  final String selectedIndicator;
  final String selectedOperator;
  final String? selectedCompare;
  final double val1, val2, val3;
  final bool canDelete;
  final ValueChanged<String> onIndicatorChanged;
  final ValueChanged<String> onOperatorChanged;
  final ValueChanged<String> onCompareChanged;
  final ValueChanged<double> onVal1Changed;
  final ValueChanged<double> onVal2Changed;
  final ValueChanged<double> onVal3Changed;
  final VoidCallback onDelete;

  const _WideLayout({
    required this.before,
    required this.compareOptions,
    required this.selectedIndicator,
    required this.selectedOperator,
    required this.selectedCompare,
    required this.val1,
    required this.val2,
    required this.val3,
    required this.canDelete,
    required this.onIndicatorChanged,
    required this.onOperatorChanged,
    required this.onCompareChanged,
    required this.onVal1Changed,
    required this.onVal2Changed,
    required this.onVal3Changed,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Labels
          Row(children: [
            const SizedBox(width: 190, child: FieldLabel('INDICATOR')),
            if (before.aLabel1.isNotEmpty) ...[
              const SizedBox(width: 10),
              SizedBox(
                  width: 140, child: FieldLabel(before.aLabel1.toUpperCase())),
            ],
            if (before.aLabel2.isNotEmpty) ...[
              const SizedBox(width: 10),
              SizedBox(
                  width: 140, child: FieldLabel(before.aLabel2.toUpperCase())),
            ],
            if (before.aLabel3.isNotEmpty) ...[
              const SizedBox(width: 10),
              SizedBox(
                  width: 140, child: FieldLabel(before.aLabel3.toUpperCase())),
            ],
            const SizedBox(width: 10),
            const SizedBox(width: 190, child: FieldLabel('OPERATOR')),
            const SizedBox(width: 10),
            const SizedBox(width: 160, child: FieldLabel('COMPARE TO')),
          ]),
          const SizedBox(height: 6),
          // Controls
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            _StyledDd(
              value: selectedIndicator,
              items: _kIndicators,
              width: 190,
              onChanged: (v) {
                if (v != null) onIndicatorChanged(v);
              },
            ),
            if (before.aLabel1.isNotEmpty) ...[
              const SizedBox(width: 10),
              _DoubleStepper(value: val1, width: 140, onChanged: onVal1Changed),
            ],
            if (before.aLabel2.isNotEmpty) ...[
              const SizedBox(width: 10),
              _DoubleStepper(value: val2, width: 140, onChanged: onVal2Changed),
            ],
            if (before.aLabel3.isNotEmpty) ...[
              const SizedBox(width: 10),
              _DoubleStepper(value: val3, width: 140, onChanged: onVal3Changed),
            ],
            const SizedBox(width: 10),
            _StyledDd(
              value: selectedOperator,
              items: _kOperators,
              width: 190,
              onChanged: (v) {
                if (v != null) onOperatorChanged(v);
              },
            ),
            const SizedBox(width: 10),
            _StyledDd(
              value: compareOptions.contains(selectedCompare)
                  ? selectedCompare!
                  : (compareOptions.isNotEmpty ? compareOptions.first : ''),
              items: compareOptions,
              width: 160,
              onChanged: (v) {
                if (v != null) onCompareChanged(v);
              },
            ),
            if (canDelete) ...[
              const SizedBox(width: 10),
              _DeleteBtn(onTap: onDelete),
            ],
          ]),
        ],
      ),
    );
  }
}

// ── Narrow / wrap layout (< 700px) ──────────────────────────────
class _NarrowLayout extends StatelessWidget {
  final After before;
  final List<String> compareOptions;
  final String selectedIndicator;
  final String selectedOperator;
  final String? selectedCompare;
  final double val1, val2, val3;
  final bool canDelete;
  final ValueChanged<String> onIndicatorChanged;
  final ValueChanged<String> onOperatorChanged;
  final ValueChanged<String> onCompareChanged;
  final ValueChanged<double> onVal1Changed;
  final ValueChanged<double> onVal2Changed;
  final ValueChanged<double> onVal3Changed;
  final VoidCallback onDelete;

  const _NarrowLayout({
    required this.before,
    required this.compareOptions,
    required this.selectedIndicator,
    required this.selectedOperator,
    required this.selectedCompare,
    required this.val1,
    required this.val2,
    required this.val3,
    required this.canDelete,
    required this.onIndicatorChanged,
    required this.onOperatorChanged,
    required this.onCompareChanged,
    required this.onVal1Changed,
    required this.onVal2Changed,
    required this.onVal3Changed,
    required this.onDelete,
  });

  Widget _labeled(String label, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [FieldLabel(label), const SizedBox(height: 4), child],
      );

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _labeled(
            'INDICATOR',
            _StyledDd(
                value: selectedIndicator,
                items: _kIndicators,
                width: 190,
                onChanged: (v) {
                  if (v != null) onIndicatorChanged(v);
                })),
        if (before.aLabel1.isNotEmpty)
          _labeled(
              before.aLabel1.toUpperCase(),
              _DoubleStepper(
                  value: val1, width: 130, onChanged: onVal1Changed)),
        if (before.aLabel2.isNotEmpty)
          _labeled(
              before.aLabel2.toUpperCase(),
              _DoubleStepper(
                  value: val2, width: 130, onChanged: onVal2Changed)),
        if (before.aLabel3.isNotEmpty)
          _labeled(
              before.aLabel3.toUpperCase(),
              _DoubleStepper(
                  value: val3, width: 130, onChanged: onVal3Changed)),
        _labeled(
            'OPERATOR',
            _StyledDd(
                value: selectedOperator,
                items: _kOperators,
                width: 190,
                onChanged: (v) {
                  if (v != null) onOperatorChanged(v);
                })),
        _labeled(
            'COMPARE TO',
            _StyledDd(
                value: compareOptions.contains(selectedCompare)
                    ? selectedCompare!
                    : (compareOptions.isNotEmpty ? compareOptions.first : ''),
                items: compareOptions,
                width: 160,
                onChanged: (v) {
                  if (v != null) onCompareChanged(v);
                })),
        if (canDelete) _DeleteBtn(onTap: onDelete),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Inline state widgets (loading / error / empty)
// ════════════════════════════════════════════════════════════════

class _LoadingRow extends StatelessWidget {
  final Color accentColor;
  const _LoadingRow({required this.accentColor});

  @override
  Widget build(BuildContext context) => Container(
        height: 60,
        decoration: BoxDecoration(
          color: accentColor == Colors.red
              ? const Color(0xFFFFF8F8)
              : const Color(0xFFF7FAF7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accentColor.withOpacity(0.35)),
        ),
        child: const Center(
          child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
}

class _ErrorRow extends StatelessWidget {
  final String message;
  final Color accentColor;
  const _ErrorRow({required this.message, required this.accentColor});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accentColor.withOpacity(0.35)),
        ),
        child: Text('Error: $message',
            style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.error)),
      );
}

class _EmptyRow extends StatelessWidget {
  final Color accentColor;
  const _EmptyRow({required this.accentColor});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accentColor == Colors.red
              ? const Color(0xFFFFF8F8)
              : const Color(0xFFF7FAF7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accentColor.withOpacity(0.35)),
        ),
        child: Text('No Data',
            style: GoogleFonts.dmSans(
                fontSize: 12, color: AppColors.textSecondary)),
      );
}

// ════════════════════════════════════════════════════════════════
//  Reusable primitive widgets
// ════════════════════════════════════════════════════════════════

class _StyledDd extends StatelessWidget {
  final String value;
  final List<String> items;
  final double width;
  final ValueChanged<String?> onChanged;

  const _StyledDd({
    required this.value,
    required this.items,
    required this.width,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value)
              ? value
              : (items.isNotEmpty ? items.first : null),
          isExpanded: true,
          isDense: true,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DoubleStepper extends StatelessWidget {
  final double value;
  final double width;
  final ValueChanged<double> onChanged;

  const _DoubleStepper({
    required this.value,
    required this.width,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove,
              () => onChanged(double.parse((value - 0.01).toStringAsFixed(2)))),
          Expanded(
            child: Text(
              value.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style:
                  GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          _btn(Icons.add,
              () => onChanged(double.parse((value + 0.01).toStringAsFixed(2)))),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          child: Icon(icon, size: 13, color: AppColors.textSecondary),
        ),
      );
}

class _DeleteBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _DeleteBtn({required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child:
              const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
        ),
      );
}

class _AddExitConditionsBtn extends StatefulWidget {
  const _AddExitConditionsBtn();

  @override
  State<_AddExitConditionsBtn> createState() => _AddExitConditionsBtnState();
}

class _AddExitConditionsBtnState extends State<_AddExitConditionsBtn> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _checked = !_checked),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
              color: _checked
                  ? AppColors.primary
                  : AppColors.border.withOpacity(0.8)),
          borderRadius: BorderRadius.circular(6),
          color: _checked
              ? AppColors.primary.withOpacity(0.06)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: Checkbox(
                value: _checked,
                onChanged: (v) => setState(() => _checked = v ?? false),
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Add Exit Conditions',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _checked ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
