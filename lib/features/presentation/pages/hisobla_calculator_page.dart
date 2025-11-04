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
        _displayValue = '0'; // yoki budget.totalBudget ni ko'rsatish mumkin
        _descriptionController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                Expanded(
                  flex: MediaQuery.of(context).size.height < 700 ? 3 : 4,
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
                Expanded(
                  flex: MediaQuery.of(context).size.height < 700 ? 7 : 6,
                  child: CalculatorKeypad(
                    onNumberPressed: _onNumberPressed,
                    onClearPressed: _onClearPressed,
                    onDonePressed: _onDonePressed,
                  ),
                ),
                // Banner Reklama
                if (_isBannerAdLoaded && _bannerAd != null)
                  Container(
                    color: Colors.white,
                    height: _bannerAd!.size.height.toDouble(),
                    width: _bannerAd!.size.width.toDouble(),
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
