import 'package:automapper/automapper.dart';

part 'automapper.g.dart';

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

@AutoMapper(mappers: [
  AutoMap<UserDto, User>(),
  AutoMap<User, UserDto>(),
  AutoMap<NameDto, User>(),
])
class ExampleMapper extends $ExampleMapper {}
