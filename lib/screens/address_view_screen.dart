import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../dialogs/custom_yes_no_dialog.dart';
import '../widgets/spaces.dart';
import '../utils/utils.dart';
import '../values/values.dart';
import '../widgets/custom_app_bar.dart';

class AddressViewScreen extends StatelessWidget {
  final String address;
  final String imgPath;
  final String coinName;
  final String description;

  AddressViewScreen({
    this.address,
    this.imgPath,
    this.coinName,
    this.description,
  });

  Color getTextColor() {
    Color color;
    switch (coinName) {
      case StringConst.btc:
        color = Colors.yellow[800];
        break;
      case StringConst.eth:
        color = Colors.blueAccent[700];
        break;
      case StringConst.ltc:
        color = Colors.indigo[900];
        break;
      case StringConst.btcCash:
        color = Colors.green[600];
        break;
      case StringConst.xmr:
        color = Colors.orange[900];
        break;
      case StringConst.usdt:
        color = Color(0xff4ba28a);
        break;
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar(
        title: StringConst.customTranslation(
          key: StringConst.sendCoin,
          data: coinName,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              var result = await showDialog(
                builder: (context) => CustomYesNoDialog(
                  buttonTitleLeft: StringConst.yes.tr,
                  buttonTitleRight: StringConst.no.tr,
                  message: StringConst.saveQrToGallery.tr,
                ),
                context: context,
              );

              if (result != null && result) {
                await Utils.saveFileToGalery(
                  path: imgPath,
                  coinName: coinName,
                );

                Utils.showCustomInfoToast(context, StringConst.savedQrToGallery.tr);
              }
            },
          ),
        ],
      ),
      body: Container(
        width: width,
        height: height,
        child: Card(
          margin: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                child: Image.asset(imgPath),
              ),
              SpaceH20(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Text(
                  address,
                  style: const TextStyle(
                    fontFamily: StringConst.trtRegular,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              description != null
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 5,
                      ),
                      child: Text(
                        '${StringConst.note.tr}: $description',
                        style: const TextStyle(
                          fontFamily: StringConst.trtRegular,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Container(),
              SpaceH20(),
              Container(
                child: TextButton(
                  child: Text(
                    StringConst.copyAddressToClipboard.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: getTextColor(),
                    ),
                  ),
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(
                        text: address,
                      ),
                    );
                    Utils.showCustomInfoToast(context, StringConst.addressCopied.tr);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
