
import 'package:mobx/mobx.dart';

part 'user_fav.g.dart';

class UserFav = UserFavBase with _$UserFav;

abstract class UserFavBase with Store {
  /// Last time the favourites has been updated.
  @observable
  DateTime updatedAt = DateTime.now();

  @action
  void updateDate() {
    updatedAt = DateTime.now();
  }
}

final stateUserFav = UserFav();
