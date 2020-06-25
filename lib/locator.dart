import 'package:get_it/get_it.dart';
import 'services/FireStoreService.dart';

GetIt locator = GetIt.instance;
void setupLocator() {
  locator.registerLazySingleton(() => FireStoreService());
}