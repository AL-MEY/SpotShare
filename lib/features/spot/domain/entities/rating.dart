class Rating {
  factory Rating(int value) {
    if (value < min || value > max) {
      throw ArgumentError.value(value, 'value', 'doit être entre $min et $max');
    }
    return Rating._(value);
  }

  const Rating._(this.value);

  static const min = 1;
  static const max = 5;

  final int value;

  @override
  bool operator ==(Object other) => other is Rating && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
