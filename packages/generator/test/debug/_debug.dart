import 'package:automapper/automapper.dart';

class User {
  final int id;
  final String name;

  User({
    required this.id,
    required this.name,
  });
}

class UserDto {
  final int id;
  final String name;

  UserDto({
    required this.id,
    required this.name,
  });
}

class NameDto {
  final String name;

  NameDto({
    required this.name,
  });
}

class UserB {
  final int id;
  final String name;

  UserB.create({
    required this.id,
    required this.name,
  });
}

@AutoMapper(mappers: [
  AutoMap<UserDto, User>(reverse: true, mappings: [
    MapMember(member: 'id', ignore: true),
    MapMember(member: 'name', target: ExampleMapper.mapUserDtoName),
  ]),
  // AutoMap<UserDto, User>(reverse: true),
  //AutoMap<UserDto, User>(reverse: true),
  //AutoMap<NameDto, User>(),
])
abstract class ExampleMapper {
  static String mapUserDtoName(UserDto dto) => dto.name.toUpperCase();
}
