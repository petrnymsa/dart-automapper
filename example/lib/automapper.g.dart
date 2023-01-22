// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'automapper.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class $ExampleMapper {
  Type _typeOf<X>() => X;
  R convert<I, R>(I model) {
    if (model is UserDto && _typeOf<R>() == User) {
      return (mapUserDtoToUser(model) as R);
    }
    if (model is User && _typeOf<R>() == UserDto) {
      return (mapUserToUserDto(model) as R);
    }
    if (model is NameDto && _typeOf<R>() == User) {
      return (mapNameDtoToUser(model) as R);
    }
    throw Exception('No mapper found for ${model.runtimeType}');
  }

  User mapUserDtoToUser(UserDto model) {
    throw Exception('Converting UserDto to User');
  }

  UserDto mapUserToUserDto(User model) {
    throw Exception('Converting User to UserDto');
  }

  User mapNameDtoToUser(NameDto model) {
    throw Exception('Converting NameDto to User');
  }
}
