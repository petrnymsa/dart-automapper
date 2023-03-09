// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../only_positional.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class $Mapper {
  Type _typeOf<X>() => X;
  bool canConvert<I, R>() {
    if (_typeOf<I>() == UserDto && _typeOf<R>() == User) {
      return true;
    }
    return false;
  }

  R convert<I, R>(I model) {
    if (model is UserDto && _typeOf<R>() == User) {
      return (_mapUserDtoToUser(model) as R);
    }
    throw Exception('No mapper found for ${model.runtimeType}');
  }

  User _mapUserDtoToUser(UserDto model) {
    final result = User(
      model.id,
      model.name,
    );
    return result;
  }
}
