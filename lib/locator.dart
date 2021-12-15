import 'package:get_it/get_it.dart';

import 'services/api.dart';
import 'viewmodels/user_model.dart';
import 'viewmodels/db_model.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => Api());
  locator.registerFactory(() => UserModel());
  locator.registerFactory(() => DbModel());
}
