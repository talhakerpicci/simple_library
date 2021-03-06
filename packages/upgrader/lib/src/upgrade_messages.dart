/*
 * Copyright (c) 2020 Larry Aasen. All rights reserved.
 */

import 'package:flutter/material.dart';

/// The message identifiers used in upgrader.
enum UpgraderMessage {
  /// Body of the upgrade message
  body,

  /// Ignore button
  buttonTitleIgnore,

  /// Later button
  buttonTitleLater,

  /// Update Now button
  buttonTitleUpdate,

  /// Prompt message
  prompt,

  /// Title
  title,
}

/// The default localized messages used for display in upgrader. Extend this
/// class to provide custom values and new localizations for languages.
/// An example to replace the Ignore button with a custom value would be:
///
/// ```dart
/// class MyUpgraderMessages extends UpgraderMessages {
///   @override
///   String get buttonTitleIgnore => 'My Ignore';
/// }
///
/// UpgradeAlert(messages: MyUpgraderMessages());
/// ```
///
class UpgraderMessages {
  /// The primary language subtag for the locale, which defaults to the
  /// system-reported default locale of the device.
  final String languageCode;

  /// Provide a [code] to override the system-reported default locale.
  UpgraderMessages({String? code})
      : languageCode = (code ?? findLanguageCode()) {
    assert(languageCode.isNotEmpty);
  }

  /// Override the message function to provide custom language localization.
  String? message(UpgraderMessage messageKey) {
    switch (messageKey) {
      case UpgraderMessage.body:
        return body;
      case UpgraderMessage.buttonTitleIgnore:
        return buttonTitleIgnore;
      case UpgraderMessage.buttonTitleLater:
        return buttonTitleLater;
      case UpgraderMessage.buttonTitleUpdate:
        return buttonTitleUpdate;
      case UpgraderMessage.prompt:
        return prompt;
      case UpgraderMessage.title:
        return title;
      default:
    }
    return null;
  }

  /// Determine the current language code, either from the context, or
  /// from the system-reported default locale of the device.
  static String findLanguageCode({BuildContext? context}) {
    Locale? locale;
    if (context != null) {
      locale = Localizations.maybeLocaleOf(context);
    } else {
      // Get the system locale
      locale = WidgetsBinding.instance!.window.locale;
    }
    final code = locale == null || locale.languageCode.isEmpty
        ? 'en'
        : locale.languageCode;
    return code;
  }

  /// The body of the upgrade message. This string supports mustache style
  /// template variables:
  ///   {{appName}}
  ///   {{currentAppStoreVersion}}
  ///   {{currentInstalledVersion}}
  /// Example:
  ///  'A new version of Upgrader is available! Version 1.2 is now available-you have 1.0.';

  /// Override this getter to provide a custom value. Values provided in the
  /// [message] function will be used over this value.
  String get body {
    String message;
    switch (languageCode) {
      case 'ar':
        message =
            '???????? ?????????? ???? {{appName}} ????????????! ???????????? {{currentAppStoreVersion}} ???????????? ????????, ?????? ???????????? ???????????? {{currentInstalledVersion}}.';
        break;
      case 'es':
        message =
            '??Una nueva versi??n de {{appName}} est?? disponible! La versi??n {{currentAppStoreVersion}} ya est?? disponible-usted tiene {{currentInstalledVersion}}.';
        break;
      case 'fa':
        message =
            '????????????? ?????????? ???? {{appname}} ?????????? ??????! ????????????? {{currentAppStoreVersion}} ???? ?????????? ?????? ?????? ?????? ???????????? ???? ????????????? {{currentInstalledVersion}} ?????????????? ???????????????.';
        break;
      case 'fil':
        message =
            'May bagong bersyon ang {{appName}} na pwede nang magamit! Ang bersyong {{currentAppStoreVersion}} ay pwede nang magamit. Ikaw ay kasalukuyang gumagamit ng bersyong {{currentInstalledVersion}}.';
        break;
      case 'fr':
        message =
            'Une nouvelle version de {{appName}} est disponible ! La version {{currentAppStoreVersion}} est maintenant disponible, vous avez la version {{currentInstalledVersion}}.';
        break;
      case 'de':
        message =
            'Eine neue Version von {{appName}} ist verf??gbar! Die Version {{currentAppStoreVersion}} ist verf??gbar, installiert ist die Version {{currentInstalledVersion}}.';
        break;
      case 'hu':
        message =
            '??j verzi?? ??rhet?? el az alkalmaz??sb??l {{appName}} ! Az el??rhet?? ??j verzi??: {{currentAppStoreVersion}} - a jelenlegi verzi??: {{currentInstalledVersion}}.';
        break;
      case 'id':
        message =
            'Versi terbaru dari {{appName}} tersedia! Versi terbaru saat ini adalah {{currentAppStoreVersion}} - versi anda saat ini adalah {{currentInstalledVersion}}.';
        break;
      case 'it':
        message =
            'Una nuova versione di {{appName}} ?? disponibile! La versione {{currentAppStoreVersion}} ?? ora disponibile, voi avete {{currentInstalledVersion}}.';
        break;
      case 'ko':
        message =
            '{{appName}}??? ??? ???????????? ???????????????????????????! ?????? ?????? {{currentAppStoreVersion}}?????? ??????????????? ??????????????? - ?????? ?????? {{currentInstalledVersion}}.';
        break;
      case 'pt':
        message =
            'H?? uma nova vers??o do {{appName}} dispon??vel! A vers??o {{currentAppStoreVersion}} j?? est?? dispon??vel, voc?? tem a {{currentInstalledVersion}}.';
        break;
      case 'pl':
        message =
            'Nowa wersja {{appName}} jest dost??pna! Wersja {{currentAppStoreVersion}} jest dost??pna, Ty masz {{currentInstalledVersion}}.';
        break;
      case 'ru':
        message =
            '???????????????? ?????????? ???????????? ???????????????????? {{appName}}! ?????????? ????????????: {{currentAppStoreVersion}}, ?????????????? ????????????: {{currentInstalledVersion}}.';
        break;
      case 'tr':
        message =
            '{{appName}} uygulaman??z??n yeni bir versiyonu mevcut! Versiyon {{currentAppStoreVersion}} ??u anda eri??ilebilir, mevcut s??r??m??n??z {{currentInstalledVersion}}.';
        break;
      case 'vi':
        message =
            '???? c?? phi??n b???n m???i c???a {{appName}}. Phi??n b???n {{currentAppStoreVersion}} ???? s???n s??ng, b???n ??ang d??ng {{currentInstalledVersion}}.';
        break;
      case 'en':
      default:
        message =
            'A new version of {{appName}} is available! Version {{currentAppStoreVersion}} is now available-you have {{currentInstalledVersion}}.';
        break;
    }
    return message;
  }

  /// The ignore button title.
  /// Override this getter to provide a custom value. Values provided in the
  /// [message] function will be used over this value.
  String get buttonTitleIgnore {
    String message;
    switch (languageCode) {
      case 'ar':
        message = '??????????';
        break;
      case 'es':
        message = 'IGNORAR';
        break;
      case 'fa':
        message = '????????????';
        break;
      case 'fil':
        message = 'HUWAG PANSININ';
        break;
      case 'fr':
        message = 'IGNORER';
        break;
      case 'de':
        message = 'IGNORIEREN';
        break;
      case 'hu':
        message = 'KIHAGYOM';
        break;
      case 'id':
        message = 'ABAIKAN';
        break;
      case 'it':
        message = 'IGNORA';
        break;
      case 'ko':
        message = '??????';
        break;
      case 'pt':
        message = 'IGNORAR';
        break;
      case 'pl':
        message = 'IGNORUJ';
        break;
      case 'ru':
        message = '??????';
        break;
      case 'tr':
        message = 'YOKSAY';
        break;
      case 'vi':
        message = 'B??? QUA';
        break;
      case 'en':
      default:
        message = 'IGNORE';
        break;
    }
    return message;
  }

  /// The later button title.
  /// Override this getter to provide a custom value. Values provided in the
  /// [message] function will be used over this value.
  String get buttonTitleLater {
    String message;
    switch (languageCode) {
      case 'ar':
        message = '????????????';
        break;
      case 'es':
        message = 'M??S TARDE';
        break;
      case 'fa':
        message = '????????';
        break;
      case 'fil':
        message = 'MAMAYA';
        break;
      case 'fr':
        message = 'PLUS TARD';
        break;
      case 'de':
        message = 'SP??TER';
        break;
      case 'hu':
        message = 'K??S??BB';
        break;
      case 'id':
        message = 'NANTI';
        break;
      case 'it':
        message = 'DOPO';
        break;
      case 'ko':
        message = '?????????';
        break;
      case 'pt':
        message = 'MAIS TARDE';
        break;
      case 'pl':
        message = 'P????NIEJ';
        break;
      case 'ru':
        message = '??????????';
        break;
      case 'tr':
        message = 'SONRA';
        break;
      case 'vi':
        message = '????? SAU';
        break;
      case 'en':
      default:
        message = 'LATER';
        break;
    }
    return message;
  }

  /// The update button title.
  /// Override this getter to provide a custom value. Values provided in the
  /// [message] function will be used over this value.
  String get buttonTitleUpdate {
    String message;
    switch (languageCode) {
      case 'ar':
        message = '?????? ????????';
        break;
      case 'es':
        message = 'ACTUALIZAR';
        break;
      case 'fa':
        message = '??????????????????';
        break;
      case 'fil':
        message = 'I-UPDATE NA NGAYON';
        break;
      case 'fr':
        message = 'MAINTENANT';
        break;
      case 'de':
        message = 'AKTUALISIEREN';
        break;
      case 'hu':
        message = 'FRISS??TSE MOST';
        break;
      case 'id':
        message = 'PERBARUI SEKARANG';
        break;
      case 'it':
        message = 'AGGIORNA ORA';
        break;
      case 'ko':
        message = '?????? ????????????';
        break;
      case 'pt':
        message = 'ATUALIZAR';
        break;
      case 'pl':
        message = 'AKTUALIZUJ';
        break;
      case 'ru':
        message = '????????????????';
        break;
      case 'tr':
        message = '????MD?? G??NCELLE';
        break;
      case 'vi':
        message = 'C???P NH???T';
        break;
      case 'en':
      default:
        message = 'UPDATE NOW';
        break;
    }
    return message;
  }

  /// The call to action prompt message.
  /// Override this getter to provide a custom value. Values provided in the
  /// [message] function will be used over this value.
  String get prompt {
    String message;
    switch (languageCode) {
      case 'ar':
        message = '???? ???????? ???? ?????? ?????????????? ????????';
        break;
      case 'es':
        message = '??Le gustar??a actualizar ahora?';
        break;
      case 'fa':
        message = '?????? ?????????????????? ?????????????????';
        break;
      case 'fil':
        message = 'Gusto mo bang i-update ito ngayon?';
        break;
      case 'fr':
        message = 'Voulez-vous mettre ?? jour maintenant?';
        break;
      case 'de':
        message = 'M??chtest du jetzt aktualisieren?';
        break;
      case 'hu':
        message = 'Akarja most friss??teni?';
        break;
      case 'id':
        message = 'Apakah Anda ingin memperbaruinya sekarang?';
        break;
      case 'it':
        message = 'Ti piacerebbe aggiornare ora?';
        break;
      case 'ko':
        message = '?????? ??????????????? ?????????????????????????';
        break;
      case 'pt':
        message = 'Voc?? quer atualizar agora?';
        break;
      case 'pl':
        message = 'Czy chcia??by?? zaktualizowa?? teraz?';
        break;
      case 'ru':
        message = '???????????? ???????????????? ?????????????';
        break;
      case 'tr':
        message = '??imdi g??ncellemek ister misiniz?';
        break;
      case 'vi':
        message = 'B???n c?? mu???n c???p nh???t ???ng d???ng?';
        break;
      case 'en':
      default:
        message = 'Would you like to update it now?';
        break;
    }
    return message;
  }

  /// The alert dialog title.
  /// Override this getter to provide a custom value. Values provided in the
  /// [message] function will be used over this value.
  String get title {
    String message;
    switch (languageCode) {
      case 'ar':
        message = '???? ???????? ?????????? ????????????????';
        break;
      case 'es':
        message = '??Actualizar la aplicaci??n?';
        break;
      case 'fa':
        message = '????????????? ????????';
        break;
      case 'fil':
        message = 'I-update ang app?';
        break;
      case 'fr':
        message = 'Mettre ?? jour l\'application?';
        break;
      case 'de':
        message = 'App aktualisieren?';
        break;
      case 'hu':
        message = 'Friss??t??s?';
        break;
      case 'id':
        message = 'Perbarui Aplikasi?';
        break;
      case 'it':
        message = 'Aggiornare l\'applicazione?';
        break;
      case 'ko':
        message = '?????? ???????????????????????????????';
        break;
      case 'pt':
        message = 'Atualizar aplica????o?';
        break;
      case 'pl':
        message = 'Czy zaktualizowa?? aplikacj???';
        break;
      case 'ru':
        message = '?????????????????';
        break;
      case 'tr':
        message = 'Uygulamay?? G??ncelle?';
        break;
      case 'vi':
        message = 'C???p nh???t ???ng d???ng?';
        break;
      case 'en':
      default:
        message = 'Update App?';
        break;
    }
    return message;
  }
}
