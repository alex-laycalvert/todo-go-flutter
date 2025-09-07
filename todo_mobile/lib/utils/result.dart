sealed class Result<T, E> {
  const Result();

  factory Result.ok({required T value}) => Ok(value);

  factory Result.err({required E error}) => Err(error);

  T unwrap() {
    if (this case Ok(value: final value)) {
      return value;
    } else {
      throw Exception("Called unwrap on an Err value");
    }
  }
}

final class Ok<T, E> extends Result<T, E> {
  const Ok(this.value);

  final T value;
}

final class Err<T, E> extends Result<T, E> {
  const Err(this.error);

  final E error;
}
