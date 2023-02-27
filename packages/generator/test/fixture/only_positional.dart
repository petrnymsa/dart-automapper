// part of 'input.dart';

// class User {
//   final int id;
//   final String name;

//   User(this.id, this.name);
// }

// class UserDto {
//   final int id;
//   final String name;

//   UserDto(this.id, this.name);
// }

// @AutoMapper(mappers: [
//   AutoMap<UserDto, User>(),
// ])
// @ShouldGenerate('''
//     $convertHeader
//        if(model is UserDto && _typeOf<R>() == User) {
//           return (_mapUserDtoToUser) as R);
//       }
//       $convertMethodException
//     }

//     User _mapUserDtoToUser(UserDto model) {
//       // User User({required int id, required String name})
//       final result = User(
//         model.id,
//         model.name,
//       );
//       return result;
//     }
// ''')
// class OnlyPositional extends $OnlyPositional {}
