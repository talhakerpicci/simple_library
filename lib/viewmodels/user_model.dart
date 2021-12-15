import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../enums/default_view.dart';
import '../screens/welcome_screen.dart';
import '../enums/book_states.dart';
import '../enums/viewstate.dart';
import '../locator.dart';
import '../model/models.dart';
import '../services/api.dart';
import '../utils/utils.dart';

class UserModel extends ChangeNotifier {
  Api _api = locator<Api>();
  UserData user = UserData(
    defaultView: Utils.defaultView,
  );

  Future fillUserInfo() async {
    var result = await _api.reloadUser();

    if (!result) {
      clearUserData();
      imageCache.clear();
      imageCache.clearLiveImages();

      await _api.signOut();
      Get.offAll(() => WelcomeScreen(removeNotifs: true));
      return;
    }

    user.id = _api.user.uid;
    user.nameSurname = _api.user.displayName;
    user.email = _api.user.email;

    user.books = [];
    user.genres = [];
    user.monthlyGoals = [];
    user.yearlyGoals = [];
    user.collections = [];

    await getUserData();
    await getBookList();
    await getGenreList();
    await getCollections();

    notifyListeners();
  }

  bool isAllStatesReady() {
    if (user.getUserDataViewState == ViewState.Ready && user.getBooksViewState == ViewState.Ready && user.getGenresViewState == ViewState.Ready && user.getCollectionsViewState == ViewState.Ready) {
      return true;
    }
    return false;
  }

  Future getUserData() async {
    GetUserDataResult userDataResult = GetUserDataResult();

    try {
      user.getUserDataViewState = ViewState.Busy;
      notifyListeners();

      userDataResult = await _api.getUserData();

      if (userDataResult.success) {
        var userData = userDataResult.model[0]['data'];
        user.image = userData['avatar'];
        user.readingSpeed = userData['readingSpeed'];
        user.isPremium = userData['isPremium'];
        user.premiumPurchaseDate = userData['premiumPurchaseDate'] != null ? (userData['premiumPurchaseDate'] as Timestamp).toDate() : null;
        user.dateRegistered = (userData['dateRegistered'] as Timestamp).toDate();

        user.getUserDataViewState = ViewState.Ready;

        Utils.setLimits(user.isPremium);
      }
    } catch (e) {
      user.getUserDataViewState = ViewState.Error;
    }
    notifyListeners();
    return userDataResult.success;
  }

  Future<bool> updateAvatar({@required File avatar}) async {
    var result = await _api.uploadAvatarImage(avatar: avatar);
    if (result.success) {
      user.image = result.downloadUrl;
      notifyListeners();
    }

    return result.success;
  }

  Future<bool> deleteAvatar() async {
    var result = await _api.deleteAvatarImage();
    if (result) {
      user.image = '';
      notifyListeners();
    }

    return result;
  }

  Future<bool> updateNameSurname({@required String nameSurname}) async {
    var result = await _api.updateNameSurname(nameSurname: nameSurname);
    if (result) {
      user.nameSurname = nameSurname;
      notifyListeners();
    }

    return result;
  }

  Future<bool> updatePassword({@required String newPassword}) async {
    var result = await _api.updatePassword(newPassword: newPassword);
    return result;
  }

  Future<bool> updateEmail({@required String newEmail}) async {
    var result = await _api.updateEmail(newEmail: newEmail);
    return result;
  }

  Future<bool> updateReadingSpeed({@required int pages, @required int minutes}) async {
    var result = await _api.updateReadingSpeed(pages: pages, minutes: minutes);
    if (result) {
      user.readingSpeed = '$pages-$minutes';
      notifyListeners();
    }
    return result;
  }

  Future<bool> upgradeToPremium({String purchaseToken, String orderId}) async {
    var result = await _api.upgradeToPremium(
      purchaseToken: purchaseToken,
      orderId: orderId,
    );
    if (result) {
      user.isPremium = true;
      Utils.setLimits(user.isPremium);
      notifyListeners();
    }
    return result;
  }

  Future<ReAuthResult> reAuth({@required String email, @required String password}) async {
    var result = await _api.reAuthUser(email: email, password: password);
    return result;
  }

  Future getBookList() async {
    GetBookListResult bookListResult = GetBookListResult();
    try {
      user.getBooksViewState = ViewState.Busy;
      notifyListeners();
      bookListResult = await _api.getBookList();

      if (bookListResult.success) {
        user.books = bookListResult.model;
        user.books.sort((book1, book2) => book1.dateCreated.compareTo(book2.dateCreated));
        user.getBooksViewState = ViewState.Ready;
      }
    } catch (e) {
      user.getBooksViewState = ViewState.Error;
    }
    notifyListeners();
    return bookListResult.success;
  }

  Future addBook({@required Book book}) async {
    var result = await _api.addBook(book: book);

    if (result.success) {
      Book newBook = Book.fromJson2(id: result.model.id, json: book.toJson());
      user.books.add(newBook);
      notifyListeners();
    }
    return result;
  }

  Future updateBook({@required String id, @required Book book}) async {
    var result = await _api.updateBook(id: id, book: book);

    if (result.success) {
      Book _book = findBookById(id);
      _book.title = book.title;
      _book.author = book.author;
      _book.totalPages = book.totalPages;
      _book.pagesRead = book.pagesRead;
      _book.state = book.state;
      _book.genre = book.genre;
      _book.dateCreated = book.dateCreated;
      _book.dateStarted = book.dateStarted;
      _book.dateFinished = book.dateFinished;
      _book.imgUrl = book.imgUrl;
      _book.siteImgUrl = book.siteImgUrl;
      _book.notes = book.notes;
      _book.rating = book.rating;
      _book.graphData = book.graphData;
      _book.highlights = book.highlights;
      notifyListeners();
    }
    return result;
  }

  Future deleteBook({@required String id, @required String imgUrl}) async {
    var result = await _api.deleteBook(id: id);
    await _api.deleteCoverImage(id: id, imgUrl: imgUrl);
    if (result.success) {
      user.books.removeWhere((book) => book.id == id);
      notifyListeners();
    }
    return result;
  }

  List getBooksWithIds(List<String> bookIds) {
    List books = [];
    bookIds.forEach((id) {
      books.add(findBookById(id));
    });

    return books;
  }

  List<Book> filterBooks() {
    return user.books.where((book) {
      bool isConditionsMet = true;

      if (Utils.filter['title'] != '') {
        isConditionsMet = isConditionsMet && book.title.toLowerCase().contains(Utils.filter['title'].toLowerCase());
      }
      if (Utils.filter['author'] != '') {
        isConditionsMet = isConditionsMet && book.author.toLowerCase().contains(Utils.filter['author'].toLowerCase());
      }
      if (Utils.filter['rating'] != 0.0) {
        isConditionsMet = isConditionsMet && book.rating == Utils.filter['rating'];
      }
      if (Utils.filter['state'] != BookState.All) {
        isConditionsMet = isConditionsMet && book.state == Utils.filter['state'];
      }
      if (Utils.filter['genre'] != '') {
        isConditionsMet = isConditionsMet && book.genre == Utils.filter['genre'];
      }
      if (Utils.filter['has-notes']) {
        isConditionsMet = isConditionsMet && book.notes != '';
      }
      if (Utils.filter['has-highlits']) {
        isConditionsMet = isConditionsMet && book.highlights.length != 0;
      }
      if (Utils.filter['page-count'] != 0) {
        if (Utils.filter['show-higher']) {
          isConditionsMet = isConditionsMet && book.totalPages > Utils.filter['page-count'];
        } else if (Utils.filter['show-lower']) {
          isConditionsMet = isConditionsMet && book.totalPages < Utils.filter['page-count'];
        } else {
          isConditionsMet = isConditionsMet && book.totalPages == Utils.filter['page-count'];
        }
      }
      return isConditionsMet;
    }).toList();
  }

  List<Book> sortBooks({List books}) {
    List<Book> sortedBooks = List.from(books);

    if (Utils.sort['name-a-to-z']) {
      sortedBooks.sort((book1, book2) => book1.title.compareTo(book2.title));
    } else if (Utils.sort['name-z-to-a']) {
      sortedBooks.sort((book1, book2) => book2.title.compareTo(book1.title));
    } else if (Utils.sort['pages-read']) {
      sortedBooks.sort((book1, book2) => book2.pagesRead.compareTo(book1.pagesRead));
    } else if (Utils.sort['page-count']) {
      sortedBooks.sort((book1, book2) => book2.totalPages.compareTo(book1.totalPages));
    } else if (Utils.sort['date-started']) {
      sortedBooks.sort((book1, book2) {
        if (book1.dateStarted == null && book2.dateStarted == null) {
          return 0;
        } else if (book1.dateStarted == null) {
          return 1;
        } else if (book2.dateStarted == null) {
          return -1;
        } else {
          return book2.dateStarted.compareTo(book1.dateStarted);
        }
      });
    } else if (Utils.sort['date-finished']) {
      sortedBooks.sort((book1, book2) {
        if (book1.dateFinished == null && book2.dateFinished == null) {
          return 0;
        } else if (book1.dateFinished == null) {
          return 1;
        } else if (book2.dateFinished == null) {
          return -1;
        } else {
          return book2.dateFinished.compareTo(book1.dateFinished);
        }
      });
    } else if (Utils.sort['number-of-highlights']) {
      sortedBooks.sort((book1, book2) => book2.highlights.length.compareTo(book1.highlights.length));
    } else if (Utils.sort['date-added-to-library-first-to-latest']) {
      sortedBooks.sort((book1, book2) => book1.dateCreated.compareTo(book2.dateCreated));
    } else if (Utils.sort['date-added-to-library-latest-to-first']) {
      sortedBooks.sort((book1, book2) => book2.dateCreated.compareTo(book1.dateCreated));
    }

    return sortedBooks;
  }

  Book findBookById(String id) {
    return user.books.firstWhere((book) => book.id == id);
  }

  int getNumberOfBooks() {
    return user.books.length;
  }

  int getNumberOfReading() {
    return user.books.where((book) => book.state == BookState.Reading).toList().length;
  }

  int getNumberOfFinished() {
    return user.books.where((book) => book.state == BookState.Finished).toList().length;
  }

  int getNumberOfToRead() {
    return user.books.where((book) => book.state == BookState.ToRead).toList().length;
  }

  int getNumberOfDropped() {
    return user.books.where((book) => book.state == BookState.Dropped).toList().length;
  }

  int getNumberOfPagesRead() {
    int total = 0;
    user.books.forEach((book) {
      total += book.pagesRead;
    });
    return total;
  }

  List<String> getAllAuthors() {
    List<String> allAuthors = [];

    user.books.forEach((book) {
      if (!allAuthors.contains(book.author)) {
        allAuthors.add(book.author);
      }
    });

    return allAuthors;
  }

  List getBooksWithHighlight() {
    List<Book> books = user.books.where((book) => (book.highlights != null) && book.highlights.length != 0).toList();
    books.sort((book1, book2) => book2.highlights.length.compareTo(book1.highlights.length));
    return books;
  }

  bool isBookAlreadyExists(String title) {
    return user.books.firstWhere((book) => Utils.capitalizeString(string: book.title) == Utils.capitalizeString(string: title), orElse: () => null) != null ? true : false;
  }

  List<Book> getBooksReadThisMonth(DateTime date) {
    List<Book> books = user.books.where((book) {
      if (book.dateFinished != null) {
        DateTime dateFinished = book.dateFinished;
        if (dateFinished.month == date.month && dateFinished.year == date.year) {
          return true;
        }
      }
      return false;
    }).toList();
    books.sort((book1, book2) => book1.dateFinished.compareTo(book2.dateFinished));
    return books;
  }

  List<Book> getBooksReadThisYear(DateTime date) {
    List<Book> books = user.books.where((book) {
      if (book.dateFinished != null) {
        DateTime dateFinished = book.dateFinished;

        if (dateFinished.year == date.year) {
          return true;
        }
      }
      return false;
    }).toList();
    books.sort((book1, book2) => book1.dateFinished.compareTo(book2.dateFinished));
    return books;
  }

  int getNumberOfPagesReadToday() {
    int numOfPages = 0;
    user.books.forEach((book) {
      if (book.graphData != null && book.graphData.isNotEmpty) {
        if (book.graphData[Utils.formatter.format(DateTime.now())] != null) {
          numOfPages += book.graphData[Utils.formatter.format(DateTime.now())]['pagesRead'];
        }
      }
    });
    return numOfPages;
  }

  Future getGenreList() async {
    GetGenreListResult genreListResult = GetGenreListResult();
    try {
      user.getGenresViewState = ViewState.Busy;
      notifyListeners();
      genreListResult = await _api.getGenreList();

      if (genreListResult.success) {
        user.genres = genreListResult.model;
        user.genres.sort((genre1, genre2) => genre1.dateCreated.compareTo(genre2.dateCreated));
        user.getGenresViewState = ViewState.Ready;
      }
    } catch (e) {
      user.getGenresViewState = ViewState.Error;
    }
    notifyListeners();
    return genreListResult.success;
  }

  Future addGenre({@required Genre genre}) async {
    var result = await _api.addGenre(genre: genre);

    if (result.success) {
      Genre newGenre = Genre.fromJson(id: result.model.id, json: genre.toJson());
      user.genres.add(newGenre);
      notifyListeners();
    }

    return result;
  }

  Future updateGenre({@required String id, @required Genre genre}) async {
    var result = await _api.updateGenre(id: id, genre: genre);
    if (result.success) {
      Genre _genre = findGenreById(id);
      _genre.title = genre.title;
      notifyListeners();
    }
    return result;
  }

  Future deleteGenre({@required String id}) async {
    var result = await _api.deleteGenre(id: id);

    if (result.success) {
      user.genres.removeWhere((genre) => genre.id == id);
      notifyListeners();
    }
    return result;
  }

  Genre findGenreById(String id) {
    return user.genres.firstWhere((genre) => genre.id == id);
  }

  bool isGenreAlreadyExists(String title) {
    return user.genres.firstWhere((genre) => Utils.capitalizeString(string: genre.title) == Utils.capitalizeString(string: title), orElse: () => null) != null ? true : false;
  }

  Future getGoals() async {
    GetGoalsResult goalsResult = GetGoalsResult();

    try {
      user.getGoalsViewState = ViewState.Busy;
      notifyListeners();
      goalsResult = await _api.getGoals();
      if (goalsResult.success) {
        goalsResult.model.forEach((data) {
          switch (data.keys.toString()) {
            case '(daily)':
              user.dailyGoal = data['daily']['numOfPage'];
              break;
            case '(monthly)':
              (data['monthly'] as Map).forEach((key, value) {
                user.monthlyGoals.add(Goal(date: key, numberOfBooks: value['numOfBooks']));
              });
              break;
            case '(yearly)':
              (data['yearly'] as Map).forEach((key, value) {
                user.yearlyGoals.add(Goal(date: key, numberOfBooks: value['numOfBooks']));
              });
              break;
            default:
          }
        });

        user.monthlyGoals.sort(
          (goal1, goal2) => DateTime(
            int.parse(
              goal1.date.split('-')[1],
            ),
            int.parse(
              goal1.date.split('-')[0],
            ),
          ).compareTo(
            DateTime(
              int.parse(
                goal2.date.split('-')[1],
              ),
              int.parse(
                goal2.date.split('-')[0],
              ),
            ),
          ),
        );
        user.yearlyGoals.sort(
          (goal1, goal2) => DateTime(
            int.parse(
              goal1.date,
            ),
          ).compareTo(
            DateTime(
              int.parse(
                goal2.date,
              ),
            ),
          ),
        );

        user.getGoalsViewState = ViewState.Ready;
      }
    } catch (e) {
      user.getGoalsViewState = ViewState.Error;
    }
    notifyListeners();
    return goalsResult.success;
  }

  Future setGoal({@required String type, Goal newGoal, int pages}) async {
    var result;

    if (type == 'daily') {
      result = await _api.setGoal(type: type, pages: pages);
      if (result) {
        user.dailyGoal = pages;
      }
    } else {
      switch (type) {
        case 'monthly':
          Goal currentGoal = user.monthlyGoals.firstWhere((goal) => goal.date == newGoal.date, orElse: () => null);
          bool shouldDelete = false;

          if (currentGoal != null) {
            if (user.monthlyGoals.length != 1 && newGoal.numberOfBooks == 0) {
              shouldDelete = true;
            }

            currentGoal.numberOfBooks = newGoal.numberOfBooks;
          } else {
            user.monthlyGoals.add(newGoal);
          }

          result = await _api.setGoal(type: type, goal: newGoal, shouldDelete: shouldDelete);

          if (!result) {
            user.monthlyGoals.removeLast();
          }

          break;
        case 'yearly':
          Goal currentGoal = user.yearlyGoals.firstWhere((goal) => goal.date == newGoal.date, orElse: () => null);
          bool shouldDelete = false;

          if (currentGoal != null) {
            if (user.yearlyGoals.length != 1 && newGoal.numberOfBooks == 0) {
              shouldDelete = true;
            }
            currentGoal.numberOfBooks = newGoal.numberOfBooks;
          } else {
            user.yearlyGoals.add(newGoal);
          }

          result = await _api.setGoal(type: type, goal: newGoal, shouldDelete: shouldDelete);

          if (!result) {
            user.yearlyGoals.removeLast();
          }

          break;
        default:
      }
    }

    notifyListeners();
    return result;
  }

  int getDailyGoal() {
    int currentGoal = user.dailyGoal;

    if (currentGoal != null) {
      return currentGoal;
    }
    return 0;
  }

  int getMonthlyGoal(DateTime dateTime) {
    String date = DateFormat('M-y').format(dateTime);
    Goal currentGoal = user.monthlyGoals.firstWhere((goal) => goal.date == date, orElse: () => null);

    if (currentGoal != null) {
      return currentGoal.numberOfBooks;
    }
    return 0;
  }

  int getYearlyGoal(DateTime dateTime) {
    String date = DateFormat('y').format(dateTime);
    Goal currentGoal = user.yearlyGoals.firstWhere((goal) => goal.date == date, orElse: () => null);

    if (currentGoal != null) {
      return currentGoal.numberOfBooks;
    }
    return 0;
  }

  Future getCollections() async {
    GetCollectionResult collectionResult = GetCollectionResult();
    try {
      user.getCollectionsViewState = ViewState.Busy;
      notifyListeners();
      collectionResult = await _api.getCollections();

      if (collectionResult.success) {
        user.collections = collectionResult.model;
        user.collections.sort((col1, col2) => col1.dateCreated.compareTo(col2.dateCreated));
        user.getCollectionsViewState = ViewState.Ready;
      }
    } catch (e) {
      user.getCollectionsViewState = ViewState.Error;
    }
    notifyListeners();
    return collectionResult.success;
  }

  Future addCollecion({@required Collection collection}) async {
    var result = await _api.addCollection(collection: collection);

    if (result.success) {
      Collection newCollection = Collection.fromJson(id: result.model.id, json: collection.toJson());
      user.collections.add(newCollection);
      notifyListeners();
    }

    return result;
  }

  Future updateCollection({@required String id, @required Collection collection}) async {
    var result = await _api.updateCollection(id: id, collection: collection);
    if (result) {
      Collection _collection = findCollectionById(id);
      _collection.books = collection.books;
      _collection.description = collection.description;
      _collection.title = collection.title;
      notifyListeners();
    }
    return result;
  }

  Future<bool> deleteCollection({@required String id}) async {
    var result = await _api.deleteCollection(id: id);

    if (result) {
      user.collections.removeWhere((col) => col.id == id);
      notifyListeners();
    }
    return result;
  }

  Collection findCollectionById(String id) {
    return user.collections.firstWhere((col) => col.id == id);
  }

  bool isCollectionAlreadyExists(String title) {
    return user.collections.firstWhere((col) => Utils.capitalizeString(string: col.title) == Utils.capitalizeString(string: title), orElse: () => null) != null ? true : false;
  }

  Future<void> setDefaultViewSetting(DefaultView view) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('defaultView', view == DefaultView.LIST ? 'LIST' : 'GRID');
    user.defaultView = view;
    notifyListeners();
  }

  void clearUserData() {
    if (user.books != null) {
      user.books.clear();
    }

    if (user.genres != null) {
      user.genres.clear();
    }

    user.getBooksViewState = ViewState.Busy;
    user.getGenresViewState = ViewState.Busy;
    user.getGoalsViewState = ViewState.Busy;
    user.getCollectionsViewState = ViewState.Busy;

    notifyListeners();
  }
}
