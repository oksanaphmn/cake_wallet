import 'package:cake_wallet/core/fiat_conversion_service.dart';
import 'package:cake_wallet/entities/fiat_api_mode.dart';
import 'package:cake_wallet/entities/sort_balance_types.dart';
import 'package:cake_wallet/ethereum/ethereum.dart';
import 'package:cake_wallet/store/settings_store.dart';
import 'package:cake_wallet/view_model/dashboard/balance_view_model.dart';
import 'package:cw_core/crypto_currency.dart';
import 'package:cw_core/erc20_token.dart';
import 'package:mobx/mobx.dart';

part 'home_settings_view_model.g.dart';

class HomeSettingsViewModel = HomeSettingsViewModelBase with _$HomeSettingsViewModel;

abstract class HomeSettingsViewModelBase with Store {
  HomeSettingsViewModelBase(this._settingsStore, this._balanceViewModel);

  final SettingsStore _settingsStore;
  final BalanceViewModel _balanceViewModel;

  @observable
  String searchText = '';

  @computed
  SortBalanceBy get sortBalanceBy => _settingsStore.sortBalanceBy;

  @action
  void setSortBalanceBy(SortBalanceBy value) => _settingsStore.sortBalanceBy = value;

  @computed
  bool get pinNativeToken => _settingsStore.pinNativeTokenAtTop;

  @action
  void setPinNativeToken(bool value) => _settingsStore.pinNativeTokenAtTop = value;

  Future<void> addErc20Token(Erc20Token token) async {
    await ethereum!.addErc20Token(_balanceViewModel.wallet, token);
    _updateFiatPrices(token);
  }

  Future<void> deleteErc20Token(Erc20Token token) async {
    await ethereum!.deleteErc20Token(_balanceViewModel.wallet, token);
  }

  Future<Erc20Token?> getErc20Token(String contractAddress) async =>
      await ethereum!.getErc20Token(_balanceViewModel.wallet, contractAddress);

  CryptoCurrency get nativeToken => _balanceViewModel.wallet.currency;

  void _updateFiatPrices(Erc20Token token) async {
    try {
      _balanceViewModel.fiatConvertationStore.prices[token] =
          await FiatConversionService.fetchPrice(
              crypto: token,
              fiat: _settingsStore.fiatCurrency,
              torOnly: _settingsStore.fiatApiMode == FiatApiMode.torOnly);
    } catch (_) {}
  }

  void changeTokenAvailability(int index, bool value) async {
    tokens.elementAt(index).enabled = value;
    _balanceViewModel.wallet.updateBalance();
  }

  @computed
  Set<Erc20Token> get tokens {
    final Set<Erc20Token> tokens = {};

    _balanceViewModel.formattedBalances.forEach((e) {
      if (e.asset is Erc20Token && _matchesSearchText(e.asset as Erc20Token)) {
        tokens.add(e.asset as Erc20Token);
      }
    });

    tokens.addAll(ethereum!
        .getERC20Currencies(_balanceViewModel.wallet)
        .where((element) => _matchesSearchText(element)));

    return tokens;
  }

  @action
  void changeSearchText(String text) => searchText = text;

  bool _matchesSearchText(Erc20Token asset) {
    return searchText.isEmpty ||
        asset.fullName!.toLowerCase().contains(searchText.toLowerCase()) ||
        asset.title.toLowerCase().contains(searchText.toLowerCase()) ||
        asset.contractAddress == searchText;
  }
}