import 'dart:ffi';

sealed class Result<T>{
}

class Success<R> extends Result<R> {
  final R result;

  Success(this.result);
}

class Error extends Result<Void>{
  final Object? exception;

  Error({this.exception});
}

class Loading extends Result<Void>{

}