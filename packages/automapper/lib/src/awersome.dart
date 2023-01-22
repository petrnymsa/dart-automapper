class AutoMapper {
  final bool useEquatable;
  final List<AutoMap> mappers;

  const AutoMapper({
    this.useEquatable = false,
    this.mappers = const [],
  });
}

const mapper = AutoMapper();

class AutoMap<A, B> {
  final bool reverse;

  const AutoMap({
    this.reverse = false,
  });
}
