import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hisobla/core/ads/ads_helper.dart';
import 'package:hisobla/features/presentation/blocs/hisobla_bloc/hisobla_bloc.dart';
import 'package:hisobla/features/presentation/blocs/hisobla_bloc/hisobla_event.dart';
import 'package:hisobla/features/presentation/blocs/hisobla_bloc/hisobla_state.dart';
import 'package:hisobla/features/presentation/widgets/hisobla_budget_display.dart';
import 'package:hisobla/features/presentation/widgets/hisobla_keypad.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _displayValue = '0';
  String _description = '';
  bool _isEditingBudget = false;
  final TextEditingController _descriptionController = TextEditingController();

  // Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() {
      setState(() {
        _description = _descriptionController.text;
      });
    });

    // Banner reklama yuklash
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdsHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isBannerAdLoaded = false;
        },
      ),
    );

    _bannerAd!.load();
  }

  void _onNumberPressed(String number) {
    setState(() {
      if (_displayValue == '0' && number != '000') {
        _displayValue = number == '000' ? '0' : number;
      } else {
        _displayValue += number;
      }
      // 000 ni to'g'ri ishlash
      if (number == '000') {
        _displayValue = _displayValue.replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}',
        );
      }
    });
  }

  void _onClearPressed() {
    setState(() {
      _displayValue = '0';
      _description = '';
      _descriptionController.clear();
    });
  }

  void _onDonePressed() {
    final amount = double.tryParse(_displayValue.replaceAll(' ', ''));
    if (amount == null || amount <= 0) return;

    final bloc = context.read<BudgetBloc>();

    if (_isEditingBudget) {
      bloc.add(SetBudgetEvent(amount));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Byudjet saqlandi')));
    } else {
      bloc.add(AddExpenseEvent(amount, _description));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Xarajat qo\'shildi')));
    }

    // Ads counter increment
    AdsManager().incrementActionCounter();

    _onClearPressed();
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditingBudget) {
        // Chiqish: hamma narsani tiklash
        _isEditingBudget = false;
        _displayValue = '0';
        _descriptionController.clear();
      } else {
        // Kirish: faqat byudjetni tahrirlash
        _isEditingBudget = true;
        _displayValue = '0';
        _descriptionController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = _isBannerAdLoaded && _bannerAd != null
        ? _bannerAd!.size.height.toDouble()
        : 0.0;

    // Ekran balandligiga qarab flex qiymatlarini dinamik hisoblash
    final availableHeight =
        screenHeight - bannerHeight - MediaQuery.of(context).padding.top;

    // Kichik ekranlar uchun (< 650px)
    final isVerySmallScreen = availableHeight < 650;
    // O'rta ekranlar uchun (650-750px)
    final isSmallScreen = availableHeight >= 650 && availableHeight < 750;

    int displayFlex;
    int keypadFlex;

    if (isVerySmallScreen) {
      // Juda kichik ekranlar - keypad ko'proq joy oladi
      displayFlex = 3;
      keypadFlex = 7;
    } else if (isSmallScreen) {
      // O'rta ekranlar - muvozanatli
      displayFlex = 4;
      keypadFlex = 6;
    } else {
      // Katta ekranlar - display ko'proq joy oladi
      displayFlex = 5;
      keypadFlex = 5;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BudgetLoaded) {
            return Column(
              children: [
                // Budget Display - moslashuvchan
                Expanded(
                  flex: displayFlex,
                  child: BudgetDisplay(
                    budget: state.budget,
                    displayValue: _displayValue,
                    description: _description,
                    isEditingBudget: _isEditingBudget,
                    onEditBudget: _toggleEditMode,
                    descriptionController: _descriptionController,
                    onDescriptionChanged: (value) {
                      setState(() {
                        _description = value;
                      });
                    },
                  ),
                ),
                // Keypad - moslashuvchan
                Expanded(
                  flex: keypadFlex,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return CalculatorKeypad(
                        onNumberPressed: _onNumberPressed,
                        onClearPressed: _onClearPressed,
                        onDonePressed: _onDonePressed,
                        // Ekran balandligini keypad'ga uzatish
                        availableHeight: constraints.maxHeight,
                      );
                    },
                  ),
                ),
                // Banner Reklama - faqat kerak bo'lganda ko'rinadi
                if (_isBannerAdLoaded && _bannerAd != null)
                  Container(
                    color: Colors.white,
                    height: bannerHeight,
                    width: double.infinity,
                    child: AdWidget(ad: _bannerAd!),
                  ),
              ],
            );
          }

          return const Center(child: Text('Xatolik yuz berdi'));
        },
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }
}
