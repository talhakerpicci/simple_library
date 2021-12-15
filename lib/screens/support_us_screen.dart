import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/utils.dart';
import '../widgets/spaces.dart';
import '../values/values.dart';
import '../widgets/custom_app_bar.dart';

import 'address_view_screen.dart';

class SupportUsScreen extends StatefulWidget {
  @override
  _SupportUsScreenState createState() => _SupportUsScreenState();
}

class _SupportUsScreenState extends State<SupportUsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Utils.showCryptoWarning == null) {
        await showWarningDialog(context);
      }
    });
  }

  Widget _coinCard({String imgPath, String coin, Function onTap}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Image.asset(
          imgPath,
          width: 40,
          height: 40,
        ),
        title: Text(coin),
        trailing: const Icon(Icons.arrow_forward_rounded),
      ),
    );
  }

  void showInfoDialog(context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          title: Center(
            child: Text(
              StringConst.whyYouShouldConsiderDonation.tr,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  child: Text(
                    StringConst.simpleLibraryCompletelyFree.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: StringConst.trtRegular,
                    ),
                  ),
                ),
                SpaceH10(),
                Container(
                  child: Text(
                    StringConst.yourContribution.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: StringConst.trtRegular,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                StringConst.close.tr,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14.0,
                ),
              ),
              onPressed: () async {
                if (Utils.showCryptoWarning == null) {
                  var prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('showCryptoWarning', false);
                  Utils.showCryptoWarning = false;
                }
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showWarningDialog(context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          title: Center(
            child: Text(
              StringConst.warning.tr,
              style: const TextStyle(
                fontSize: 28,
                color: Colors.red,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  child: Text(
                    StringConst.forTheTimeBeing.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: StringConst.trtRegular,
                    ),
                  ),
                ),
                SpaceH10(),
                Container(
                  child: Text(
                    StringConst.pleaseNoteThat.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: StringConst.trtRegular,
                    ),
                  ),
                ),
                SpaceH10(),
                Container(
                  child: Text(
                    StringConst.moneyEarnedFrom.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: StringConst.trtRegular,
                    ),
                  ),
                ),
                SpaceH10(),
                Container(
                  child: Text(
                    StringConst.thankYou.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: StringConst.trtRegular,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                StringConst.close.tr,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14.0,
                ),
              ),
              onPressed: () async {
                if (Utils.showCryptoWarning == null) {
                  var prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('showCryptoWarning', false);
                  Utils.showCryptoWarning = false;
                }
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  void setCollectionTipPref() async {}

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(
        title: StringConst.supportUs.tr,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline,
            ),
            onPressed: () {
              showWarningDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.help_outline,
            ),
            onPressed: () {
              showInfoDialog(context);
            },
          ),
        ],
      ),
      body: Container(
        width: width,
        height: height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _coinCard(
                imgPath: StringConst.btcLogo,
                coin: StringConst.btc,
                onTap: () {
                  Get.to(
                    () => AddressViewScreen(
                      imgPath: StringConst.btcAddressQr,
                      address: StringConst.btcAddress,
                      coinName: StringConst.btc,
                    ),
                  );
                },
              ),
              _coinCard(
                imgPath: StringConst.ethLogo,
                coin: StringConst.eth,
                onTap: () {
                  Get.to(
                    () => AddressViewScreen(
                      imgPath: StringConst.ethAddressQr,
                      address: StringConst.ethAddress,
                      coinName: StringConst.eth,
                    ),
                  );
                },
              ),
              _coinCard(
                imgPath: StringConst.ltcLogo,
                coin: StringConst.ltc,
                onTap: () {
                  Get.to(
                    () => AddressViewScreen(
                      imgPath: StringConst.ltcAddressQr,
                      address: StringConst.ltcAddress,
                      coinName: StringConst.ltc,
                    ),
                  );
                },
              ),
              _coinCard(
                imgPath: StringConst.btcCashLogo,
                coin: StringConst.btcCash,
                onTap: () {
                  Get.to(
                    () => AddressViewScreen(
                      imgPath: StringConst.btcCashAddressQr,
                      address: StringConst.btcCashAddress,
                      coinName: StringConst.btcCash,
                    ),
                  );
                },
              ),
              _coinCard(
                imgPath: StringConst.xmrLogo,
                coin: StringConst.xmr,
                onTap: () {
                  Get.to(
                    () => AddressViewScreen(
                      imgPath: StringConst.xmrAddressQr,
                      address: StringConst.xmrAddress,
                      coinName: StringConst.xmr,
                    ),
                  );
                },
              ),
              _coinCard(
                imgPath: StringConst.usdtLogo,
                coin: StringConst.usdt,
                onTap: () {
                  Get.to(
                    () => AddressViewScreen(
                      imgPath: StringConst.usdtAddressQr,
                      address: StringConst.usdtAddress,
                      coinName: StringConst.usdt,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
