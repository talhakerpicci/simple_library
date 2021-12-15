import 'package:flutter/widgets.dart';

import '../enums/viewstate.dart';

class BaseModel extends ChangeNotifier {
  ViewState _state = ViewState.Ready;

  ViewState get state => _state;

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }
}
