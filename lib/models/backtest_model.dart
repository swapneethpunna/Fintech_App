import 'dart:convert';

RunBackTesting runBackTestingFromJson(String str) => RunBackTesting.fromJson(json.decode(str));

String runBackTestingToJson(RunBackTesting data) => json.encode(data.toJson());

class RunBackTesting {
    List<Summary> summary;
    List<Graph> graph;
    List<Metric> metrics;
    List<Trade> trades;

    RunBackTesting({
        required this.summary,
        required this.graph,
        required this.metrics,
        required this.trades,
    });

    factory RunBackTesting.fromJson(Map<String, dynamic> json) => RunBackTesting(
        summary: List<Summary>.from(json["Summary"].map((x) => Summary.fromJson(x))),
        graph: List<Graph>.from(json["Graph"].map((x) => Graph.fromJson(x))),
        metrics: List<Metric>.from(json["Metrics"].map((x) => Metric.fromJson(x))),
        trades: List<Trade>.from(json["Trades"].map((x) => Trade.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "Summary": List<dynamic>.from(summary.map((x) => x.toJson())),
        "Graph": List<dynamic>.from(graph.map((x) => x.toJson())),
        "Metrics": List<dynamic>.from(metrics.map((x) => x.toJson())),
        "Trades": List<dynamic>.from(trades.map((x) => x.toJson())),
    };
}

class Graph {
    DateTime tradingdate;
    double cummulativepl;
    double underlyingprice;
    double dradownDay;

    Graph({
        required this.tradingdate,
        required this.cummulativepl,
        required this.underlyingprice,
        required this.dradownDay,
    });

    factory Graph.fromJson(Map<String, dynamic> json) => Graph(
        tradingdate: DateTime.parse(json["tradingdate"]),
        cummulativepl: json["cummulativepl"]?.toDouble(),
        underlyingprice: json["underlyingprice"]?.toDouble(),
        dradownDay: json["dradown_day"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "tradingdate": "${tradingdate.year.toString().padLeft(4, '0')}-${tradingdate.month.toString().padLeft(2, '0')}-${tradingdate.day.toString().padLeft(2, '0')}",
        "cummulativepl": cummulativepl,
        "underlyingprice": underlyingprice,
        "dradown_day": dradownDay,
    };
}

class Metric {
    String metric;
    double value;

    Metric({
        required this.metric,
        required this.value,
    });

    factory Metric.fromJson(Map<String, dynamic> json) => Metric(
        metric: json["Metric"],
        value: json["Value"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "Metric": metric,
        "Value": value,
    };
}

class Summary {
    int totalWeeks;
    int success;
    int failure;
    int successPer;
    int failurePer;
    int capital;
    double grossProfitLoss;
    double grossProfitLossPer;

    Summary({
        required this.totalWeeks,
        required this.success,
        required this.failure,
        required this.successPer,
        required this.failurePer,
        required this.capital,
        required this.grossProfitLoss,
        required this.grossProfitLossPer,
    });

    factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        totalWeeks: json["TotalWeeks"],
        success: json["Success"],
        failure: json["Failure"],
        successPer: json["Success_per"],
        failurePer: json["Failure_per"],
        capital: json["Capital"],
        grossProfitLoss: json["GrossProfitLoss"]?.toDouble(),
        grossProfitLossPer: json["GrossProfitLoss_per"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "TotalWeeks": totalWeeks,
        "Success": success,
        "Failure": failure,
        "Success_per": successPer,
        "Failure_per": failurePer,
        "Capital": capital,
        "GrossProfitLoss": grossProfitLoss,
        "GrossProfitLoss_per": grossProfitLossPer,
    };
}

class Trade {
    DateTime entryDate;
    String entryTime;
    DateTime exitDate;
    String exitTime;
    Type type;
    int strike;
    BS bS;
    int qty;
    double entryPrice;
    double exitPrice;
    double pL;

    Trade({
        required this.entryDate,
        required this.entryTime,
        required this.exitDate,
        required this.exitTime,
        required this.type,
        required this.strike,
        required this.bS,
        required this.qty,
        required this.entryPrice,
        required this.exitPrice,
        required this.pL,
    });

    factory Trade.fromJson(Map<String, dynamic> json) => Trade(
        entryDate: DateTime.parse(json["EntryDate"]),
        entryTime: json["EntryTime"],
        exitDate: DateTime.parse(json["ExitDate"]),
        exitTime: json["ExitTime"],
        type: typeValues.map[json["Type"]]!,
        strike: json["Strike"],
        bS: bsValues.map[json["B/S"]]!,
        qty: json["Qty"],
        entryPrice: json["EntryPrice"]?.toDouble(),
        exitPrice: json["ExitPrice"]?.toDouble(),
        pL: json["P/L"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "EntryDate": entryDate.toIso8601String(),
        "EntryTime": entryTime,
        "ExitDate": exitDate.toIso8601String(),
        "ExitTime": exitTime,
        "Type": typeValues.reverse[type],
        "Strike": strike,
        "B/S": bsValues.reverse[bS],
        "Qty": qty,
        "EntryPrice": entryPrice,
        "ExitPrice": exitPrice,
        "P/L": pL,
    };
}

enum BS {
    SELL
}

final bsValues = EnumValues({
    "Sell": BS.SELL
});

enum Type {
    CE,
    PE
}

final typeValues = EnumValues({
    "CE": Type.CE,
    "PE": Type.PE
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}

