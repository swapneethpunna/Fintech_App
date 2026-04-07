import 'package:backtesting_app/backtesting_widgets/back_test_table.dart';
import 'package:backtesting_app/utils/app_theme.dart';
import 'package:backtesting_app/backtesting_widgets/back_test_params.dart';
import 'package:backtesting_app/backtesting_widgets/condition_section.dart';
import 'package:backtesting_app/utils/form_state_data.dart';
import 'package:backtesting_app/backtesting_widgets/quick_configs.dart';
import 'package:backtesting_app/backtesting_widgets/top_bar.dart';
import 'package:backtesting_app/backtesting_widgets/trade_legs.dart';
import 'package:backtesting_app/repos/back_testing_repo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BacktestingPage extends StatefulWidget {
  const BacktestingPage({super.key});

  @override
  State<BacktestingPage> createState() => _BacktestingPageState();
}

class _BacktestingPageState extends State<BacktestingPage> {
  final BacktestFormModel _form = BacktestFormModel();
  int _selectedNavIndex = 4;

  List<ConditionRowData> _entryConditions = [];
  List<ConditionRowData> _exitConditions = [];

  bool _isRunning = false;
  dynamic _resultData;
  DateTime? _resultFrom;
  DateTime? _resultTo;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _resultKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

// payload for backtesting api body
  Map<String, dynamic> _buildPayload() {
    final f = _form;
    final tfMap = {
      '1 Min': '1', '3 Mins': '3', '5 Mins': '5', '10 Mins': '10',
      '15 Mins': '15', '30 Mins': '30', '1 Hour': '60', '1 Day': '1440',
    };
    final timeFrame = tfMap[f.timeframe] ?? '5';
    String fmtDate(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

    final entryParams = f.entryLegs.map((leg) => {
      'Symbol': f.symbol, 'Instrument': leg.instrument,
      'BuySell': leg.buySell == 'B' ? 'BUY' : 'SELL',
      'Qty': leg.quantity.toString(), 'StrikeType': leg.strike,
      'Type': 'Pts', 'Tgt': f.target ?? '0', 'SL': f.stopLoss ?? '0',
      'TrailTGT': '0', 'TrailSL': '0',
    }).toList();

    final entryReverse = f.entryLegs.map((leg) => {
      'Symbol': f.symbol, 'Instrument': leg.instrument,
      'BuySell': leg.buySell == 'B' ? 'SELL' : 'BUY',
      'Qty': leg.quantity.toString(), 'StrikeType': leg.strike,
      'Type': 'Pts', 'Tgt': f.target ?? '0', 'SL': f.stopLoss ?? '0',
      'TrailTGT': '0', 'TrailSL': '0',
    }).toList();

    final techEntry = _entryConditions.isNotEmpty
        ? _entryConditions.map((c) => {'value': c.toApiString(), 'TimeFrame': timeFrame}).toList()
        : [{'value': 'Close,Greater Than ( > ),Super Trend,10,3,AND', 'TimeFrame': timeFrame}];

    final techExit = _exitConditions.isNotEmpty
        ? _exitConditions.map((c) => {'value': c.toApiString(), 'TimeFrame': timeFrame}).toList()
        : [{'value': 'Close,Less Than ( < ),Super Trend,10,3,AND', 'TimeFrame': timeFrame}];

    final days = f.days;
    return {
      'validation': '20251217224718174', 'Tabname': 'AT_Backtest', 'Request': 'ADD',
      'Validity': f.mode, 'symbolchart': f.symbol, 'exchange': 'NSE',
      'ExpiryType': f.expiry, 'TimeFrame': timeFrame,
      'AT_EntryParameters': entryParams,
      'AT_EntryParameters_Reverse': entryReverse,
      'AT_TargetParameters': [{'FixedProfit': f.target ?? '0', 'Type': f.targetInRupees ? 'Value' : 'Percentage'}],
      'AT_ExitParameters': [{'FixedLoss': f.stopLoss ?? '0'}],
      'AT_DailyParamters': [{
        'Monday': days[0] ? 'True' : 'False', 'Tuesday': days[1] ? 'True' : 'False',
        'Wednesday': days[2] ? 'True' : 'False', 'Thursday': days[3] ? 'True' : 'False',
        'Friday': days[4] ? 'True' : 'False', 'TimeFrame': f.expiry,
      }],
      'AT_TechnicalParameters': techEntry,
      'AT_TechnicalParametersExit': techExit,
      'AT_ComputationTime': [{'EntryTime': f.entryTime, 'ExitTime': f.exitTime, 'nooftimes': f.noOfTimes.toString()}],
      'AT_BackTestParameters': [{'fromdate': fmtDate(f.fromDate), 'todate': fmtDate(f.toDate)}],
    };
  }

// run the backtesting api call
  Future<void> _runBacktest() async {
    setState(() { _isRunning = true; _resultData = null; });
    try {
      final result = await runBacktest(_buildPayload());
      if (!mounted) return;
      if (result.success) {
        setState(() {
          _resultData = result.data;
          _resultFrom = _form.fromDate;
          _resultTo = _form.toDate;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Delay so the result widget has time to lay out before we scroll.
          // Without this, ensureVisible fires before layout is done and
          // causes "RenderBox was not laid out" assertion errors.
          Future.delayed(const Duration(milliseconds: 150), () {
            if (!mounted) return;
            final ctx = _resultKey.currentContext;
            if (ctx != null) {
              Scrollable.ensureVisible(ctx,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut);
            }
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${result.error}',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w500)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 4),
        ));
      }
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 600;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(isMobile: isMobile),
      drawer: isMobile ? _buildDrawer() : null,
      body: isMobile
          ? _buildContent(context, isMobile: true)
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _IconSidebar(
                selectedIndex: _selectedNavIndex,
                onItemSelected: (i) => setState(() => _selectedNavIndex = i),
              ),
              Expanded(child: _buildContent(context, isMobile: false)),
            ]),
    );
  }

// app bar for the page
  PreferredSizeWidget _buildAppBar({required bool isMobile}) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      automaticallyImplyLeading: false,
      leadingWidth: isMobile ? 52 : 0,
      leading: isMobile
          ? Builder(builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textPrimary, size: 22),
              onPressed: () => Scaffold.of(ctx).openDrawer()))
          : null,
      title: Builder(builder: (ctx) {
        final isMob = MediaQuery.of(ctx).size.width < 600;
        return Row(children: [
          if (!isMob) ...[
            Text(' MA ', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(width: 16),
          ],
          Text(' Good Afternoon!', style: GoogleFonts.dmSans(fontSize: isMob ? 13 : 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ]);
      }),
      actions: [
        Builder(builder: (ctx) {
          final isMob = MediaQuery.of(ctx).size.width < 600;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: EdgeInsets.symmetric(horizontal: isMob ? 6 : 10),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (!isMob) Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Subcription', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.green)),
                Text('Active', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.green)),
              ]),
              const SizedBox(width: 4),
              const Icon(Icons.check_circle, size: 26, color: Colors.green),
            ]),
          );
        }),
        IconButton(icon: const Icon(Icons.help_outline, size: 19, color: AppColors.textSecondary), onPressed: () {}),
        Builder(builder: (ctx) {
          final isMob = MediaQuery.of(ctx).size.width < 600;
          return Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: isMob ? 8 : 12),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const CircleAvatar(radius: 15, backgroundColor: Colors.blue,
                child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))),
              if (!isMob) ...[
                const SizedBox(width: 6),
                Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Aman', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text('Broker: BNRATHI', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textSecondary)),
                ]),
              ],
            ]),
          );
        }),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(backgroundColor: AppColors.surface, child: SafeArea(child: _DrawerContent()));
  } 

// main content of the page
  Widget _buildContent(BuildContext context, {required bool isMobile}) {
    final w = MediaQuery.of(context).size.width;
    final hPad = isMobile ? 12.0 : (w < 1024 ? 20.0 : 28.0);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Breadcrumb(),
              const SizedBox(height: 20),
              TopBar(form: _form, onChanged: () => setState(() {})),
              const SizedBox(height: 20),
              _card(child: QuickConfigsSection(form: _form, onChanged: () => setState(() {}))),
              const SizedBox(height: 20),
              EntryConditionsSection(
                onConditionsChanged: (rows) => setState(() => _entryConditions = rows),
              ),
              const SizedBox(height: 20),
              ExitConditionsSection(
                form: _form,
                onChanged: () => setState(() {}),
                onConditionsChanged: (rows) => setState(() => _exitConditions = rows),
              ),
              const SizedBox(height: 20),
              EntryTradeSection(form: _form, onChanged: () => setState(() {})),
              const SizedBox(height: 20),
              ExitTradeSection(form: _form, onChanged: () => setState(() {})),
              const SizedBox(height: 20),
              BacktestParamsSection(form: _form, onChanged: () => setState(() {})),
              const SizedBox(height: 32),

              // ── Run button ──────────────────────────────────────
              Center(
                child: SizedBox(
                  width: isMobile ? double.infinity : 280,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? null : _runBacktest,
                    icon: _isRunning
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.play_arrow_rounded, size: 22),
                    label: Text(_isRunning ? 'Running…' : 'Run Backtest',
                        style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.accent.withOpacity(0.6),
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Results (appear after run) ──────────────────────
              if (_resultData != null) ...[
                BacktestResultSection(
                  key: _resultKey,
                  rawApiResponse: _resultData,
                  fromDate: _resultFrom!,
                  toDate: _resultTo!,
                ),
                const SizedBox(height: 32),
                _BottomActions(
                  onModify: () => _scrollController.animateTo(0,
                      duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
                  onNew: () {
                    setState(() { _resultData = null; });
                    _scrollController.animateTo(0,
                        duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                  },
                ),
                const SizedBox(height: 32),
              ],

              const _Footer(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface, borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border),
    ),
    child: child,
  );
}

// ─────────────────────────────────────────────────────────────────
//  Modify / New Backtest actions
// ─────────────────────────────────────────────────────────────────
class _BottomActions extends StatelessWidget {
  final VoidCallback onModify;
  final VoidCallback onNew;
  const _BottomActions({required this.onModify, required this.onNew});

  @override
  Widget build(BuildContext context) => Center(
    child: Wrap(spacing: 16, children: [
      OutlinedButton.icon(
        onPressed: onModify,
        icon: const Icon(Icons.edit_outlined, size: 15),
        label: Text('Modify Strategy', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      ElevatedButton.icon(
        onPressed: onNew,
        icon: const Icon(Icons.add, size: 15),
        label: Text('New Backtest', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────
//  Icon sidebar
// ─────────────────────────────────────────────────────────────────
class _IconSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  static const _navItems = [
    (icon: Icons.dashboard_outlined, label: 'Dashboard'),
    (icon: Icons.account_balance_wallet_outlined, label: 'Portfolio'),
    (icon: Icons.construction_outlined, label: 'Algo Builders'),
    (icon: Icons.candlestick_chart_outlined, label: 'Technical Algos'),
    (icon: Icons.trending_up_outlined, label: 'Easy Investment'),
    (icon: Icons.bar_chart_outlined, label: 'Research Picks'),
    (icon: Icons.build_outlined, label: 'Trading Tools'),
  ];
  const _IconSidebar({required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.show_chart, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 8),
        Expanded(child: ListView.builder(
          itemCount: _navItems.length,
          itemBuilder: (ctx, i) {
            final sel = i == selectedIndex;
            return Tooltip(
              message: _navItems[i].label,
              preferBelow: false,
              child: GestureDetector(
                onTap: () => onItemSelected(i),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_navItems[i].icon, size: 20,
                      color: sel ? AppColors.primary : AppColors.textSecondary),
                ),
              ),
            );
          },
        )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Drawer
// ─────────────────────────────────────────────────────────────────
class _DrawerContent extends StatelessWidget {
  static const _navItems = [
    (icon: Icons.dashboard_outlined, label: 'Dashboard', selected: false, hasArrow: false),
    (icon: Icons.account_balance_wallet_outlined, label: 'Portfolio', selected: false, hasArrow: false),
    (icon: Icons.construction_outlined, label: 'Algo Builders', selected: false, hasArrow: true),
    (icon: Icons.candlestick_chart_outlined, label: 'Technical Algos', selected: false, hasArrow: true),
    (icon: Icons.trending_up_outlined, label: 'Easy Investment', selected: false, hasArrow: true),
    (icon: Icons.bar_chart_outlined, label: 'Research Picks', selected: false, hasArrow: true),
    (icon: Icons.build_outlined, label: 'Trading Tools', selected: true, hasArrow: true),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _navItems.length + 3,
      itemBuilder: (context, index) {
        if (index == 0) return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: _DrawerLogoWidget(),
        );
        if (index == 1) return const Divider(height: 1);
        if (index == 2) return const SizedBox(height: 6);
        final item = _navItems[index - 3];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: item.selected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            dense: true,
            leading: Icon(item.icon, size: 18,
                color: item.selected ? AppColors.primary : AppColors.textSecondary),
            title: Text(item.label, style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: item.selected ? FontWeight.w600 : FontWeight.w400,
              color: item.selected ? AppColors.primary : AppColors.textSecondary,
            )),
            trailing: item.hasArrow
                ? Icon(Icons.expand_more, size: 15, color: AppColors.textHint) : null,
            onTap: () { if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context); },
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            visualDensity: VisualDensity.compact,
          ),
        );
      },
    );
  }
}

class _DrawerLogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
        child: const Icon(Icons.show_chart, color: Colors.white, size: 18),
      ),
      const SizedBox(width: 8),
      Text('modernalgos', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    ],
  );
}

// breadcrumb for the page static text
class _Breadcrumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Icon(Icons.home, size: 13, color: AppColors.textHint),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.chevron_right, size: 13, color: AppColors.textHint)),
      Text('Back-Testing', style: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
    ],
  );
}

class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) => Column(children: [
    const Divider(),
    const SizedBox(height: 12),
    Wrap(
      alignment: WrapAlignment.center,
      children: [Text(
        'SEBI Regn No: INH200009935 | BSE Enlistment No. 5592 | CIN No.U74999TG2022PTC162657',
        style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textHint),
        textAlign: TextAlign.center,
      )],
    ),
    const SizedBox(height: 6),
    Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      children: ['Compliance','Privacy','Terms','Disclaimer','MITC']
          .map((t) => Text(t, style: GoogleFonts.dmSans(fontSize: 11, color: Colors.blue, decoration: TextDecoration.underline)))
          .toList(),
    ),
  ]);
}