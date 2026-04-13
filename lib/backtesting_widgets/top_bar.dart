import 'package:backtesting_app/utils/app_data.dart';
import 'package:backtesting_app/utils/app_theme.dart';
import 'package:backtesting_app/utils/form_state_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopBar extends StatefulWidget {
  final BacktestFormModel form;
  final VoidCallback onChanged;

  const TopBar({super.key, required this.form, required this.onChanged});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.form.symbol);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _pickSymbol(String s) {
    setState(() {
      widget.form.selectSymbol(s);
      _ctrl.text = s;
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.form;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: _TopBarContent(
        ctrl: _ctrl,
        form: f,
        onPickSymbol: _pickSymbol,
        onChanged: (fn) {
          setState(fn);
          widget.onChanged();
        },
      ),
    );
  }
}

class _TopBarContent extends StatelessWidget {
  final TextEditingController ctrl;
  final BacktestFormModel form;
  final ValueChanged<String> onPickSymbol;
  final void Function(VoidCallback) onChanged;

  const _TopBarContent({
    required this.ctrl,
    required this.form,
    required this.onPickSymbol,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 220,
            maxWidth: 320,
          ),
          child: SizedBox(
            width: double.infinity,
            child: _SymbolField(
              ctrl: ctrl,
              onSelected: onPickSymbol,
            ),
          ),
        ),

        _vDivider(),

        // Lot Size
        _LotBadge(lotSize: form.lotSize),

        _vDivider(),

        // Mode
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: _ModeToggle(
            selected: form.mode,
            onChanged: (m) => onChanged(() => form.mode = m),
          ),
        ),

        _vDivider(),

        // Timeframe
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: _TimeframeDropdown(
            selected: form.timeframe,
            onChanged: (t) => onChanged(() => form.timeframe = t),
          ),
        ),
      ],
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 32, color: AppColors.border);
}

// ───────────────────────────────────────────────────────────────
// search SYMBOL FIELD
// ───────────────────────────────────────────────────────────────

class _SymbolField extends StatelessWidget {
  final TextEditingController ctrl;
  final ValueChanged<String> onSelected;

  const _SymbolField({required this.ctrl, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: ctrl.text),
      optionsBuilder: (v) {
        if (v.text.isEmpty) return AppData.symbols;
        return AppData.symbols
            .where((s) => s.toLowerCase().contains(v.text.toLowerCase()));
      },
      onSelected: onSelected,
      fieldViewBuilder: (ctx, controller, focusNode, onSubmit) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: 'Search symbol…',
            prefixIcon: const Icon(
              Icons.search,
              size: 16,
              color: AppColors.textHint,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.borderFocus,
                width: 1.5,
              ),
            ),
          ),
        );
      },
      optionsViewBuilder: (ctx, onSel, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 250,
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: options
                  .map((s) => ListTile(
                        dense: true,
                        title: Text(
                          s,
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          'Lot: ${AppData.lotSize(s)}',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        onTap: () => onSel(s),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// LOT BADGE
// ───────────────────────────────────────────────────────────────

class _LotBadge extends StatelessWidget {
  final int lotSize;
  const _LotBadge({required this.lotSize});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Lot Size:',
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('$lotSize',
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ),
        ],
      );
}

// ───────────────────────────────────────────────────────────────
// MODE TOGGLE \ — toggle between intraday and positional modes
// ───────────────────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _ModeToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Mode:',
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(width: 8),
         Flexible(
           child: Container(
                 height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
                 padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: AppData.modes.map((m) {
                    final sel = m == selected;
                    return GestureDetector(
                      onTap: () => onChanged(m),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          m,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
         ),
        ],
      );
}

// ───────────────────────────────────────────────────────────────
// TIMEFRAME
// ───────────────────────────────────────────────────────────────

class _TimeframeDropdown extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _TimeframeDropdown({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Timeframe:',
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(width: 6),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                  value: selected,
                  underline: const SizedBox(),
                  isDense: true,
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary),
                  items: AppData.timeframes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      onChanged(v);
                    }
                  }),
            ),
          ),
        ],
      );
}
