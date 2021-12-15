import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../enums/default_view.dart';
import '../enums/book_states.dart';
import '../enums/viewstate.dart';
import '../utils/utils.dart';

part 'models.g.dart';

class RegisterUserResult {
  FirebaseAuthException error;
  UserCredential user;

  RegisterUserResult({
    this.error,
    this.user,
  });

  RegisterUserResult.fromJson({FirebaseAuthException error, UserCredential user})
      : this.error = error,
        this.user = user;

  Map<String, dynamic> toJson() => {
        'error': error,
        'user': user,
      };
}

class SignInUserResult {
  FirebaseAuthException error;
  UserCredential user;
  bool success;

  SignInUserResult({
    this.error,
    this.user,
    this.success,
  });

  SignInUserResult.fromJson({FirebaseAuthException error, UserCredential user, bool success})
      : this.error = error,
        this.user = user,
        this.success = success;

  Map<String, dynamic> toJson() => {
        'error': error,
        'user': user,
        'success': success,
      };
}

class ReAuthResult {
  FirebaseAuthException error;
  bool success;

  ReAuthResult({
    this.error,
    this.success,
  });

  ReAuthResult.fromJson({FirebaseAuthException error, bool success})
      : this.error = error,
        this.success = success;

  Map<String, dynamic> toJson() => {
        'error': error,
        'success': success,
      };
}

class GetUserDataResult {
  bool success;
  List<Map> model;

  GetUserDataResult({
    this.success = false,
    this.model,
  });

  GetUserDataResult.fromJson({bool success, List<Map> model})
      : this.success = success,
        this.model = model;

  Map<String, dynamic> toJson() => {
        'success': success,
        'model': model,
      };
}

class GetGoalsResult {
  bool success;
  List<Map> model;

  GetGoalsResult({
    this.success = false,
    this.model,
  });

  GetGoalsResult.fromJson({bool success, List<Map> model})
      : this.success = success,
        this.model = model;

  Map<String, dynamic> toJson() => {
        'success': success,
        'model': model,
      };
}

class GetBookListResult {
  bool success;
  var model;

  GetBookListResult({
    this.success = false,
    this.model,
  });

  GetBookListResult.fromJson({bool success, List<QueryDocumentSnapshot> model})
      : this.success = success,
        this.model = Utils.getBooks(model);

  Map<String, dynamic> toJson() => {
        'success': success,
        'model': model,
      };
}

class AddBookResult {
  bool success;
  Book model;

  AddBookResult.fromJson({bool success, var model})
      : this.success = success,
        this.model = model;

  Map<String, dynamic> toJson() => {
        'success': success,
        'model': model,
      };
}

class UpdateBookResult {
  bool success;

  UpdateBookResult.fromJson({bool success}) : this.success = success;

  Map<String, dynamic> toJson() => {
        'success': success,
      };
}

class DeleteBookResult {
  bool success;

  DeleteBookResult.fromJson({bool success}) : this.success = success;

  Map<String, dynamic> toJson() => {
        'success': success,
      };
}

class Book {
  String id;
  String title;
  String author;
  String genre;
  DateTime dateCreated;
  DateTime dateFinished;
  DateTime dateStarted;
  Map graphData = {};
  List<Highlight> highlights = [];
  String imgUrl;
  String siteImgUrl;
  String notes;
  int pagesRead;
  int totalPages;
  double rating;
  BookState state;

  Book({
    this.id,
    this.author = '',
    this.genre = '',
    this.dateCreated,
    this.dateFinished,
    this.dateStarted,
    this.graphData,
    this.highlights,
    this.imgUrl = '',
    this.siteImgUrl = '',
    this.notes = '',
    this.pagesRead = 0,
    this.rating = 0,
    this.state,
    this.title = '',
    this.totalPages = 0,
  });

  Book.fromJson({String id, Map<String, dynamic> json})
      : id = id,
        author = json['author'] as String,
        genre = json['genre'] as String,
        dateCreated = json['dateCreated'] == null ? null : (json['dateCreated'] as Timestamp).toDate(),
        dateFinished = json['dateFinished'] == null ? null : (json['dateFinished'] as Timestamp).toDate(),
        dateStarted = json['dateStarted'] == null ? null : (json['dateStarted'] as Timestamp).toDate(),
        graphData = json['graphData'] == null ? {} : json['graphData'],
        imgUrl = json['imgUrl'] as String,
        siteImgUrl = json['siteImgUrl'] as String,
        highlights = json['highlights'] == null || json['highlights'] == '' ? [] : Utils.getHighlights(json['highlights'] as List),
        notes = json['notes'] as String,
        pagesRead = json['pagesRead'] as int,
        rating = json['rating'] as double,
        state = BookState.values.firstWhere((item) => item.toString() == json['state']),
        title = json['title'] as String,
        totalPages = json['totalPages'] as int;

  Book.fromJson2({String id, Map<String, dynamic> json})
      : id = id,
        author = json['author'] as String,
        genre = json['genre'] as String,
        dateCreated = json['dateCreated'],
        dateFinished = json['dateFinished'] == null ? null : json['dateFinished'],
        dateStarted = json['dateStarted'] == null ? null : json['dateStarted'],
        graphData = json['graphData'] == null ? {} : json['graphData'],
        imgUrl = json['imgUrl'] as String,
        siteImgUrl = json['siteImgUrl'] as String,
        highlights = json['highlights'] == null || json['highlights'] == '' ? [] : Utils.getHighlights(json['highlights'] as List),
        notes = json['notes'] as String,
        pagesRead = json['pagesRead'] as int,
        rating = json['rating'] as double,
        state = BookState.values.firstWhere((item) => item.toString() == json['state']),
        title = json['title'] as String,
        totalPages = json['totalPages'] as int;

  Map<String, dynamic> toJson() => {
        'author': author,
        'genre': genre,
        'dateCreated': dateCreated,
        'dateFinished': dateFinished,
        'dateStarted': dateStarted,
        'graphData': graphData,
        'highlights': highlights.map((highlight) => highlight.toJson()).toList(),
        'imgUrl': imgUrl,
        'siteImgUrl': siteImgUrl,
        'notes': notes,
        'pagesRead': pagesRead,
        'rating': rating,
        'state': state.toString(),
        'title': title,
        'totalPages': totalPages,
      };

  @override
  bool operator ==(Object book) => identical(this, book) || book is Book && runtimeType == book.runtimeType && author == book.author && genre == book.genre && graphData == book.graphData && imgUrl == book.imgUrl && notes == book.notes && pagesRead == book.pagesRead && rating == book.rating && state == book.state && title == book.title && totalPages == book.totalPages && book.dateStarted == dateStarted && book.dateFinished == dateFinished && book.siteImgUrl == siteImgUrl;

  @override
  int get hashCode => id.hashCode;
}

class GoogleBook {
  String title;
  String authors;
  String thumbnail;
  int pageCount;

  GoogleBook({
    this.title,
    this.authors,
    this.thumbnail = '',
    this.pageCount = 0,
  });

  GoogleBook.fromJson(Map<String, dynamic> json)
      : title = json['volumeInfo']['title'] as String,
        authors = (json['volumeInfo']['authors'] as List) != null ? (json['volumeInfo']['authors'] as List).join(', ') : '',
        thumbnail = json['volumeInfo']['imageLinks'] != null ? (json['volumeInfo']['imageLinks']['thumbnail'] as String).replaceAll('&edge=curl', '').replaceAll('http', 'https') : '',
        pageCount = json['volumeInfo']['pageCount'] != null ? json['volumeInfo']['pageCount'] : 0;

  static List<GoogleBook> parseFromJsonStr(var jsonStr) {
    final map = json.decode(jsonStr);
    final jsonList = map['items'] as List<dynamic>;
    return [
      for (final jsonMap in jsonList)
        GoogleBook.fromJson(
          jsonMap as Map<String, dynamic>,
        ),
    ];
  }
}

class GetGenreListResult {
  bool success;
  var model;

  GetGenreListResult({
    this.success = false,
    this.model,
  });

  GetGenreListResult.fromJson({bool success, List<QueryDocumentSnapshot> model})
      : this.success = success,
        this.model = Utils.getGenres(model);

  Map<String, dynamic> toJson() => {
        'success': success,
        'model': model,
      };
}

class AddGenreResult {
  bool success;
  Genre model;

  AddGenreResult.fromJson({bool success, var model})
      : this.success = success,
        this.model = model;

  Map<String, dynamic> toJson() => {
        'success': success,
        'model': model,
      };
}

class UpdateGenreResult {
  bool success;

  UpdateGenreResult.fromJson({bool success}) : this.success = success;

  Map<String, dynamic> toJson() => {
        'success': success,
      };
}

class DeleteGenreResult {
  bool success;

  DeleteGenreResult.fromJson({bool success}) : this.success = success;

  Map<String, dynamic> toJson() => {
        'success': success,
      };
}

class Genre {
  String id;
  String title;
  DateTime dateCreated;

  Genre({
    this.id,
    this.title,
    this.dateCreated,
  });

  Genre.fromJson({String id, Map<String, dynamic> json})
      : this.id = id,
        this.title = json['title'],
        this.dateCreated = json['dateCreated'] == null ? null : DateTime.parse(json['dateCreated']);

  Map<String, dynamic> toJson() => {
        'title': title,
        'dateCreated': dateCreated.toIso8601String(),
      };
}

class Goal {
  String date;
  int numberOfBooks;

  Goal({
    this.date,
    this.numberOfBooks,
  });

  Goal.fromJson({String date, int numberOfBooks})
      : this.date = date,
        this.numberOfBooks = numberOfBooks;

  Map<String, dynamic> toJson() => {
        'date': date,
        'numberOfBooks': numberOfBooks,
      };
}

class Collection {
  String id;
  String title;
  String description;
  List<String> books;
  DateTime dateCreated;

  Collection({
    this.id,
    this.title = '',
    this.description = '',
    this.books,
    this.dateCreated,
  });

  Collection.fromJson({String id, Map<String, dynamic> json})
      : this.id = id,
        this.title = json['title'],
        this.description = json['description'],
        this.books = json['books'].cast<String>(),
        this.dateCreated = json['dateCreated'] == null
            ? null
            : json['dateCreated'] is DateTime
                ? json['dateCreated']
                : (json['dateCreated'] as Timestamp).toDate();

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'books': List.from(books),
        'dateCreated': dateCreated,
      };

  @override
  bool operator ==(Object collection) => identical(this, collection) || collection is Collection && runtimeType == collection.runtimeType && title == collection.title && description == collection.description && listEquals(books, collection.books);

  @override
  int get hashCode => id.hashCode;
}

class GetCollectionResult {
  bool success;
  var model;

  GetCollectionResult({
    this.success = false,
    this.model,
  });

  GetCollectionResult.fromJson({bool success, List<QueryDocumentSnapshot> model})
      : this.success = success,
        this.model = Utils.getCollections(model);

  Map<String, dynamic> toJson() => {
        'success': success,
        'model': model,
      };
}

class AddCollectionResult {
  bool success;
  Collection model;

  AddCollectionResult.fromJson({bool success, var model})
      : this.success = success,
        this.model = model;

  Map<String, dynamic> toJson() => {
        'success': success,
        'model': model,
      };
}

@HiveType(typeId: 0)
class Reminder {
  @HiveField(0)
  String id;

  @HiveField(1)
  String timeOfDay;

  @HiveField(2)
  Repetition repetition;

  @HiveField(3)
  String customMessage;

  @HiveField(4)
  List<int> days;

  Reminder({
    this.id,
    this.timeOfDay = '',
    this.repetition = Repetition.Once,
    this.customMessage = '',
    this.days,
  });

  Reminder.fromJson({Map<String, dynamic> json})
      : this.id = json['id'],
        this.timeOfDay = json['timeOfDay'],
        this.repetition = json['repetition'],
        this.customMessage = json['customMessage'],
        this.days = json['days'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'timeOfDay': timeOfDay,
        'repetition': repetition,
        'customMessage': customMessage,
        'days': days,
      };
}

@HiveType(typeId: 1)
class BookReminderData extends HiveObject {
  @HiveField(0)
  String bookId;

  @HiveField(1)
  List<Reminder> reminders;

  BookReminderData({
    this.bookId,
    this.reminders,
  });
}

@HiveType(typeId: 2)
enum Repetition {
  @HiveField(0)
  Once,

  @HiveField(1)
  Daily,

  @HiveField(2)
  MonToFri,

  @HiveField(3)
  Weekends,

  @HiveField(4)
  Custom,
}

class UserData {
  String id;
  String nameSurname;
  String email;
  String image;
  String readingSpeed;
  int dailyGoal;
  List<Book> books;
  List<Genre> genres;
  List<Goal> monthlyGoals;
  List<Goal> yearlyGoals;
  List<Collection> collections;
  DefaultView defaultView;
  ViewState getUserDataViewState;
  ViewState getBooksViewState;
  ViewState getGenresViewState;
  ViewState getGoalsViewState;
  ViewState getCollectionsViewState;
  bool isPremium;
  DateTime dateRegistered;
  DateTime premiumPurchaseDate;

  UserData({
    this.id,
    this.nameSurname,
    this.email,
    this.image,
    this.dailyGoal = 0,
    this.books,
    this.genres,
    this.monthlyGoals,
    this.yearlyGoals,
    this.collections,
    this.defaultView,
    this.getUserDataViewState = ViewState.Busy,
    this.getBooksViewState = ViewState.Busy,
    this.getGenresViewState = ViewState.Busy,
    this.getGoalsViewState = ViewState.Busy,
    this.getCollectionsViewState = ViewState.Busy,
    this.isPremium = false,
    this.dateRegistered,
  });
}

class Highlight {
  String chapter;
  String pageNo;
  String highlight;
  String textAlign;
  DateTime dateCreated;

  Highlight({
    this.chapter = '',
    this.pageNo = '',
    this.highlight = '',
    this.textAlign = 'left',
    this.dateCreated,
  });

  Highlight.fromJson({Map<String, dynamic> json})
      : this.chapter = json['chapter'],
        this.pageNo = json['pageNo'],
        this.highlight = json['highlight'],
        this.textAlign = json['textAlign'],
        this.dateCreated = json['dateCreated'] == null ? null : (json['dateCreated'] as Timestamp).toDate();

  Highlight.fromJson2({Map<String, dynamic> json})
      : this.chapter = json['chapter'],
        this.pageNo = json['pageNo'],
        this.highlight = json['highlight'],
        this.textAlign = json['textAlign'],
        this.dateCreated = json['dateCreated'] == null ? null : json['dateCreated'];

  Map<String, dynamic> toJson() => {
        'chapter': chapter,
        'pageNo': pageNo,
        'highlight': highlight,
        'textAlign': textAlign,
        'dateCreated': dateCreated,
      };

  @override
  bool operator ==(Object highlightObj) => identical(this, highlightObj) || highlightObj is Highlight && runtimeType == highlightObj.runtimeType && chapter == highlightObj.chapter && pageNo == highlightObj.pageNo && highlight == highlightObj.highlight && textAlign == highlightObj.textAlign;

  @override
  int get hashCode => dateCreated.hashCode;
}

class UploadCoverImageResult {
  bool success;
  String downloadUrl;

  UploadCoverImageResult({this.success, this.downloadUrl});

  UploadCoverImageResult.fromJson({bool success, String downloadUrl})
      : this.success = success,
        this.downloadUrl = downloadUrl;

  Map<String, dynamic> toJson() => {
        'success': success,
        'downloadUrl': downloadUrl,
      };
}

class DeleteCoverImageResult {
  bool success;

  DeleteCoverImageResult({this.success});

  DeleteCoverImageResult.fromJson({bool success}) : this.success = success;

  Map<String, dynamic> toJson() => {
        'success': success,
      };
}

class UploadAvatarImageResult {
  bool success;
  String downloadUrl;

  UploadAvatarImageResult({this.success, this.downloadUrl});

  UploadAvatarImageResult.fromJson({bool success, String downloadUrl})
      : this.success = success,
        this.downloadUrl = downloadUrl;

  Map<String, dynamic> toJson() => {
        'success': success,
        'downloadUrl': downloadUrl,
      };
}

class GetUserStatsResult {
  bool success;
  var model;

  GetUserStatsResult.fromJson({bool success, List<QueryDocumentSnapshot> model})
      : this.success = success,
        this.model = Utils.getBooks(model);

  Map<String, dynamic> toJson() => {
        'success': success,
        'model': model,
      };
}
