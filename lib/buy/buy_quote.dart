import 'package:cake_wallet/buy/buy_provider.dart';
import 'package:cake_wallet/core/selectable_option.dart';
import 'package:cake_wallet/entities/provider_types.dart';

class Quote extends SelectableOption {
  final double rate;
  final double feeAmount;
  final double networkFee;
  final double transactionFee;
  final double payout;
  final String paymentMethod;
  final BuyProvider? provider;
  final String? quoteId;
  final String? ramp;
  String sourceCurrency = '';
  String destinationCurrency = '';
  bool isSelected = false;
  bool isBestRate = false;
  bool isBuyAction;

  Quote({
    required this.rate,
    required this.feeAmount,
    required this.networkFee,
    required this.transactionFee,
    required this.payout,
    required this.provider,
    required this.paymentMethod,
    this.isBuyAction = true,
    this.quoteId,
    this.ramp,
  });

  @override
  String get title => provider?.title ?? '';

  @override
  bool get isOptionSelected => this.isSelected;

  @override
  String get iconPath => provider?.lightIcon ?? '';

  @override
  String get description => provider?.providerDescription ?? '';

  @override
  String? get firstBadgeName => isBestRate ? 'BEST RATE' : null;

  @override
  String? get secondBadgeName => provider?.isAggregator ?? false ? 'AGGREGATOR' : null;

  @override
  String? get leftSubTitle => this.rate > 0
      ? '1 $destinationCurrency = $formatedRate $sourceCurrency\ntotal fee = $formatedFee'
      : null;

  @override
  String? get rightSubTitle => this.ramp;

  String get formatedRate => isBuyAction ? rate.toStringAsFixed(2) : rate.toStringAsFixed(8);

  String get formatedFee => '$feeAmount ${isBuyAction ?  sourceCurrency : destinationCurrency}';

  void set setIsSelected(bool isSelected) => this.isSelected = isSelected;

  void set setIsBestRate(bool isBestRate) => this.isBestRate = isBestRate;

  void set setSourceCurrency(String sourceCurrency) => this.sourceCurrency = sourceCurrency;

  void set setDestinationCurrency(String destinationCurrency) =>
      this.destinationCurrency = destinationCurrency;

  factory Quote.fromOnramperJson(Map<String, dynamic> json, ProviderType providerType) {
    final rate = _toDouble(json['rate']) ?? 0.0;
    final networkFee = _toDouble(json['networkFee']) ?? 0.0;
    final transactionFee = _toDouble(json['transactionFee']) ?? 0.0;
    final feeAmount = double.parse((networkFee + transactionFee).toStringAsFixed(2));
    return Quote(
      rate: rate,
      feeAmount: feeAmount,
      networkFee: networkFee,
      transactionFee: transactionFee,
      payout: json['payout'] as double? ?? 0.0,
      ramp: json['ramp'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      quoteId: json['quoteId'] as String? ?? '',
      provider: ProvidersHelper.getProviderByType(providerType),
    );
  }

  factory Quote.fromMoonPayJson(Map<String, dynamic> json, ProviderType providerType) {
    final fee = json['feeAmount'] as double? ?? 0.0;
    final networkFee = json['networkFeeAmount'] as double? ?? 0.0;
    final transactionFee = (json['extraFeeAmount'] as int?)?.toDouble() ?? 0.0;
    final feeAmount = double.parse((fee + networkFee + transactionFee).toStringAsFixed(2));
    return Quote(
      rate: json['quoteCurrencyPrice'] as double? ?? 0.0,
      feeAmount: feeAmount,
      networkFee: networkFee,
      transactionFee: transactionFee,
      payout: json['quoteCurrencyAmount'] as double? ?? 0.0,
      paymentMethod: json['paymentMethod'] as String? ?? '',
      quoteId: json['signature'] as String? ?? '',
      provider: ProvidersHelper.getProviderByType(providerType),
    );
  }

  factory Quote.fromDFXJson(
      Map<String, dynamic> json, ProviderType providerType, bool isBuyAction) {
    final fees = json['fees'] as Map<String, dynamic>;
    return Quote(
      rate: json['exchangeRate'] as double? ?? 0.0,
      feeAmount: json['feeAmount'] as double? ?? 0.0,
      networkFee: fees['network'] as double? ?? 0.0,
      transactionFee: fees['rate'] as double? ?? 0.0,
      payout: json['payout'] as double? ?? 0.0,
      paymentMethod: json['paymentMethod'] as String? ?? '',
      provider: ProvidersHelper.getProviderByType(providerType),
      isBuyAction: isBuyAction,
    );
  }

  factory Quote.fromMeldJson(Map<String, dynamic> json, ProviderType providerType) {
    final quotes = json['quotes'][0] as Map<String, dynamic>;
    return Quote(
      rate: quotes['exchangeRate'] as double? ?? 0.0,
      feeAmount: quotes['totalFee'] as double? ?? 0.0,
      networkFee: quotes['networkFee'] as double? ?? 0.0,
      transactionFee: quotes['transactionFee'] as double? ?? 0.0,
      payout: quotes['payout'] as double? ?? 0.0,
      paymentMethod: quotes['paymentMethodType'] as String? ?? '',
      provider: ProvidersHelper.getProviderByType(providerType),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    }
    return null;
  }
}