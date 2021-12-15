import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dialogs/custom_error_dialog.dart';
import '../dialogs/custom_success_dialog.dart';
import '../viewmodels/user_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/spaces.dart';
import '../values/values.dart';
import '../widgets/custom_app_bar.dart';

class BuyPremiumScreen extends StatefulWidget {
  final String userId;
  BuyPremiumScreen({this.userId});
  @override
  _BuyPremiumScreenState createState() => _BuyPremiumScreenState();
}

class _BuyPremiumScreenState extends State<BuyPremiumScreen> {
  bool _isLoading = true;
  bool _isErrorOccured = false;

  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;
  /* StreamSubscription _conectionSubscription; */

  final List<String> _productLists = [
    'item_id_here',
  ];

  List<IAPItem> _items = [];

  ConfettiController _controllerCenterRight;
  ConfettiController _controllerCenterLeft;

  @override
  void initState() {
    super.initState();
    _controllerCenterRight = ConfettiController(duration: const Duration(seconds: 5));
    _controllerCenterLeft = ConfettiController(duration: const Duration(seconds: 5));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _initPlatformState();
        await _getProduct();
      } catch (e) {
        setState(() {
          _isErrorOccured = true;
        });
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _controllerCenterRight.dispose();
    _controllerCenterLeft.dispose();
    if (_purchaseUpdatedSubscription != null) {
      _purchaseUpdatedSubscription.cancel();
      _purchaseUpdatedSubscription = null;
    }
    if (_purchaseErrorSubscription != null) {
      _purchaseErrorSubscription.cancel();
      _purchaseErrorSubscription = null;
    }
    super.dispose();
  }

  Future<bool> _willPopCallback() async {
    await endConnection();
    return true;
  }

  Future<void> _initPlatformState() async {
    await FlutterInappPurchase.instance.initConnection;

    if (!mounted) return;
    _purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      if (productItem != null) {
        PurchaseState status = productItem.purchaseStateAndroid;
        if (status == PurchaseState.purchased) {
          _controllerCenterRight.play();
          _controllerCenterLeft.play();

          FlutterInappPurchase.instance.finishTransaction(productItem, isConsumable: true);

          Provider.of<UserModel>(context, listen: false).upgradeToPremium(
            purchaseToken: productItem.purchaseToken,
            orderId: productItem.orderId,
          );

          showDialog(
            builder: (context) => SuccessDialog(StringConst.success.tr),
            context: context,
          );
        }
      }
    });

    _purchaseErrorSubscription = FlutterInappPurchase.purchaseError.listen((PurchaseResult purchaseError) {
      if (purchaseError != null) {
        if (purchaseError.code != 'E_USER_CANCELLED') {
          showDialog(
            builder: (context) => ErrorDialog(
              StringConst.anErrorOccuredTryAgainLater.tr,
              height: 160,
            ),
            context: context,
          );
        }
      }
    });
  }

  Future<void> endConnection() async {
    await FlutterInappPurchase.instance.endConnection;
  }

  void _requestPurchase() async {
    FlutterInappPurchase.instance.requestPurchase(
      _items[0].productId,
      obfuscatedAccountIdAndroid: widget.userId,
    );
  }

  List<Widget> _premiumBenefits(UserModel model) {
    return [
      Text(
        StringConst.premiumBenefits.tr,
        style: TextStyle(
          fontSize: 20,
        ),
      ),
      SpaceH12(),
      benefitTile(StringConst.increaseLibraryCapacity.tr),
      benefitTile(StringConst.increaseMaxGenreCapacity.tr),
      benefitTile(StringConst.increaseMaxHighlightCapacity.tr),
      benefitTile(StringConst.increaseMaxCollectionCapacity.tr),
      benefitTile(StringConst.accessToAllUpcomingFeatures.tr),
      benefitTile(StringConst.lifetimeValidity.tr),
      SpaceH12(),
      !model.user.isPremium
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 45),
              child: CustomButton(
                height: 40,
                title: StringConst.purchasePremiumVersion.tr,
                onPressed: () async {
                  _requestPurchase();
                },
              ),
            )
          : Container(),
      SpaceH20(),
    ];
  }

  Widget benefitTile(title) {
    return ListTile(
      leading: const Icon(
        Icons.check,
        color: Colors.green,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: StringConst.trtRegular,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Future _getProduct() async {
    List<IAPItem> items = await FlutterInappPurchase.instance.getProducts(_productLists);
    for (var item in items) {
      this._items.add(item);
    }

    setState(() {
      this._items = items;
    });
  }

  Widget buildBody() {
    Widget screen;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var model = Provider.of<UserModel>(context, listen: true);

    if (_isLoading) {
      screen = Container(
        child: const SpinKitCircle(
          color: AppColors.nord1,
          size: 60,
        ),
      );
    } else if (_isErrorOccured) {
      screen = Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sentiment_dissatisfied_outlined,
                size: 120,
              ),
              SpaceH12(),
              Text(StringConst.onlyAnErrorOccured.tr),
              SpaceH12(),
              CustomButton(
                borderRadius: 30,
                onPressed: () async {
                  await _initPlatformState();
                  await _getProduct();
                },
                height: 35,
                title: StringConst.tryAgain.tr,
                width: width * 0.5,
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      if (model.user.isPremium) {
        screen = Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ConfettiWidget(
                            confettiController: _controllerCenterLeft,
                            blastDirection: 0,
                            particleDrag: 0.05,
                            emissionFrequency: 0.05,
                            numberOfParticles: 20,
                            gravity: 0.05,
                            shouldLoop: false,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ConfettiWidget(
                            confettiController: _controllerCenterRight,
                            blastDirection: pi,
                            particleDrag: 0.05,
                            emissionFrequency: 0.05,
                            numberOfParticles: 20,
                            gravity: 0.05,
                            shouldLoop: false,
                          ),
                        ),
                      ],
                    ),
                    SpaceH30(),
                    SizedBox(
                      height: 35,
                      child: AnimatedTextKit(
                        animatedTexts: [
                          FadeAnimatedText(
                            StringConst.thankYou2.tr,
                            textAlign: TextAlign.center,
                            textStyle: const TextStyle(
                              fontSize: 30.0,
                            ),
                          ),
                          FadeAnimatedText(
                            StringConst.forYourSupport.tr,
                            textAlign: TextAlign.center,
                            textStyle: const TextStyle(
                              fontSize: 30.0,
                            ),
                          ),
                        ],
                        repeatForever: true,
                      ),
                    ),
                    SpaceH20(),
                    Text(
                      StringConst.thanksSupportMessage.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: StringConst.trtRegular,
                      ),
                    ),
                    SpaceH30(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CustomButton(
                        height: 40,
                        title: StringConst.sendFeedback.tr,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        borderRadius: 5,
                        onPressed: () async {
                          final Uri _emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: 'simple.library.app@gmail.com',
                            queryParameters: {
                              'subject': StringConst.customTranslation(
                                key: StringConst.feedbackAboutSimpleLibrary,
                              ),
                            },
                          );
                          await launch(_emailLaunchUri.toString().replaceAll('+', ' '));
                        },
                      ),
                    ),
                    SpaceH50(),
                    ..._premiumBenefits(model),
                  ],
                ),
              ),
            ),
          ),
        );
      } else {
        screen = Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  StringConst.itsMe,
                  width: width,
                  height: height * 0.4,
                ),
                SpaceH12(),
                Text(
                  StringConst.supportTheDevelopment.tr,
                  style: const TextStyle(
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
                SpaceH12(),
                Text(
                  StringConst.iHopeTheAppIsHelpingYou.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: StringConst.trtRegular,
                  ),
                ),
                SpaceH12(),
                Text(
                  StringConst.spIsMyFavProject.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: StringConst.trtRegular,
                  ),
                ),
                SpaceH30(),
                ..._premiumBenefits(model),
              ],
            ),
          ),
        );
      }
    }

    return screen;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: StringConst.upgradeToPremium.tr,
        ),
        body: buildBody(),
      ),
    );
  }
}
