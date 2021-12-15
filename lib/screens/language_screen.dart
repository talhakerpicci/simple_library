import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../utils/utils.dart';
import '../values/values.dart';
import '../widgets/custom_app_bar.dart';

class LanguagesScreen extends StatefulWidget {
  @override
  _LanguagesScreenState createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  int languageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Utils.selectedLocale != null && Utils.selectedLocale != '') {
        setState(() {
          languageIndex = availableLanuages[Utils.selectedLocale];
        });
      } else {
        if (availableLanuages[Utils.defaultLocale] == null) {
          languageIndex = 0;
        } else {
          setState(() {
            languageIndex = availableLanuages[Utils.defaultLocale];
          });
        }
      }
    });
  }

  final Map availableLanuages = {
    StringConst.en_US: 0,
    StringConst.tr_TR: 1,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: StringConst.appLanguage.tr,
      ),
      body: SettingsList(
        backgroundColor: Colors.white,
        sections: [
          SettingsSection(tiles: [
            SettingsTile(
              title: StringConst.english.tr,
              trailing: trailingWidget(0),
              onPressed: (_) async {
                await changeLanguage(StringConst.en_US);
              },
            ),
            SettingsTile(
              title: StringConst.turkish.tr,
              trailing: trailingWidget(1),
              onPressed: (_) async {
                await changeLanguage(StringConst.tr_TR);
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget trailingWidget(int index) {
    return (languageIndex == index) ? const Icon(Icons.check, color: AppColors.nord1) : const Icon(null);
  }

  Future changeLanguage(String locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var jsonData = json.decode(prefs.getString('localeData'));

    if (locale == jsonData['selectedLocale']) {
      return;
    }

    jsonData['selectedLocale'] = locale;
    Utils.selectedLocale = locale;

    await prefs.setString(
      'localeData',
      jsonEncode(
        {
          'defaultLocale': jsonData['defaultLocale'],
          'languageCode': locale.split('_')[0],
          'countryCode': locale.split('_')[1],
          'selectedLocale': locale,
        },
      ),
    );
    setState(() {
      languageIndex = availableLanuages[locale];
    });

    Utils.showFlushInfo(context, StringConst.pleaseRestartTheApp.tr);
  }
}
