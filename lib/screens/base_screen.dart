import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../locator.dart';
import '../viewmodels/base_model.dart';

class BaseScreen<T extends BaseModel> extends StatefulWidget {
  final Widget Function(BuildContext context, T model, Widget child) builder;
  final Function(T) onModelReady;

  BaseScreen({this.builder, this.onModelReady});

  @override
  _BaseScreenState<T> createState() => _BaseScreenState<T>();
}

class _BaseScreenState<T extends BaseModel> extends State<BaseScreen<T>> {
  T model = locator<T>();

  @override
  void initState() {
    if (widget.onModelReady != null) {
      widget.onModelReady(model);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(create: (context) => model, child: Consumer<T>(builder: widget.builder));
  }
}
