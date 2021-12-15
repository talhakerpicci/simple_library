import 'package:get/get.dart';

import '../values/values.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        StringConst.tr_TR: {
          // All Places and Dialogs
          StringConst.comingSoon: 'Çok Yakında!',
          StringConst.faqs: 'S.S.S',
          StringConst.upgradeToPremium: 'Premiuma Yükselt',
          StringConst.theEnteredEmailAlreadyInUse: 'Girilen e-posta zaten kullanılıyor',
          StringConst.passwordMustBeAtLeastSixCharacters: 'Şifre en az 6 karakterden oluşmalıdır ',
          StringConst.failedToRegister: 'Kayıt başarısız',
          StringConst.thisFieldIsRequired: 'Bu alan zorunludur ',
          StringConst.nameSurnameLengthMustBeLowerThan: "Ad soyad uzunluğu 200'den az olmalıdır",
          StringConst.enterValidEmailAddress: 'Geçerli bir e-posta adresi girin',
          StringConst.passwordsDoesNotMatch: 'Şifreler eşleşmiyor ',
          StringConst.successfulyUpdated: 'Başarıyla güncellendi',
          StringConst.anErrorOccured: 'Bir hata oluştu. Lütfen tekrar deneyin',
          StringConst.invalidEmail: 'Geçersiz e-posta',
          StringConst.noUserFound: 'Girilen e-postaya sahip kullanıcı bulunamadı',
          StringConst.wrongPassword: 'Hatalı şifre',
          StringConst.accountDisabled: 'Bu hesap devre dışı bırakıldı. Lütfen bizimle iletişime geçin',
          StringConst.failedToLogin: 'Giriş yapılamadı',
          StringConst.accessBlocked: 'Erişim engellendi',
          StringConst.makeSureYouAreOnline: 'Lütfen çevrimiçi olduğunuzdan emin olun ve tekrar deneyin',
          StringConst.pleaseWait: 'Lütfen bekleyin...',
          StringConst.selectABookCover: 'Bir kitap kapağı seçin',
          StringConst.selectACoverToApply: 'Lütfen uygulamak için bir kapak seçin',
          StringConst.chooseAnother: 'Başka Birini Seç ',
          StringConst.applyCover: 'Kapak Resmini Uygula',
          StringConst.onlineSearchLanguage: 'Çevrimiçi arama dili',
          StringConst.save: 'Kaydet',
          StringConst.confirmPassword: 'Şifreyi Onayla',
          StringConst.enterPassword: 'Şifreni Gir',
          StringConst.proceed: 'Devam Et',
          StringConst.yes: 'Evet',
          StringConst.no: 'Hayır',
          StringConst.onlyAnErrorOccured: 'Bir hata oluştu ',
          StringConst.anErrorOccuredTryAgainLater: 'Bir hata oluştu.\nLütfen daha sonra tekrar deneyiniz.',
          StringConst.someChangesHaveBeenMade: 'Bazı değişiklikler yapıldı. Değişiklikleri iptal etmek istediğinizden emin misiniz?',
          StringConst.yourAccHasBeenUpgraded: 'Hesabınız yükseltildi. Artık premium sürümün tüm avantajlarına sahipsiniz.\nTadını çıkar!',

          // Validators
          StringConst.enterAValue: 'Bir değer girin',

          // Address View Screen
          StringConst.note: 'Not',
          StringConst.copyAddressToClipboard: 'Adresi Panoya Kopyala',
          StringConst.addressCopied: 'Adres kopyalandı',
          StringConst.saveQrToGallery: 'QR kod galeriye kaydedilsin mi?',
          StringConst.savedQrToGallery: 'QR kod kaydedildi',

          // Intro Screen
          StringConst.welcomeToSimpleLibrary: "Simple Library'ye Hoş Geldiniz",
          StringConst.welcomeDescription: 'Simple Library, ek özelliklerle kitaplarınızı takip etmenize yardımcı olan kişisel bir dijital kitaplık uygulamasıdır.',
          StringConst.allBooksInOnePlace: 'Tüm Kitaplarınız Tek Bir Yerde',
          StringConst.allBooksInOnePlaceDescription: 'Simple Library, tüm kitaplarınızı bir sunucuda depolar, hiçbir şey yerel olarak depolanmaz! Bu nedenle kitaplarınıza erişimi kaybetme konusunda endişelenmenize gerek yok.',
          StringConst.setGoals: 'Hedef Belirleyin',
          StringConst.setGoalsDescription: 'Simple Library, günlük, aylık, yıllık hedefler oluşturmanıza ve günlük bir okuma alışkanlığı geliştirmenize ve devam etmenize yardımcı olur.',
          StringConst.viewYourStats: 'İstatistiklerinizi Görüntüleyin ',
          StringConst.viewYourStatsDescription: 'Simple Library, kitaplarınız ve okuma alışkanlıklarınız hakkında istatistikler sağlar.',
          StringConst.muchMoreToDiscover: 'Ve Keşfedilecek Çok Daha Fazlası!',
          StringConst.muchMoreToDiscoverDescription: 'Bugün kaydolarak başlayın ve tüm özellikleri keşfedin!',
          StringConst.getStarted: 'Hemen Şimdi Başlayın ',
          StringConst.skip: 'Atla',
          StringConst.next: 'Sonraki',

          // Welcome Screen
          StringConst.login: 'Giriş',
          StringConst.register: 'Kayıt Ol',
          StringConst.changePassword: 'Şifre Değiştir',
          StringConst.profilePicture: 'Profil Fotoğrafı',

          // User Profile Screen
          StringConst.deleteProfilePhoto: 'Fotoğrafı\nSil',
          StringConst.errorOccuredWhileDeleting: 'Avatar silinirken bir hata oluştu ',
          StringConst.profilePhotoDeleteSuccess: 'Avatar başarıyla silindi ',
          StringConst.takeProfilePhoto: 'Fotoğraf Çek',
          StringConst.toUseCameraGivePermission: 'Kamerayı kullanmak için lütfen erişim verin',
          StringConst.errorOccuredWhileUpdating: 'Avatar güncellenirken bir hata oluştu',
          StringConst.profilePhotoUpdateSuccess: 'Avatar başarıyla güncellendi',
          StringConst.fileSizeMustBeLowerThanEight: "Dosya boyutu 8 mb'den küçük olmalıdır",
          StringConst.takePhotoFromGallery: 'Galeriden\nSeç',
          StringConst.toSelectImageGivePermission: 'Galeriden bir resim seçmek için lütfen erişim verin.',
          StringConst.profilePhoto: 'Profil Fotoğrafı',

          // Stats Screen
          StringConst.statsAppBarTitle: 'Okuma İstatistikleri',
          StringConst.totalBooks: 'Toplam Kitap',
          StringConst.reading: 'Okuyorum',
          StringConst.toRead: 'Okunacak',
          StringConst.finished: 'Okudum',
          StringConst.dropped: 'Bıraktım',
          StringConst.pagesReading: 'Okunan Sayfalar',
          StringConst.totalPagesN: 'Toplam Sayfa\n',
          StringConst.totalPages: 'Toplam Sayfa',
          StringConst.totalTimeAprox: 'Toplam Süre\nyakl.',
          StringConst.pagesDailyAvg: 'Sayfa Günlük Ort\n(Son 30 Gün)',
          StringConst.days: 'gün',
          StringConst.currentReadingStreak: 'Mevcut okuma serisi',
          StringConst.maxStreak: 'Maksimum Seri',
          StringConst.pages: 'Sayfa Sayısı Girin',
          StringConst.pagesS: 'sayfa',
          StringConst.maxPagesReadInOneDay: 'Maksimum Okunan Sayfa (bir günde)',
          StringConst.minutes: 'dakika',
          StringConst.maxMinutesReadInOneDay: 'Maksimum Okuma Süresi (bir günde)',
          StringConst.viewYourGraphs: 'Grafiklerinizi görüntüleyin',
          StringConst.tapHereToViewYourGraphs: 'Grafiklerinizi görüntülemek için buraya dokunun',

          // Register Screen
          StringConst.alreadyHaveAnAccount: 'Zaten hesabınız var mı ?',
          StringConst.nameSurname: 'Ad Soyad',
          StringConst.email: 'E-posta',
          StringConst.password: 'Şifre',
          StringConst.passwordAgain: 'Şifre Tekrar',

          // Settings Screen
          StringConst.settingsAppBarTitle: 'Ayarlar',
          StringConst.account: 'Hesap',
          StringConst.common: 'Genel',
          StringConst.language: 'Dil',
          StringConst.readingSpeed: 'Okuma Hızı',
          StringConst.yourReadingSpeed: 'Okuma Hızınız',
          StringConst.pageS: 'Sayfa',
          StringConst.minuteS: 'Dakika',
          StringConst.cancel: 'İptal',
          StringConst.done: 'Tamam',
          StringConst.other: 'Diğer',
          StringConst.about: 'Hakkında',
          StringConst.developedBy: 'Talha Kerpiççi tarafından geliştirildi',
          StringConst.visitMyWebsite: 'Web Sitemi Ziyaret Edin',
          StringConst.shareApp: 'Uygulamayı Paylaş',
          StringConst.rateUs: 'Uygulamayı Değerlendirin',
          StringConst.supportUs: 'Bizi Destekle',
          StringConst.feedback: 'Geribildirim / Öneriler',
          StringConst.version: 'Versiyon',
          StringConst.close: 'Kapat',
          StringConst.minute: 'dk',
          StringConst.hour: 's',
          StringConst.releaseNotes: 'İlk sürüm!\n\nUygulamayı indirdiğiniz için teşekkürler!',
          StringConst.unlockAllTheFeatures: 'Okuma deneyiminizi geliştirmek için tüm özelliklerin kilidini açın.',
          StringConst.defaultView: 'Varsayılan Görünüm',
          StringConst.gridView: 'Izgara Görünümü',
          StringConst.listView: 'Liste Görünümü',
          StringConst.genres: 'Türler',

          // Genres Screen
          StringConst.longPressToEdit: 'Güncellemek veya silmek için bir türe uzun basın',

          // Support Us Screen
          StringConst.forTheTimeBeing: 'Şimdilik sadece kripto para birimlerini kabul ediyoruz. Gelecekte daha fazla bağış yöntemi eklenecek.',
          StringConst.pleaseNoteThat: 'Bağış yaparak herhangi bir uygulama içi avantaj elde etmeyeceğinizi veya kazanmayacağınızı lütfen unutmayın. Bağışlar yalnızca bu uygulamayı desteklemek ve bu uygulamayı çalışır durumda tutmamıza yardımcı olmak içindir.',
          StringConst.moneyEarnedFrom: 'Bağışlardan kazanılan para, uygulamayı ve sunucuları geliştirmek için kullanılacaktır.',
          StringConst.thankYou: 'Teşekkürler!',
          StringConst.whyYouShouldConsiderDonation: 'Neden Bağış\nYapmayı Düşünmelisiniz',
          StringConst.simpleLibraryCompletelyFree: 'Simple Library tamamen ücretsiz bir uygulamadır, ayrıca herhangi bir reklam içermez. Bu şekilde kalması için yardımına ihtiyacım var! 5 tl gibi küçük bir hediye bile çok yardımcı olacaktır.',
          StringConst.yourContribution: "Katkınız ayrıca Simple Library'ye yeni özellikler getirmem için bana yardımcı olacak ve motive edecek.",
          StringConst.minDepositAmount: 'Minimum para yatırma tutarı: 0.001 LTC',

          // Select Books Screen
          StringConst.couldNotFindBook: 'Kitap Bulunamadı',
          StringConst.bookSSelected: 'kitap seçildi',
          StringConst.searchWithDots: 'Ara...',
          StringConst.showSelectedOnly: 'Yalnızca seçili olanları göster',

          // Select Book Screen
          StringConst.couldNotFindAnyBook: 'Kitap bulunamadı',
          StringConst.couldNotFindAnyBookTryAddingSome: 'Kitap bulunamadı.\nBirkaç tane eklemeyi deneyin!',
          StringConst.selectABook: 'Bir kitap seçin',
          StringConst.bookSFound: 'kitap bulundu',

          // Login Screen
          StringConst.emailAddress: 'E-posta Adresi',
          StringConst.aPasswordResetEmailWillBeSent: 'Girilen e-posta adresine bir şifre sıfırlama e-postası gönderilecektir',
          StringConst.anErrorOccuredMakeSureToTypeEmailCorrectly: 'Bir hata oluştu. E-postanızı doğru yazdığınızdan emin olun ve tekrar deneyin',
          StringConst.aPasswordResetEmailHasBeenSent: 'Parola sıfırlama e-postası gönderildi. Lütfen gelen kutunuzu kontrol edin',
          StringConst.sendEmail: 'Eposta gönder',
          StringConst.forgotPassword: 'Parolanızı mı unuttunuz ?',
          StringConst.dontHaveAnAccount: 'Hesabınız yok mu ?',

          // Langeage Screen
          StringConst.appLanguage: 'Uygulama Dili',
          StringConst.english: 'İngilizce',
          StringConst.turkish: 'Türkçe',
          StringConst.pleaseRestartTheApp: 'Uygulanan değişikliklerin geçerli olması için lütfen uygulamayı yeniden başlatın',

          // Info Screen
          StringConst.whatsIsSimpleLibrary: 'Simple Library nedir?',
          StringConst.answer1: 'Simple Library, birçok ek özelliği ile birlikte, kitaplarınızın takibini kolaylaştırmayı hedefleyen, kişisel bir dijital kitaplık uygulamasıdır.',
          StringConst.iosVersion: 'Uygulamanın IOS sürümü olacak mı?',
          StringConst.answer2: 'Gelecekte uygulamanın IOS sürümünü yayınlamayı planlıyoruz.',
          StringConst.whyDoIHaveToRegister: 'Neden kayıt oluşturma şartı var?',
          StringConst.answer3: 'Simple Library, kitap kapak resimleri dahil tüm kitaplarınızı ve hedefleriniz, vurgulamalarınız, koleksiyonlarınız gibi diğer tüm verileri bir sunucuda depolar. Bu nedenle, uygulamayı kullanmak için bir hesap oluşturmanız gerekir.',
          StringConst.isTheAppFree: 'Uygulama ücretsiz mi?',
          StringConst.answer4: 'Simple Library tamamen ücretsizdir, ayrıca içinde herhangi bir reklam yoktur ve bu şekilde kalmasını hedefliyorum. Ancak limitlerinizi artırabileceğiniz ve tüm özelliklere erişebileceğiniz bir premium planımız var.',
          StringConst.iCantReadBooksIAdded: 'Kitaplığıma eklediğim kitapları okuyamıyorum?',
          StringConst.answer5: 'Simple Library, kitap okumak için bir uygulama değildir. Uygulamanın kullanım amacı, kitaplarınızı takip etmek için organize kişisel bir kütüphaneye sahip olmaktır.',
          StringConst.isThereALimit: 'Sahip olabileceğim kitap sayısı sınırı var mı?',
          StringConst.answer6: "Ücretsiz sürümde sahip olabileceğiniz maksimum kitap sayısı 50'dir. Premium'a yükseltirseniz, bu sınır 500'e çıkar. Bu limitleri yükseltmek için çalışıyoruz. Daha fazla bilgi için premium avantajları sayfasına göz atın.",
          StringConst.whyThereIsALimit: 'Neden belirli şeylerde bir sınır var?',
          StringConst.answer7: "Uygulama ücretsiz olsa ve içinde hiç reklam olmasa da, bu uygulamayı çalışır durumda tutabilmek için sunucuların maliyetini ödememiz gerekiyor. Bu nedenle, normal kullanıcılar için maksimum kitap sayısı, önemli noktalar, koleksiyonlar vb. için bazı sınırlamalar mevcut. Bu sınırları artırmak ve Simple Library'nin sunduğu her şeye erişmek için hesabınızı premium'a yükseltmeyi düşünebilirsiniz. Ayrıca, bu uygulamayı çalışır durumda tutmamıza yardımcı olmak için bağış yapmayı da düşünebilirsiniz.",
          StringConst.howCanIMakeADonation: 'Nasıl bağış yapabilirim?',
          StringConst.answer8: 'Şimdilik sadece kripto para birimlerini kabul ediyoruz. İlgili adreslerimizi bize destek sayfasında bulabilirsiniz.',
          StringConst.watchDemoVideo: 'Demo Videoyu İzle',

          // Image Edit Screen
          StringConst.couldNotLoadPicture: 'Resim yüklenemedi',
          StringConst.editPicture: 'Resmi Düzenle',

          // Reading Reminders
          StringConst.yourRemindersWillAppearHere: 'Okuma hatırlatıcılarınız burada görünecek',

          // Home Screen Base
          StringConst.addNewBook: 'Yeni Kitap Ekle',
          StringConst.all: 'Hepsi',
          StringConst.reachedMaxBookCapacity: 'Maksimum kitap kapasitesine ulaşıldı',
          StringConst.search: 'Kitaplarını Ara',
          StringConst.searchBookOnline: 'Çevrimiçi Kitap Ara',
          StringConst.tapHereToAddBook: 'Kitaplığınıza yeni kitaplar eklemek için buraya dokunun.',

          // Highlights Screen
          StringConst.yourHiglihtsWillBeListedHere: 'Önemli noktalarınız burada listelenecek',
          StringConst.bookHighlights: 'önemli nokta',
          StringConst.addNewHighlight: 'Yeni Önemli Nokta Ekle',
          StringConst.somethingWentWrong: 'Bir şeyler yanlış gitti',
          StringConst.highlightUpdateSuccess: 'Önemli nokta başarıyla güncellendi',
          StringConst.highlightDeleteSuccess: 'Önemli nokta başarıyla silindi',
          StringConst.highlightInsertSuccess: 'Önemli nokta başarıyla eklendi',
          StringConst.searchHighlight: 'Önemli nokta ara',

          // Book Grid Screen
          StringConst.yourBooksWillBeListedHere: 'Kitaplarınız burada listelenecek.\nBirkaç tane eklemeyi deneyin!',
          StringConst.booksYouReadWillBeListedHere: 'Okuduğunuz kitaplar burada listelenecek',
          StringConst.booksYouFinishedWillBeListedHere: 'Bitirdiğiniz kitaplar burada listelenecek',
          StringConst.booksYouPlanToReadWillBeListedHere: 'Okumayı planladığınız kitaplar burada listelenecek',
          StringConst.booksYouDroppedWillBeListedHere: 'Yarım bıraktığınız kitaplar burada listelenecek',

          // Goals Screen
          StringConst.goalsCapital: 'HEDEFLER',
          StringConst.goal: 'Hedef',
          StringConst.dailyReadingGoal: 'Günlük Okuma Hedefi',
          // ignore: equal_keys_in_map
          StringConst.numberGoal: 'Hedefi',
          StringConst.numberBooks: 'Kitap',
          StringConst.numberOfBooks: 'Kitap Sayısını Girin',
          StringConst.anErrorOccuredOnlyEnterNumbers: 'Bir hata oluştu. Lütfen sadece rakam girin',
          StringConst.edit: 'Düzenle',
          StringConst.view: 'Görüntüle',
          StringConst.sGoal: ' Hedefi',
          StringConst.readingGoals: 'Okuma Hedefleri',

          // Goal View Screen
          StringConst.pickDate: 'Tarih Seçin',
          StringConst.ok: 'Tamam',
          StringConst.okay: 'Tamam',

          // Reminders Screen
          StringConst.updateReminder: 'Hatırlatıcıyı Güncelle',
          StringConst.newReminder: 'Yeni Hatırlatıcıyı',
          StringConst.customNotifMessage: 'Özel Bildirim Mesajı (Opsiyonel)',
          StringConst.reminderTime: 'Hatırlatma Zamanı',
          StringConst.repeat: 'Tekrar',
          StringConst.deleteReminder: 'Hatırlatıcıyı Sil',
          StringConst.areYouSureToDeleteReminder: 'Bu hatırlatıcıyı silmek istediğinizden emin misiniz?',

          // Reminders Screen
          // ignore: equal_keys_in_map
          StringConst.yourReadingRemindersWillAppearHere: 'Okuma hatırlatıcılarınız burada görünecek',
          StringConst.reminderUpdateSuccess: 'Okuma hatırlatıcısı başarıyla güncellendi',
          StringConst.reminderUpdateFail: 'Okuma hatırlatıcısı güncellenemedi',
          StringConst.reminderDeleteSuccess: 'Okuma hatırlatıcısı başarıyla silindi',
          StringConst.reminderDeleteFail: 'Okuma hatırlatıcısı silinemedi',
          StringConst.reminderCreateSuccess: 'Okuma hatırlatıcısı başarıyla oluşturuldu',
          StringConst.reminderCreateFail: 'Okuma hatırlatıcısı oluşturulamadı',

          // Filters Screen
          StringConst.filters: 'Filtreler',
          StringConst.hasNotes: 'Nota Sahip',
          StringConst.hasHighlights: 'Önemli Noktaya Sahip',
          StringConst.ratingColon: 'Puan: ',
          StringConst.pageCountColon: 'Toplam Sayfa: ',
          StringConst.apply: 'Uygula',

          // Most Common Data Screen
          StringConst.notEnoughDataToDisplay: 'Görüntülenecek Yeterli Veri Yok',

          // Graphs Screen
          StringConst.graphs: 'Grafikler',
          StringConst.pagesReadLastSevenDays: 'Son 7 Günde Okunan Sayfalar',
          StringConst.bookStates: 'Kitap Durumları',
          StringConst.mostCommonAuthors: 'En Yaygın Yazarlar',
          StringConst.mostCommonGenres: 'En Yaygın Türler',
          StringConst.numberOfBooksByRatings: 'Puana Göre Kitap Sayısı',
          StringConst.star: 'Yıldız',
          StringConst.booksReadByMonth: 'Aylara Göre Okunan Kitaplar',
          StringConst.numberOfBooksByPageCount: 'Sayfa Sayısına Göre Kitap Sayısı',

          // Feedback Screen
          StringConst.thanksForConsideringFeedback: 'Hey! Uygulamayı kullandığınız için teşekkürler. Mümkün olan en iyi deneyimi sağlamak istiyoruz! Bize yardımcı olmak için, lütfen geri bildiriminizi bırakmak için bir dakikanızı ayırın.',
          StringConst.sendFeedback: 'Geribildirim Yolla',

          // Error Screen
          StringConst.anErrorOccuredPleaseCheckConnection: 'Bir hata oluştu.\nLütfen bağlantınızı kontrol edin.',
          StringConst.tryAgain: 'Tekrar Deneyin',

          // Email Confirmation Screen
          StringConst.confirmYourEmail: 'E-postanızı Onaylayın',
          StringConst.tapOneMoreTimeToGetBack: 'Geri dönmek için bir kez daha dokunun',
          StringConst.oneLastStep: 'Son Bir Adım',
          StringConst.yourAccountHasBeenCreated: 'Hesabınız oluşturuldu. Hesabınızla devam etmek için, e-posta adresinizi doğrulamalısınız.',
          StringConst.youWillSoonReceiveEmail: 'Yakında ekibimizden bir e-posta alacaksınız. Lütfen gelen kutunuzu kontrol edin.\n(Spam klasörünüzü de kontrol ettiğinizden emin olun)',
          StringConst.toVerifyEmail: 'E-postanızı doğrulamak için, aldığınız postada verilen bağlantıya tıklamanız yeterlidir.',
          StringConst.afterVerification: 'Doğruladıktan sonra, hesabınızla devam etmek için sayfanın altındaki "Devam" düğmesini tıklayın.',
          StringConst.ifYouDidNotReceive: 'Herhangi bir posta almadıysanız, lütfen aşağıdaki "Yeniden Gönder" düğmesini kullanın.',
          StringConst.resendEmail: 'Yeniden Gönder',
          StringConst.newEmailSent: 'Yeni bir doğrulama e-postası gönderildi',
          StringConst.failedToSendEmail: 'Doğrulama e-postası gönderilemedi',
          StringConst.continueTo: 'Devam',
          StringConst.wait: 'Bekleyin',
          StringConst.pleaseVerifyToContinue: 'Devam etmek için lütfen e-postanızı doğrulayın',

          // Create Highlight Screen
          StringConst.highlightScan: 'Önemli Nokta Tarama',
          StringConst.higlightPicture: 'Sayfa Resmi',
          StringConst.couldNotExtractText: 'Görüntüden metin çıkarılamadı.\n\nMetin içeren bir alanı kırptığınızdan emin olun',
          // ignore: equal_keys_in_map
          StringConst.takePhoto: 'Fotoğraf\nÇek',
          StringConst.createHighlight: 'Önemli nokta oluştur',
          StringConst.updateHighlight: 'Önemli nokta güncelle',
          StringConst.highlightCanNotBeEmpty: 'Önemli nokta boş olamaz',
          StringConst.areYouSureYouWantToDeleteHighlight: 'Bu önemli noktayı silmek istediğinizden emin misiniz?',
          StringConst.sectionChapter: r'Bölüm \ Kısım',
          StringConst.pageNo: 'Sayfa',
          StringConst.pageNoLengthCanNotBeMore: "Sayfa uzunluğu 10'dan fazla olamaz",
          StringConst.enterHighlight: 'Önemli Nokta Girin',

          // Create Collection Screen
          StringConst.editCollection: 'Koleksiyonu düzenleyin',
          StringConst.createCollection: 'Koleksiyon oluştur',
          StringConst.preparingCollection: 'Koleksiyon hazırlanıyor ...',
          StringConst.title: 'Kitap İsmi',
          StringConst.colectionName: 'Koleksiyon İsmi',
          StringConst.description: 'Açıklama',
          StringConst.booksInsideCollection: 'Koleksiyonun içindeki kitaplar',
          StringConst.booksToAddColleciton: 'Koleksiyona eklenecek kitaplar',

          // Collections Screen
          StringConst.yourColelctionsWillBeListedHere: 'Koleksiyonlarınız burada listelenecek.',
          StringConst.someIdeas: 'Birkaç fikir: ',
          StringConst.collectionIdea: 'En sevdiğim kitaplar, bu ay okunacak kitaplar, en sevdiğim romanlar vs ...',
          StringConst.collectionUpdateSuccess: 'Koleksiyon başarıyla güncellendi',
          StringConst.collectionUpdateFail: 'Koleksiyon güncellenemedi',
          StringConst.collectionDeleteSuccess: 'Koleksiyon başarıyla silindi',
          StringConst.collectionDeleteFail: 'Koleksiyon silinemedi',
          StringConst.collectionCreateSuccess: 'Koleksiyon başarıyla oluşturuldu',
          StringConst.collectionCreateFail: 'Koleksiyon oluşturulamadı',
          StringConst.reachedMaxColelctionCapacity: 'Maksimum koleksiyon kapasitesine ulaşıldı',

          // Collection Screen
          StringConst.tip: 'İpucu',
          StringConst.youCanReOrder: 'Kitaplarınızın sırasını değiştirebilirsiniz! Kartları uzun süre tutarak sürükleyip bırakın',
          StringConst.thisCollectionIsEmpty: 'Bu koleksiyon boş',
          StringConst.confirmDeletingSelectedBooks: 'Koleksiyondan seçilen kitapları silmek istediğinizden emin misiniz?',
          StringConst.bookSDeleteSuccess: 'Kitaplar başarıyla silindi',
          StringConst.bookSDeleteFail: 'Kitaplar silinemedi',
          StringConst.selectBooksToDelete: 'Silinecek kitapları seçin',

          // Change Password Screen
          StringConst.update: 'Güncelle',
          StringConst.passwordUpdateSuccess: 'Şifreniz güncellenmiştir',
          StringConst.madeTooMuchAttempts: 'Çok fazla yanlış girişimde bulundun. Lütfen daha sonra tekrar deneyiniz',
          StringConst.failedToReAuth: 'Yeniden kimlik doğrulaması yapılamadı',
          StringConst.currentPassword: 'Mevcut Şifre',
          StringConst.newPassword: 'Yeni Şifre',
          StringConst.newPasswordAgain: 'Yeni Şifre Tekrar',

          // Change Name Surname Screen
          StringConst.yourInfoHasBeenUpdated: 'Bilgileriniz güncellendi',
          StringConst.updateProfile: 'Profili Güncelle',

          // Change Email Screen
          StringConst.warning: 'UYARI',
          StringConst.youWillHaveToReLogin: 'Bu işlemden sonra hesabınızdan çıkış yapacaksınız. Yeniden giriş yapmanız gerekecek.',
          StringConst.newEmail: 'Yeni E-posta',
          StringConst.enterDifferentEmail: 'Lütfen farklı bir e-posta adresi girin',
          StringConst.updateEmail: 'E-postayı Güncelle',

          // Book Highlights Screen
          StringConst.generatePdf: 'Pdf Oluştur',
          StringConst.pdf: 'Pdf',
          StringConst.noHighlightFound: 'Önemli nokta bulunamadı',
          StringConst.searchWithoutDots: 'Ara',
          StringConst.dateCreated: 'Oluşturulma Tarihi',

          // Book Detail Screen
          StringConst.currentPosition: 'Şu Anki Pozisyon',
          StringConst.enterAValidPosition: 'Geçerli bir sayfa girin',
          StringConst.enterTotalPagesFirst: 'Önce toplam sayfaları girin',
          StringConst.couldNotUploadCover: 'Kapak resmi sunucuya aktarılamadı',
          StringConst.couldNotFindImages: 'Herhangi bir kapak resmi bulunamadı',
          StringConst.coverImgUrl: "Kapak Resmi URL'si",
          StringConst.urlCanNotBeNull: 'URL boş olamaz',
          StringConst.enterAValidUrl: 'Geçerli bir url girin',
          StringConst.urlWasNotValid: "URL, geçerli bir resim url'si değildi",
          StringConst.titleAndAuthor: 'Kitap İsmi ve Yazar',
          StringConst.titleIsRequired: 'Kitap ismi gerekli',
          StringConst.thisBookAlreadyExists: 'Bu kitap zaten var',
          StringConst.authorNameIsRequired: 'Yazar adı gerekli',
          StringConst.author: 'Yazar',
          StringConst.startReading: 'Okumaya Başla',
          StringConst.pagesLeft: 'sayfa kaldı',
          StringConst.dateStarted: 'Başlama Tarihi',
          StringConst.dateDropped: 'Bırakılma Tarihi',
          StringConst.dateFinished: 'Bitiş Tarihi',
          // ignore: equal_keys_in_map
          StringConst.totalPagess: 'Toplam Sayfa',
          StringConst.enterValidNumber: 'Geçerli bir numara girin',
          StringConst.totalPagesCantBeMoreThan: "Toplam sayfa 10.000'den fazla olamaz",
          StringConst.pagesRead: 'Okunan Sayfa',
          StringConst.genre: 'Tür',
          StringConst.state: 'Durum',
          StringConst.bookState: 'Kitap Durumu',
          StringConst.youCanTakeNotesHere: 'Buraya not alabilirsiniz!',
          // ignore: equal_keys_in_map
          StringConst.readingStats: 'Okuma İstatistikleri',
          StringConst.readingReminders: 'Okuma Hatırlatıcıları',
          StringConst.readingReminder: 'Okuma Hatırlatıcısı',
          StringConst.delete: 'Sil',
          StringConst.reset: 'Sıfırla',
          StringConst.confirmDeletingBook: 'Kitabı silmeyi onaylayın',

          // Add New Book Screen
          StringConst.upgradeToProToSeeWhy: "Limitinizi artırmak için premium'a yükseltin. Nedenini görmek için SSS'ye bakın",
          StringConst.pleaseEnterBookTitle: 'Online kitap kapaklarını aramak için lütfen bir kitap ismi girin',
          StringConst.bookTitleLengthMustBeLowerThan: "Kitap ismi uzunluğu 200'den az olmalıdır",
          StringConst.authorLengthMustBeLowerThan: "Yazar adı uzunluğu 200'den az olmalıdır",
          StringConst.bookStateIsRequired: 'Kitap durumu gerekli',
          StringConst.pagesReadCantBeMoreThanTotalPages: 'Okunan sayfalar toplam sayfadan fazla olamaz',

          // Buy Premium Screen
          StringConst.supportTheDevelopment: 'Gelişimi Destekleyin',
          StringConst.iHopeTheAppIsHelpingYou: 'Hey! Umarım uygulama kitaplarınızı takip etmenize ve sürekli bir okuma alışkanlığı oluşturmanıza yardımcı oluyordur.',
          StringConst.spIsMyFavProject: 'Simple Library, en sevdiğim hobi projelerimden biridir. Premium sürümü satın alarak yeni özellikleri daha hızlı geliştirmeme ve uygulamanın bakımını yapmama yardımcı olabilirsiniz!',
          StringConst.premiumBenefits: 'Premium Avantajları',
          StringConst.increaseLibraryCapacity: "Kütüphane kapasitesini 50'den 500 kitaba çıkarın",
          StringConst.increaseMaxGenreCapacity: "Maksimum tür kapasitesini 30'dan 100 türe artırın",
          StringConst.increaseMaxHighlightCapacity: "Her kitap için maksimum vurgulama kapasitesini 10'dan 100'e çıkarın",
          StringConst.increaseMaxCollectionCapacity: "Maksimum koleksiyon kapasitesini 5'ten 50'ye çıkarın",
          StringConst.accessToAllUpcomingFeatures: 'Tüm gelecek özelliklere erişim',
          StringConst.lifetimeValidity: 'Ömür boyu geçerlilik',
          StringConst.purchasePremiumVersion: 'Premium Sürümü Satın Al',
          StringConst.thankYou2: 'Teşekkürler!',
          StringConst.forYourSupport: 'Desteğiniz için',
          StringConst.thanksSupportMessage: "Desteğin için teşekkürler! Artık tüm premium özelliklere erişebilirsiniz. Simple Library'yi daha iyi bir uygulama haline getirebilecek herhangi bir isteğiniz veya fikriniz varsa, geri bildirim bırakmaktan çekinmeyin!",

          // Reading Chart Screen
          StringConst.pagesReadWithSpace: 'Okunan sayfa:  ',
          StringConst.dailyAvg: 'Günlük ortalama:  ',
          StringConst.showAvg: 'Ortalamayı Göster',
          StringConst.noDataAvailable: 'Veri bulunamadı\nOkuma grafiğinizi görmek için her gün okuduğunuz sayfaları güncelleyin',
          StringConst.pagesReadd: 'sayfa okundu',
          StringConst.pagesAvg: 'sayfa ort.\t',
          StringConst.dailyGraph: 'Günlük Grafik',
          StringConst.finishedIn: 'Bitirildi:  ',
          StringConst.maxPagesInADay: 'Maks. sayfa (1 günde):',
          StringConst.progressResetSuccess: 'İlerleme başarıyla sıfırlandı',
          StringConst.progressResetFail: 'İlerleme sıfırlanamadı',

          // Scanner Screen
          StringConst.scanACode: 'Kod Tara',
          StringConst.openFlash: 'Flaşı Aç',
          StringConst.closeFlash: 'Flaşı Kapa',

          // Seach Book Online Screen
          StringConst.queryCantBeEmpty: 'Sorgu boş olamaz',
          StringConst.scanIsbn: 'ISBN Tara',
          StringConst.poweredByGoogle: 'Powered by Google',

          // Sorting
          StringConst.sortBy: 'Sırala',
          StringConst.nameAtoZ: "İsim: A'dan Z'ye",
          StringConst.nameZtoA: "İsim: Z'den A'ya",
          StringConst.pageCount: 'Sayfa Sayısı',
          StringConst.numberOfHighlights: 'Önemli Nokta Sayısı',
          StringConst.dateAddedFirstToLatest: 'Kütüphaneye Eklenme Tarihi: İlkten En Sona',
          StringConst.dateAddedLatestToFirst: 'Kütüphaneye Eklenme Tarihi: En Sondan İlke',

          // Release Notes
          StringConst.nowOpenSource: "Simple Library artık açık kaynak!\nKaynak kodu https://github.com/N1ght-Fury/simple_library adresinde görüntülenebilir",
          StringConst.bugFixes: 'Hata düzeltmeleri',

          // Drawer
          StringConst.profile: 'Profil',
          StringConst.highlights: 'Önemli Noktalar',
          StringConst.goals: 'Hedefler',
          StringConst.statistics: 'İstatistikler',
          StringConst.collections: 'Koleksiyonlar',
          // ignore: equal_keys_in_map
          StringConst.settings: 'Ayarlar',
          StringConst.logout: 'Çıkış Yap',
          StringConst.loading: 'Yükleniyor...',

          // Widgets
          // ignore: equal_keys_in_map
          StringConst.open: 'Görüntüle',
          StringConst.confirmExit: 'Hesabınızdan çıkmak istediğinizden emin misiniz?',
          StringConst.genreCanNotBeEmpty: 'Tür boş olamaz',
          StringConst.genreLengthMustBeLowerThan: "Tür uzunluğu 200'den az olmalıdır",
          StringConst.thisGenreAlreadyExists: 'Bu tür zaten var',
          StringConst.editGenre: 'Türü Düzenle',
          StringConst.addNewGenre: 'Yeni Tür Ekle',
          StringConst.failedToUpdateGenre: 'Tür güncellenemedi',
          StringConst.reachedMaxGenreCapacity: 'Maksimum tür kapasitesine ulaşıldı',
          StringConst.couldNotAddGenre: 'Tür eklenemedi. Lütfen tekrar deneyin.',
          StringConst.add: 'Ekle',
          StringConst.chooseGenre: 'Bir Tür Seçin',
          StringConst.genresWillBeListedHere: 'Türleriniz burada listelenecek',
          StringConst.confirmDeletingGenre: 'Türü silmeyi onaylayın',
          StringConst.genreDeleteSuccess: 'Tür başarıyla silindi',
          StringConst.genreDeleteFail: 'Tür silinemedi',
          StringConst.genreUpdateSuccess: 'Tür başarıyla güncellendi',
          StringConst.genreInsertSuccess: 'Tür başarıyla eklendi',
          StringConst.tapToSetSearchLanguage: 'Arama dilini ayarlamak için dokunun',
          StringConst.bookCover: 'Kitap Kapağı',
          StringConst.searchOnline: 'Çevrimiçi\nAra',
          StringConst.enterUrl: 'Url\nGir',
          StringConst.deleteCover: 'Kapağı\nSil',
          StringConst.appSettings: 'Uygulama Ayarları',
          StringConst.success: 'Başarılı!',

          // Genres
          StringConst.adventure: 'Macera',
          StringConst.biography: 'Biyografi',
          StringConst.children: 'Çocuk',
          StringConst.classics: 'Klasikler',
          StringConst.contemporary: 'Modern',
          StringConst.dystopian: 'Distopik',
          StringConst.fantasy: 'Fantastik',
          StringConst.fiction: 'Roman',
          StringConst.history: 'Tarih',
          StringConst.horror: 'Korku',
          StringConst.memoir: 'Anı',
          StringConst.mystery: 'Gizem',
          StringConst.nonFiction: 'Kurgu Dışı',
          StringConst.paranormal: 'Paranormal',
          StringConst.romance: 'Romantik',
          StringConst.sciFi: 'Bilimkurgu',
          StringConst.selfHelp: 'Kişisel Gelişim',
          StringConst.thriller: 'Gerilim',
          StringConst.travel: 'Seyahat',
          StringConst.youngAdult: 'Genç Yetişkin',
          // ignore: equal_keys_in_map
          StringConst.otherGenre: 'Diğer',

          // Days
          StringConst.monday: 'Pazartesi',
          StringConst.tuesday: 'Salı',
          StringConst.wednesday: 'Çarşamba',
          StringConst.thursday: 'Perşembe',
          StringConst.friday: 'Cuma',
          StringConst.saturday: 'cumartesi',
          StringConst.sunday: 'Pazar',

          // Days Short
          StringConst.mon: 'Pzt',
          StringConst.tue: 'Sal',
          StringConst.wed: 'Çar',
          StringConst.thu: 'Per',
          StringConst.fri: 'Cum',
          StringConst.sat: 'Cmt',
          StringConst.sun: 'Paz',

          // Repetitions
          StringConst.once: 'Bir Kere',
          StringConst.daily: 'Günlük',
          StringConst.monToFri: "Pzt den Cum'ya",
          StringConst.weekends: 'Hafta Sonları',
          StringConst.custom: 'Özel',
        }
      };
}
