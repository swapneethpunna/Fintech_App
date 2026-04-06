// app_data.dart — All static data / constants used across the UI.

class AppData {
  AppData._();

  // Symbol → lot size
  static const Map<String, int> symbolLotSize = {
    'NIFTY': 65,
    'BANKNIFTY': 30,
    'RELIANCE': 500,
    'SBIN': 750,
    'TATASTEEL': 5500,
  };

  static List<String> get symbols => symbolLotSize.keys.toList();

  static int lotSize(String symbol) => symbolLotSize[symbol] ?? 1;

  // Instrument options depend on symbol
  static List<String> instruments(String symbol) {
    if (symbol == 'NIFTY' || symbol == 'BANKNIFTY') {
      return ['CE', 'PE', 'FUT'];
    }
    return ['EQ', 'FUT', 'CE', 'PE'];
  }

  static const List<String> modes = ['Intraday', 'Positional'];
  static const List<String> timeframes = [
    '1 Min',
    '3 Mins',
    '5 Mins',
    '10 Mins',
    '15 Mins',
    '30 Mins',
    '1 Hour',
    '1 Day'
  ];
  static const List<String> strikes = ['ATM', 'ITM1', 'ITM2', 'OTM1', 'OTM2'];
  static const List<String> timePeriods = [
    'Custom',
    '1 Month',
    '3 Months',
    '6 Months',
    '1 Year'
  ];

  // Quick config presets (matching screenshots)
  static const List<String> quickConfigs = [
    'EMA CrossOver',
    'SuperTrend',
    'Parabolic SAR',
    'BBands BreakOut',
    'MACD Crosssover',
  ];

  static const List<String> indicators = [
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
  static const List<String> operators = [
    'Crosses Above',
    'Crosses Below',
    'Greater Than',
    'Less Than',
    'Equals'
  ];

  // Dummy dropdown items (will be replaced by API later)
  static const List<String> technicalParams = [
    'EMA',
    'SMA',
    'RSI',
    'MACD',
    'Bollinger Bands',
    'Stochastic',
    'ADX'
  ];
  static const List<String> strategies = [
    'EMA CrossOver',
    'SuperTrend',
    'Parabolic SAR',
    'BBands BreakOut',
    'MACD Crosssover'
  ];

  static const String defaultEntryTime = '09:15';
  static const String defaultExitTime = '15:30';
  static const List<String> weekdays = ['M', 'T', 'W', 'T', 'F'];
}
