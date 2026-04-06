import 'package:uuid/uuid.dart';
import 'app_data.dart';

const _uuid = Uuid();

class ConditionModel {
  final String id;

  String indicator;
  int period;
  String operator;
  String compareTo;
  int comparePeriod;

  ConditionModel({
    String? id,
    this.indicator   = 'EMA',
    this.period      = 7,
    this.operator    = 'Crosses Above',
    this.compareTo   = 'EMA',
    this.comparePeriod = 21,
  }) : id = id ?? _uuid.v4();

  ConditionModel clone() => ConditionModel(
    id: id,
    indicator: indicator,
    period: period,
    operator: operator,
    compareTo: compareTo,
    comparePeriod: comparePeriod,
  );
}

class LegModel {
  String buySell;   // 'B' or 'S'
  String instrument;
  String strike;
  int quantity;

  LegModel({
    this.buySell    = 'B',
    this.instrument = 'CE',
    this.strike     = 'ATM',
    this.quantity   = 65,
  });

  LegModel clone() => LegModel(
    buySell: buySell,
    instrument: instrument,
    strike: strike,
    quantity: quantity,
  );
}

class BacktestFormModel {
  // ── Top bar ─────────────────────────────────────────────
  String symbol      = 'NIFTY';
  String mode        = 'Intraday';
  String timeframe   = '5 Mins';

  // Derived
  int get lotSize            => AppData.lotSize(symbol);
  List<String> get instruments => AppData.instruments(symbol);

  // ── Quick config ─────────────────────────────────────────
  String? quickConfig;

  // ── Dropdowns (will come from API later) ─────────────────
  String? technicalParam;
  String? strategy;

  // ── Entry conditions ─────────────────────────────────────
  List<ConditionModel> entryConditions = [ConditionModel()];

  // ── Exit conditions ──────────────────────────────────────
  List<ConditionModel> exitConditions  = [ConditionModel(operator: 'Crosses Below')];
  bool checkSimultaneously             = false;

  // ── Entry legs ───────────────────────────────────────────
  List<LegModel> entryLegs = [LegModel(quantity: 65)];

  // ── Exit legs ────────────────────────────────────────────
  List<LegModel> exitLegs  = [];

  // ── Backtest parameters ──────────────────────────────────
  String   timePeriod  = 'Custom';
  DateTime fromDate    = DateTime.now().subtract(const Duration(days: 7));
  DateTime toDate      = DateTime.now();
  int      noOfTimes   = 0;
  String   expiry      = 'Weekly';
  String   entryTime   = AppData.defaultEntryTime;
  String   exitTime    = AppData.defaultExitTime;
  List<bool> days      = [true, true, true, true, true]; // M T W T F

  // ── Targets ──────────────────────────────────────────────
  bool    targetInRupees = true;
  String? target;
  String? stopLoss;

  // ── Helpers ──────────────────────────────────────────────

  void selectSymbol(String s) {
    symbol = s;
    // Reset leg quantities and instruments when symbol changes
    final inst = instruments;
    for (final leg in entryLegs) {
      leg.quantity   = lotSize;
      if (!inst.contains(leg.instrument)) leg.instrument = inst.first;
    }
    for (final leg in exitLegs) {
      leg.quantity   = lotSize;
      if (!inst.contains(leg.instrument)) leg.instrument = inst.first;
    }
  }

  void incrementLegQty(LegModel leg) {
    leg.quantity += lotSize;
  }

  void decrementLegQty(LegModel leg) {
    final next = leg.quantity - lotSize;
    leg.quantity = next < lotSize ? lotSize : next;
  }
}