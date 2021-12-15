import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../model/models.dart';
import '../utils/utils.dart';

class Api {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User user = FirebaseAuth.instance.currentUser;
  final CollectionReference _dataCollection = FirebaseFirestore.instance.collection('users');

  Future<RegisterUserResult> registerUser({@required String email, @required String password, @required String nameSurname}) async {
    UserCredential userCredential;
    FirebaseAuthException error;

    try {
      userCredential = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      user = userCredential.user;
      await user.updateProfile(displayName: nameSurname);
      await setInitialUserData();
    } on FirebaseAuthException catch (e) {
      error = e;
    } catch (e) {}

    return RegisterUserResult.fromJson(error: error, user: userCredential);
  }

  Future<SignInUserResult> signInUser({@required String email, @required String password}) async {
    UserCredential userCredential;
    FirebaseAuthException error;
    bool success = true;

    try {
      userCredential = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      error = e;
      success = false;
    } catch (e) {
      success = false;
    }

    return SignInUserResult.fromJson(error: error, user: userCredential, success: success);
  }

  Future<bool> deleteUser() async {
    bool success = true;

    var bookResult = await getBookList();
    var genreResult = await getGenreList();

    List<Book> books = bookResult.model;
    books.forEach((book) async {
      await deleteBook(id: book.id);
      await deleteCoverImage(id: book.id, imgUrl: book.imgUrl);
    });
    List<Genre> genres = genreResult.model;
    genres.forEach((genre) async {
      await deleteGenre(id: genre.id);
    });

    await deleteAvatarImage();
    await _dataCollection.doc(user.uid).collection('userData').doc('data').delete();
    await _dataCollection.doc(user.uid).delete();
    await user.delete();

    try {} catch (e) {
      success = false;
    }
    return success;
  }

  Future<bool> updateNameSurname({@required String nameSurname}) async {
    bool success = true;
    try {
      await user.updateProfile(displayName: nameSurname);
    } catch (e) {
      success = false;
    }

    return success;
  }

  Future<ReAuthResult> reAuthUser({@required String email, @required String password}) async {
    FirebaseAuthException error;
    bool success = true;
    try {
      UserCredential userCredential = await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: email,
          password: password,
        ),
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      error = e;
      success = false;
    } catch (e) {
      success = false;
    }

    return ReAuthResult.fromJson(error: error, success: success);
  }

  Future<bool> updateEmail({@required String newEmail}) async {
    bool success = true;
    try {
      await user.verifyBeforeUpdateEmail(newEmail);
    } catch (e) {
      success = false;
    }

    return success;
  }

  Future<bool> updatePassword({@required String newPassword}) async {
    bool success = true;
    try {
      await user.updatePassword(newPassword);
    } catch (e) {
      success = false;
    }

    return success;
  }

  Future<bool> updateReadingSpeed({@required int pages, @required int minutes}) async {
    bool success = true;

    try {
      await _dataCollection.doc(user.uid).collection('userData').doc('data').set(
        {
          'readingSpeed': '$pages-$minutes',
        },
        SetOptions(
          merge: true,
        ),
      );
    } catch (e) {
      success = false;
    }

    return success;
  }

  Future<bool> upgradeToPremium({String purchaseToken, String orderId}) async {
    bool success = true;

    try {
      await _dataCollection.doc(user.uid).collection('userData').doc('data').set(
        {
          'isPremium': true,
          'premiumPurchaseDate': DateTime.now(),
          'purchaseToken': purchaseToken,
          'orderId': orderId,
        },
        SetOptions(
          merge: true,
        ),
      );
    } catch (e) {
      success = false;
    }

    return success;
  }

  bool isUserVerified() {
    return user.emailVerified;
  }

  Future<bool> reloadUser() async {
    try {
      await user.reload();
      user = FirebaseAuth.instance.currentUser;

      return true;
    } catch (e) {
      if (!(await Utils.isOnline())) {
        return true;
      }
      return false;
    }
  }

  Future<void> sendVerificationEmail() async {
    await setAuthLanguage();
    await user.sendEmailVerification();
  }

  Future<void> sendPasswordResetEmail({@required email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> setAuthLanguage() async {
    await _auth.setLanguageCode(Utils.currentLocale.languageCode);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> setInitialUserData() async {
    bool success = true;
    try {
      await _dataCollection.doc(user.uid).collection('userData').doc('data').set({
        'avatar': '',
        'isPremium': false,
        'premiumPurchaseDate': null,
        'dateRegistered': DateTime.now(),
        'readingSpeed': '1-1',
      });

      await setGoal(type: 'monthly', goal: Goal(date: '${DateTime.now().month}-${DateTime.now().year}', numberOfBooks: 0));
      await setGoal(type: 'yearly', goal: Goal(date: '${DateTime.now().year}', numberOfBooks: 0));

      Utils.defaultGenres.forEach((genre) async {
        await addGenre(genre: Genre(title: genre.title, dateCreated: DateTime.now()));
      });
    } catch (e) {
      success = false;
    }
    return success;
  }

  Future<UploadAvatarImageResult> uploadAvatarImage({@required File avatar}) async {
    bool success = true;
    String url = '';
    try {
      StorageReference storageReferance = FirebaseStorage.instance.ref().child('${user.uid}/avatar/avatar.png');
      final StorageUploadTask uploadTask = storageReferance.putFile(avatar);
      final StorageTaskSnapshot downloadUrl = await uploadTask.onComplete;
      url = await downloadUrl.ref.getDownloadURL();
      await _dataCollection.doc(user.uid).collection('userData').doc('data').set(
        {
          'avatar': url,
        },
        SetOptions(
          merge: true,
        ),
      );
    } catch (e) {
      success = false;
    }
    return UploadAvatarImageResult(success: success, downloadUrl: url);
  }

  Future<bool> deleteAvatarImage() async {
    bool success = true;

    if (user.photoURL != '') {
      try {
        StorageReference storageReferance = FirebaseStorage.instance.ref().child('${user.uid}/avatar/avatar.png');
        await storageReferance.delete();
        await _dataCollection.doc(user.uid).collection('userData').doc('data').set(
          {
            'avatar': '',
          },
          SetOptions(
            merge: true,
          ),
        );
      } catch (e) {
        success = false;
      }
    }

    return success;
  }

  Future<GetUserDataResult> getUserData() async {
    List<Map> userData = [];
    QuerySnapshot response;
    bool success = true;
    try {
      response = await _dataCollection.doc(user.uid).collection('userData').get();
      response.docs.forEach((doc) {
        userData.add({doc.id: doc.data()});
      });
    } catch (e) {
      success = false;
    }

    return GetUserDataResult.fromJson(success: success, model: userData);
  }

  Future<GetBookListResult> getBookList() async {
    QuerySnapshot response;
    bool success = true;
    try {
      response = await _dataCollection.doc(user.uid).collection('books').get();
    } catch (e) {
      success = false;
    }
    return GetBookListResult.fromJson(success: success, model: response.docs);
  }

  Future<AddBookResult> addBook({@required Book book}) async {
    DocumentReference response;
    bool success = true;
    try {
      response = await _dataCollection.doc(user.uid).collection('books').add(book.toJson());
    } catch (e) {
      success = false;
    }
    return AddBookResult.fromJson(success: success, model: Book.fromJson2(id: response.id, json: book.toJson()));
  }

  Future<UpdateBookResult> updateBook({@required String id, @required Book book}) async {
    bool success = true;

    try {
      await _dataCollection.doc(user.uid).collection('books').doc(id).update(book.toJson());
    } catch (e) {
      success = false;
    }
    return UpdateBookResult.fromJson(success: success);
  }

  Future<DeleteBookResult> deleteBook({@required String id}) async {
    bool success = true;

    try {
      await _dataCollection.doc(user.uid).collection('books').doc(id).delete();
    } catch (e) {
      success = false;
    }
    return DeleteBookResult.fromJson(success: success);
  }

  Future<GetGenreListResult> getGenreList() async {
    QuerySnapshot response;
    bool success = true;
    try {
      response = await _dataCollection.doc(user.uid).collection('genres').get();
    } catch (e) {
      success = false;
    }
    return GetGenreListResult.fromJson(success: success, model: response.docs);
  }

  Future<AddGenreResult> addGenre({@required Genre genre}) async {
    DocumentReference response;
    bool success = true;
    try {
      response = await _dataCollection.doc(user.uid).collection('genres').add(genre.toJson());
    } catch (e) {
      success = false;
    }
    return AddGenreResult.fromJson(success: success, model: Genre.fromJson(id: response.id, json: genre.toJson()));
  }

  Future<UpdateGenreResult> updateGenre({@required String id, @required Genre genre}) async {
    bool success = true;

    try {
      await _dataCollection.doc(user.uid).collection('genres').doc(id).update(genre.toJson());
    } catch (e) {
      success = false;
    }
    return UpdateGenreResult.fromJson(success: success);
  }

  Future<DeleteGenreResult> deleteGenre({@required String id}) async {
    bool success = true;

    try {
      await _dataCollection.doc(user.uid).collection('genres').doc(id).delete();
    } catch (e) {
      success = false;
    }
    return DeleteGenreResult.fromJson(success: success);
  }

  Future<GetCollectionResult> getCollections() async {
    QuerySnapshot response;
    bool success = true;
    try {
      response = await _dataCollection.doc(user.uid).collection('collections').get();
    } catch (e) {
      success = false;
    }
    return GetCollectionResult.fromJson(success: success, model: response.docs);
  }

  Future<AddCollectionResult> addCollection({@required Collection collection}) async {
    DocumentReference response;
    bool success = true;
    try {
      response = await _dataCollection.doc(user.uid).collection('collections').add(collection.toJson());
    } catch (e) {
      success = false;
    }
    return AddCollectionResult.fromJson(success: success, model: Collection.fromJson(id: response.id, json: collection.toJson()));
  }

  Future<bool> updateCollection({@required String id, @required Collection collection}) async {
    bool success = true;

    try {
      await _dataCollection.doc(user.uid).collection('collections').doc(id).update(collection.toJson());
    } catch (e) {
      success = false;
    }
    return success;
  }

  Future<bool> deleteCollection({@required String id}) async {
    bool success = true;

    try {
      await _dataCollection.doc(user.uid).collection('collections').doc(id).delete();
    } catch (e) {
      success = false;
    }
    return success;
  }

  Future<UploadCoverImageResult> uploadCoverImage({@required File bookCover, @required String bookId}) async {
    bool success = true;
    String url = '';
    try {
      StorageReference storageReferance = FirebaseStorage.instance.ref().child('${user.uid}/covers/$bookId');
      final StorageUploadTask uploadTask = storageReferance.putFile(bookCover);
      final StorageTaskSnapshot downloadUrl = await uploadTask.onComplete;
      url = await downloadUrl.ref.getDownloadURL();
    } catch (e) {
      success = false;
    }
    return UploadCoverImageResult(success: success, downloadUrl: url);
  }

  Future<DeleteCoverImageResult> deleteCoverImage({@required String id, @required String imgUrl}) async {
    bool success = true;
    if (imgUrl != '') {
      try {
        StorageReference storageReferance = FirebaseStorage.instance.ref().child('${user.uid}/covers/$id');
        await storageReferance.delete();
      } catch (e) {
        success = false;
      }
    }

    return DeleteCoverImageResult(success: success);
  }

  Future<bool> setInitialGoals() async {
    bool success = true;
    String date = DateFormat('M-y').format(DateTime.now()).toString();
    try {
      await _dataCollection.doc(user.uid).collection('goals').doc('daily').set({
        'pages': 0,
      });
      await _dataCollection.doc(user.uid).collection('goals').doc('monthly').set({
        date: {
          'numOfBooks': 0,
        }
      });
      await _dataCollection.doc(user.uid).collection('goals').doc('yearly').set({
        date: {
          'numOfBooks': 0,
        }
      });
    } catch (e) {
      success = false;
    }
    return success;
  }

  Future<bool> setGoal({@required String type, Goal goal, int pages, bool shouldDelete = false}) async {
    bool success = true;

    try {
      if (type == 'daily') {
        await _dataCollection.doc(user.uid).collection('goals').doc(type).set(
          {
            'numOfPage': pages == 0 && shouldDelete ? FieldValue.delete() : pages,
          },
          SetOptions(
            merge: true,
          ),
        );
      } else {
        await _dataCollection.doc(user.uid).collection('goals').doc(type).set(
          {
            goal.date: goal.numberOfBooks == 0 && shouldDelete
                ? FieldValue.delete()
                : {
                    'numOfBooks': goal.numberOfBooks,
                  }
          },
          SetOptions(
            merge: true,
          ),
        );
      }
    } catch (e) {
      success = false;
    }

    return success;
  }

  Future<GetGoalsResult> getGoals() async {
    List<Map> goals = [];
    QuerySnapshot response;
    bool success = true;
    try {
      response = await _dataCollection.doc(user.uid).collection('goals').get();
      response.docs.forEach((doc) {
        goals.add({doc.id: doc.data()});
      });
    } catch (e) {
      success = false;
    }

    return GetGoalsResult.fromJson(success: success, model: goals);
  }

  Future<void> getUserStats() async {}
}
