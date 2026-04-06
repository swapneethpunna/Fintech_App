import 'package:backtesting_app/models/backtest_model.dart';
import 'package:backtesting_app/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';


class BacktestResultSection extends StatefulWidget {
  final dynamic rawApiResponse;
  final DateTime fromDate;
  final DateTime toDate;

  const BacktestResultSection({
    super.key,
    required this.rawApiResponse,
    required this.fromDate,
    required this.toDate,
  });

  @override
  State<BacktestResultSection> createState() => _BacktestResultSectionState();
}

class _BacktestResultSectionState extends State<BacktestResultSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  RunBackTesting? _result;
  String? _parseError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _parseResponse();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _parseResponse() {
    try {
      if (widget.rawApiResponse is Map<String, dynamic>) {
        _result = RunBackTesting.fromJson(
            widget.rawApiResponse as Map<String, dynamic>);
      }
    } catch (e) {
      _parseError = e.toString();
    }
  }

  String _fmtDate(DateTime d) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border.all(color: AppColors.border),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;

              return isSmall
                  ? Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Icon(Icons.bar_chart_rounded,
                            size: 18, color: AppColors.primary),

                        Text(
                          'Backtest Results',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        Text(
                          '${_fmtDate(widget.fromDate)}  ·  ${_fmtDate(widget.toDate)}',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        // Button comes in next line automatically
                        _ExportBtn(),
                      ],
                    )
                  : Row(
                      children: [
                        const Icon(Icons.bar_chart_rounded,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Text(
                          'Backtest Results',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${_fmtDate(widget.fromDate)}  ·  ${_fmtDate(widget.toDate)}',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        _ExportBtn(),
                      ],
                    );
            },
          ),
        ),

        // ── Tab bar ──────────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              left: BorderSide(color: AppColors.border),
              right: BorderSide(color: AppColors.border),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle:
                GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 13),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            tabs: const [
              Tab(text: 'Metrics'),
              Tab(text: 'Equity Curve'),
              Tab(text: 'Trade Log'),
            ],
          ),
        ),

        // ── Tab content ─────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            border: Border.all(color: AppColors.border),
          ),
          child: _result == null
              ? _ErrorView(error: _parseError)
              : IndexedStack(
                  index: _tabController.index,
                  children: [
                    _MetricsTab(
                      summary: _result!.summary,
                      metrics: _result!.metrics,
                    ),
                    _EquityCurveTab(graph: _result!.graph),
                    _TradeLogTab(trades: _result!.trades),
                  ],
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Error view
// ─────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String? error;
  const _ErrorView({this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 36, color: AppColors.error),
          const SizedBox(height: 10),
          Text('Could not parse API response',
              style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          if (error != null) ...[
            const SizedBox(height: 6),
            Text(error!,
                style: GoogleFonts.dmSans(
                    fontSize: 11, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  TAB 1 — Metrics
// ════════════════════════════════════════════════════════════════
class _MetricsTab extends StatelessWidget {
  final List<Summary> summary;
  final List<Metric> metrics;

  const _MetricsTab({required this.summary, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final s = summary.isNotEmpty ? summary.first : null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (s != null) ...[
            LayoutBuilder(builder: (ctx, constraints) {
              final cols = constraints.maxWidth > 700 ? 4 : 2;
              final cardW = (constraints.maxWidth - 12 * (cols - 1)) / cols;
              final items = [
                _CardData(
                    label: 'TOTAL WEEKS',
                    value: '${s.totalWeeks}',
                    isPositive: null),
                _CardData(
                    label: 'SUCCESS',
                    value: '${s.success} (${s.successPer}%)',
                    isPositive: true),
                _CardData(
                    label: 'FAILURE',
                    value: '${s.failure} (${s.failurePer}%)',
                    isPositive: s.failure == 0),
                _CardData(
                    label: 'GROSS P&L',
                    value:
                        '₹${s.grossProfitLoss.toStringAsFixed(2)} (${s.grossProfitLossPer.toStringAsFixed(2)}%)',
                    isPositive: s.grossProfitLoss >= 0),
              ];
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: items
                    .map((d) =>
                        SizedBox(width: cardW, child: _StatCard(data: d)))
                    .toList(),
              );
            }),
            const SizedBox(height: 12),
          ],
          LayoutBuilder(builder: (ctx, constraints) {
            final cols = constraints.maxWidth > 900
                ? 4
                : constraints.maxWidth > 600
                    ? 3
                    : 2;
            final cardW = (constraints.maxWidth - 12 * (cols - 1)) / cols;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: metrics
                  .map((m) => SizedBox(
                        width: cardW,
                        child: _StatCard(
                          data: _CardData(
                            label: m.metric.toUpperCase(),
                            value: m.value.toStringAsFixed(2),
                            isPositive: m.value >= 0,
                          ),
                        ),
                      ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _CardData {
  final String label;
  final String value;
  final bool? isPositive;
  const _CardData(
      {required this.label, required this.value, required this.isPositive});
}

class _StatCard extends StatelessWidget {
  final _CardData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final Color valueColor = data.isPositive == null
        ? AppColors.primary
        : data.isPositive!
            ? Colors.green
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(data.label,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(data.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: valueColor)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  TAB 2 — Equity Curve
// ════════════════════════════════════════════════════════════════
class _EquityCurveTab extends StatelessWidget {
  final List<Graph> graph;
  const _EquityCurveTab({required this.graph});

  @override
  Widget build(BuildContext context) {
    if (graph.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Text('No graph data available',
              style:
                  GoogleFonts.dmSans(fontSize: 13, color: AppColors.textHint)),
        ),
      );
    }

    final equitySeries = graph.map((g) => g.cummulativepl).toList();
    final drawdownSeries = graph.map((g) => g.dradownDay).toList();
    final maxDD = drawdownSeries.reduce((a, b) => a < b ? a : b);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(builder: (ctx, constraints) {
        final wide = constraints.maxWidth > 700;

        final equityCard = _ChartCard(
          title: 'Equity Curve',
          icon: Icons.show_chart,
          iconColor: AppColors.primary,
          child: _FlLineChart(
            series: equitySeries,
            lineColor: AppColors.primary,
          ),
        );

        final drawdownCard = _ChartCard(
          title: 'Drawdown',
          icon: Icons.trending_down,
          iconColor: AppColors.error,
          subtitle: 'Max Drawdown: ${maxDD.toStringAsFixed(2)}',
          child: _FlLineChart(
            series: drawdownSeries,
            lineColor: AppColors.error,
          ),
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: equityCard),
              const SizedBox(width: 16),
              Expanded(child: drawdownCard),
            ],
          );
        }

        return Column(
          children: [
            equityCard,
            const SizedBox(height: 16),
            drawdownCard,
          ],
        );
      }),
    );
  }
}

class _FlLineChart extends StatelessWidget {
  final List<double> series;
  final Color lineColor;

  const _FlLineChart({required this.series, required this.lineColor});

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
      series.length,
      (i) => FlSpot(i.toDouble(), series[i]),
    );

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: series.reduce((a, b) => a < b ? a : b),
          maxY: series.reduce((a, b) => a > b ? a : b),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (series.reduce((a, b) => a > b ? a : b) -
                    series.reduce((a, b) => a < b ? a : b)) /
                4,
          ),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: AppColors.border),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: lineColor,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withValues(alpha: 0.15),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    spot.y.toStringAsFixed(2),
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String? subtitle;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 6),
            Text(title,
                style: GoogleFonts.dmSans(
                    fontSize: 14, fontWeight: FontWeight.w700)),
          ]),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!,
                style: GoogleFonts.dmSans(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Breakpoint helper
//  mobile  : width < 480
//  tablet  : 480 ≤ width < 900
//  desktop : width ≥ 900
// ════════════════════════════════════════════════════════════════
enum _ScreenSize { mobile, tablet, desktop }

_ScreenSize _screenSize(double width) {
  if (width < 480) return _ScreenSize.mobile;
  if (width < 900) return _ScreenSize.tablet;
  return _ScreenSize.desktop;
}

// ════════════════════════════════════════════════════════════════
//  Column descriptor
// ════════════════════════════════════════════════════════════════
class _ColDef {
  final String header;
  final double width;
  const _ColDef(this.header, this.width);
}

// ════════════════════════════════════════════════════════════════
//  TAB 3 — Trade Log  (fully responsive)
//
//  mobile  (< 480 px) : SEQNO | SYMBOL | P&L
//  tablet  (480–899)  : SEQNO | SYMBOL | ENTRY TIME | EXIT TIME | DIRECTION | P&L
//  desktop (≥ 900 px) : all 9 columns
// ════════════════════════════════════════════════════════════════
class _TradeLogTab extends StatefulWidget {
  final List<Trade> trades;
  const _TradeLogTab({required this.trades});

  @override
  State<_TradeLogTab> createState() => _TradeLogTabState();
}

class _TradeLogTabState extends State<_TradeLogTab> {
  int _perPage = 10;
  int _currentPage = 1;
  String _search = '';

  // ── column definitions per breakpoint ────────────────────────
  static const List<_ColDef> _mobileCols = [
    _ColDef('SEQ', 60),
    _ColDef('SYMBOL', 90),
    _ColDef('P&L', 90),
  ];

  static const List<_ColDef> _tabletCols = [
    _ColDef('SEQ', 60),
    _ColDef('SYMBOL', 90),
    _ColDef('ENTRY TIME', 130),
    _ColDef('EXIT TIME', 130),
    _ColDef('DIRECTION', 100),
    _ColDef('P&L', 90),
  ];

  static const List<_ColDef> _desktopCols = [
    _ColDef('SEQ', 70),
    _ColDef('SYMBOL', 100),
    _ColDef('ENTRY TIME', 130),
    _ColDef('EXIT TIME', 130),
    _ColDef('DIRECTION', 100),
    _ColDef('ENTRY PRICE', 110),
    _ColDef('EXIT PRICE', 110),
    _ColDef('QTY', 80),
    _ColDef('P&L', 90),
  ];

  List<_ColDef> _colsFor(_ScreenSize sz) {
    switch (sz) {
      case _ScreenSize.mobile:
        return _mobileCols;
      case _ScreenSize.tablet:
        return _tabletCols;
      case _ScreenSize.desktop:
        return _desktopCols;
    }
  }

  // ── filtering / paging ───────────────────────────────────────
  List<Trade> get _filtered {
    if (_search.isEmpty) return widget.trades;
    final q = _search.toLowerCase();
    return widget.trades.where((t) {
      final bs = bsValues.reverse[t.bS] ?? '';
      final type = typeValues.reverse[t.type] ?? '';
      return '$type ${t.strike} $bs ${t.qty} ${t.pL} '
              '${t.entryTime} ${t.exitTime}'
          .toLowerCase()
          .contains(q);
    }).toList();
  }

  List<Trade> get _paged {
    final f = _filtered;
    final start = (_currentPage - 1) * _perPage;
    if (start >= f.length) return [];
    return f.sublist(start, (start + _perPage).clamp(0, f.length));
  }

  int get _totalPages => (_filtered.length / _perPage).ceil().clamp(1, 9999);

  String _formatDateTime(DateTime date, String time) {
    final d = '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
    return '$d $time';
  }

  // ── build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final paged = _paged;
    final start = (_currentPage - 1) * _perPage + 1;
    final end = (start + paged.length - 1).clamp(0, filtered.length);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Controls ─────────────────────────────────────────
          LayoutBuilder(builder: (ctx, constraints) {
            final isNarrow = constraints.maxWidth < 480;
            return isNarrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPerPageRow(),
                      const SizedBox(height: 8),
                      _buildSearchField(),
                    ],
                  )
                : Row(children: [
                    _buildPerPageRow(),
                    const Spacer(),
                    Text('Search: ',
                        style: GoogleFonts.dmSans(
                            fontSize: 13, color: AppColors.textSecondary)),
                    _buildSearchField(),
                  ]);
          }),

          const SizedBox(height: 14),

          // ── Table ────────────────────────────────────────────
          widget.trades.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text('No trades available',
                        style: GoogleFonts.dmSans(
                            fontSize: 13, color: AppColors.textHint)),
                  ),
                )
              : LayoutBuilder(builder: (ctx, constraints) {
                  final sz = _screenSize(constraints.maxWidth);
                  final cols = _colsFor(sz);
                  final minTableWidth =
                      cols.fold<double>(0, (sum, c) => sum + c.width);

                  // Desktop: always stretch to fill available width (no scroll).
                  // Mobile/tablet: scroll only when fixed widths exceed space.
                  if (sz == _ScreenSize.desktop) {
                    return _buildTable(
                      paged,
                      cols,
                      sz,
                      availableWidth: constraints.maxWidth,
                    );
                  }

                  final needsScroll = minTableWidth > constraints.maxWidth;
                  Widget table = _buildTable(paged, cols, sz);
                  if (needsScroll) {
                    table = SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(width: minTableWidth, child: table),
                    );
                  }
                  return table;
                }),

          const SizedBox(height: 14),

          // ── Footer ───────────────────────────────────────────
          LayoutBuilder(builder: (ctx, constraints) {
            final isNarrow = constraints.maxWidth < 480;
            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.trades.isEmpty
                        ? 'No data'
                        : 'Showing $start–$end of ${filtered.length}',
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  if (widget.trades.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _Pagination(
                      current: _currentPage,
                      total: _totalPages,
                      onChanged: (p) => setState(() => _currentPage = p),
                    ),
                  ],
                ],
              );
            }
            return Row(children: [
              Text(
                widget.trades.isEmpty
                    ? 'No data'
                    : 'Showing $start to $end of ${filtered.length} entries',
                style: GoogleFonts.dmSans(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              const Spacer(),
              if (widget.trades.isNotEmpty)
                _Pagination(
                  current: _currentPage,
                  total: _totalPages,
                  onChanged: (p) => setState(() => _currentPage = p),
                ),
            ]);
          }),
        ],
      ),
    );
  }

  // ── helper widgets ───────────────────────────────────────────
  Widget _buildPerPageRow() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _perPage,
                isDense: true,
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: AppColors.textPrimary),
                items: [5, 10, 25, 50]
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _perPage = v;
                      _currentPage = 1;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('entries per page',
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: AppColors.textSecondary)),
        ],
      );

  Widget _buildSearchField() => SizedBox(
        width: 180,
        child: TextField(
          onChanged: (v) => setState(() {
            _search = v;
            _currentPage = 1;
          }),
          style: GoogleFonts.dmSans(fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide:
                    const BorderSide(color: AppColors.borderFocus, width: 1.5)),
          ),
        ),
      );

  // ── table builder ────────────────────────────────────────────
  // [availableWidth] is supplied only for desktop; when provided the columns
  // stretch proportionally to fill the full row width.
  Widget _buildTable(List<Trade> rows, List<_ColDef> cols, _ScreenSize sz,
      {double? availableWidth}) {
    final colWidths = <int, TableColumnWidth>{};

    if (sz == _ScreenSize.desktop && availableWidth != null) {
      // Use the fixed widths as flex ratios so every column scales up together.
      for (int i = 0; i < cols.length; i++) {
        colWidths[i] = FlexColumnWidth(cols[i].width);
      }
    } else {
      for (int i = 0; i < cols.length; i++) {
        colWidths[i] = FixedColumnWidth(cols[i].width);
      }
    }

    return Table(
      columnWidths: colWidths,
      border: TableBorder(
        horizontalInside:
            BorderSide(color: AppColors.border.withValues(alpha: 0.7)),
        top: BorderSide(color: AppColors.border),
        bottom: BorderSide(color: AppColors.border),
      ),
      children: [
        // ── Header row ──────────────────────────────────────────
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF8F8F8)),
          children: cols
              .map((c) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Text(c.header,
                        style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.4)),
                  ))
              .toList(),
        ),

        // ── Data rows ────────────────────────────────────────────
        ...rows.asMap().entries.map((entry) {
          final i = entry.key;
          final t = entry.value;
          final isSell = t.bS == BS.SELL;
          final plPositive = t.pL >= 0;
          final plText = plPositive
              ? '+${t.pL.toStringAsFixed(2)}'
              : t.pL.toStringAsFixed(2);
          final seqNo = (_currentPage - 1) * _perPage + i + 1;

          // Build cells according to which columns are visible
          final cells = cols.map((c) {
            switch (c.header) {
              case 'SEQ':
                return _cell('$seqNo',
                    color: AppColors.textSecondary, fontSize: 12);

              case 'SYMBOL':
                return _cell('NIFTY', fontSize: 12);

              case 'ENTRY TIME':
                return _cell(_formatDateTime(t.entryDate, t.entryTime),
                    fontSize: 11);

              case 'EXIT TIME':
                return _cell(_formatDateTime(t.exitDate, t.exitTime),
                    fontSize: 11);

              case 'DIRECTION':
                return _directionCell(isSell);

              case 'ENTRY PRICE':
                return _cell(t.entryPrice.toStringAsFixed(2), fontSize: 12);

              case 'EXIT PRICE':
                return _cell(t.exitPrice.toStringAsFixed(2), fontSize: 12);

              case 'QTY':
                return _cell('${t.qty}', fontSize: 12);

              case 'P&L':
                return _cell(plText,
                    color: plPositive ? Colors.green : AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600);

              default:
                return _cell('');
            }
          }).toList();

          return TableRow(
            decoration: BoxDecoration(
              color: i.isEven ? AppColors.surface : const Color(0xFFFAFAFA),
            ),
            children: cells,
          );
        }),
      ],
    );
  }

  // ── cell helpers ─────────────────────────────────────────────
  Widget _cell(
    String text, {
    Color? color,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w400,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Text(
          text,
          style: GoogleFonts.dmSans(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      );

  Widget _directionCell(bool isSell) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isSell
                ? AppColors.error.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSell
                  ? AppColors.error.withOpacity(0.4)
                  : AppColors.primary.withOpacity(0.4),
            ),
          ),
          child: Center(
            child: Text(
              isSell ? 'SELL' : 'BUY',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSell ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────
//  Pagination
// ─────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────
//  Pagination  — grouped pill: «  ‹  [current]  ›  »
// ─────────────────────────────────────────────────────────────────
class _Pagination extends StatelessWidget {
  final int current;
  final int total;
  final ValueChanged<int> onChanged;

  const _Pagination(
      {required this.current, required this.total, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // Only «  ‹  [current]  ›  » — single active page number
    final items = <_PgItem>[
      _PgItem.nav('«', current > 1 ? () => onChanged(1) : null),
      _PgItem.nav('‹', current > 1 ? () => onChanged(current - 1) : null),
      _PgItem.page(current, true, () {}),
      _PgItem.nav('›', current < total ? () => onChanged(current + 1) : null),
      _PgItem.nav('»', current < total ? () => onChanged(total) : null),
    ];

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isLast = idx == items.length - 1;

              Widget cell;

              if (item.isSelected) {
                // Active page — solid blue inset tile
                cell = Container(
                  width: 36,
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.info,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${item.label}',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              } else {
                // Nav button («  ‹  ›  »)
                final enabled = item.onTap != null;
                cell = InkWell(
                  onTap: item.onTap,
                  child: Container(
                    width: 36,
                    alignment: Alignment.center,
                    child: Text(
                      '${item.label}',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: enabled
                            ? AppColors.textSecondary
                            : AppColors.textHint.withOpacity(0.35),
                      ),
                    ),
                  ),
                );
              }

              // Thin vertical divider between cells, not after the last
              if (isLast) return cell;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  cell,
                  Container(width: 1, height: 36, color: AppColors.border),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Lightweight data class for each pagination cell ──────────────
class _PgItem {
  final Object label; // String or int
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isNav;

  const _PgItem._({
    required this.label,
    this.onTap,
    this.isSelected = false,
    this.isNav = false,
  });

  factory _PgItem.nav(String symbol, VoidCallback? onTap) =>
      _PgItem._(label: symbol, onTap: onTap, isNav: true);

  factory _PgItem.page(int p, bool selected, VoidCallback onTap) =>
      _PgItem._(label: p, onTap: onTap, isSelected: selected);
}
// ─────────────────────────────────────────────────────────────────
//  Export button
// ─────────────────────────────────────────────────────────────────
class _ExportBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Export coming soon',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w500)),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 2),
          ));
        },
        icon: const Icon(Icons.download_outlined, size: 14),
        label: Text('Export',
            style:
                GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
      );
}
