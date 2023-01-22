// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'automapper.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class $ExampleMapper {
  R convert<I, R>(I model) {
    if (model.runtimeType == UserDto && R.runtimeType == User) {
      return (mapUserDtoToUser((model as UserDto)) as R);
    }
    if (model.runtimeType == User && R.runtimeType == UserDto) {
      return (mapUserToUserDto((model as User)) as R);
    }
    if (model.runtimeType == NameDto && R.runtimeType == User) {
      return (mapNameDtoToUser((model as NameDto)) as R);
    }
    throw Exception('No mapper found for ${model.runtimeType}');
  }

  User mapUserDtoToUser(UserDto fromModel) {
    throw Exception('Converting UserDto to User');
  }

  UserDto mapUserToUserDto(User fromModel) {
    throw Exception('Converting User to UserDto');
  }

  User mapNameDtoToUser(NameDto fromModel) {
    throw Exception('Converting NameDto to User');
  }
}
