// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'automapper.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class $ExampleMapper {
  Type _typeOf<X>() => X;
  bool canConvert<I, R>() {
    if (_typeOf<I>() == UserDto && _typeOf<R>() == User) {
      return true;
    }
    if (_typeOf<I>() == User && _typeOf<R>() == UserDto) {
      return true;
    }
    if (_typeOf<I>() == UserDto && _typeOf<R>() == NameDto) {
      return true;
    }
    if (_typeOf<I>() == UserDto && _typeOf<R>() == SetterNameDto) {
      return true;
    }
    if (_typeOf<I>() == ListDtoNN && _typeOf<R>() == ListTargetNN) {
      return true;
    }
    if (_typeOf<I>() == ListDtoNN && _typeOf<R>() == ListTargetNullable) {
      return true;
    }
    if (_typeOf<I>() == ListDtoNullable && _typeOf<R>() == ListTargetNullable) {
      return true;
    }
    if (_typeOf<I>() == ListDtoNullable && _typeOf<R>() == ListTargetNN) {
      return true;
    }
    return false;
  }

  R convert<I, R>(I model) {
    if (model is UserDto && _typeOf<R>() == User) {
      return (_mapUserDtoToUser(model) as R);
    }
    if (model is User && _typeOf<R>() == UserDto) {
      return (_mapUserToUserDto(model) as R);
    }
    if (model is UserDto && _typeOf<R>() == NameDto) {
      return (_mapUserDtoToNameDto(model) as R);
    }
    if (model is UserDto && _typeOf<R>() == SetterNameDto) {
      return (_mapUserDtoToSetterNameDto(model) as R);
    }
    if (model is ListDtoNN && _typeOf<R>() == ListTargetNN) {
      return (_mapListDtoNNToListTargetNN(model) as R);
    }
    if (model is ListDtoNN && _typeOf<R>() == ListTargetNullable) {
      return (_mapListDtoNNToListTargetNullable(model) as R);
    }
    if (model is ListDtoNullable && _typeOf<R>() == ListTargetNullable) {
      return (_mapListDtoNullableToListTargetNullable(model) as R);
    }
    if (model is ListDtoNullable && _typeOf<R>() == ListTargetNN) {
      return (_mapListDtoNullableToListTargetNN(model) as R);
    }
    throw Exception('No mapper found for ${model.runtimeType}');
  }

  User _mapUserDtoToUser(UserDto model) {
    // User User({required int id, required String name})
    final result = User(
      id: model.id,
      name: model.name,
    );
    return result;
  }

  UserDto _mapUserToUserDto(User model) {
    // UserDto UserDto({required int id, required String name})
    final result = UserDto(
      id: model.id,
      name: model.name,
    );
    return result;
  }

  NameDto _mapUserDtoToNameDto(UserDto model) {
    // NameDto NameDto(int id, {required String name})
    final result = NameDto(
      model.id,
      name: model.name,
    );
    return result;
  }

  SetterNameDto _mapUserDtoToSetterNameDto(UserDto model) {
    // SetterNameDto SetterNameDto({required String name})
    final result = SetterNameDto(name: model.name);
    result.id = model.id;
    return result;
  }

  ListTargetNN _mapListDtoNNToListTargetNN(ListDtoNN model) {
    // ListTargetNN ListTargetNN({required List<String> names})
    final result = ListTargetNN(names: model.names);
    return result;
  }

  ListTargetNullable _mapListDtoNNToListTargetNullable(ListDtoNN model) {
    // ListTargetNullable ListTargetNullable({required List<String>? names})
    final result = ListTargetNullable(names: model.names);
    return result;
  }

  ListTargetNullable _mapListDtoNullableToListTargetNullable(
      ListDtoNullable model) {
    // ListTargetNullable ListTargetNullable({required List<String>? names})
    final result = ListTargetNullable(names: model.names);
    return result;
  }

  ListTargetNN _mapListDtoNullableToListTargetNN(ListDtoNullable model) {
    // ListTargetNN ListTargetNN({required List<String> names})
    final result = ListTargetNN(names: model.names ?? []);
    return result;
  }
}
