

sealed class Result<T> {
  Success<T>? toSuccess() {
    if (this is Success) return this as Success<T>;
    return null;
  }
  Error<T>? toError() {
    if (this is Error) return this as Error<T>;
    return null;
  }
}

class Success<R> extends Result<R> {
  final R result;

  Success(this.result);


}

class Error<R> extends Result<R>{
  final Object? exception;

  Error({this.exception});
}

class Loading<R> extends Result<R>{

}