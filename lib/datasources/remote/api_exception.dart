// Api Error Messages
const String apiFetchData = "Error During Communication: ";
const String apiBadRequest = "Invalid Request: ";
const String apiUnauthorised = "Unauthorised: ";
const String apiInteralServer = "Internal Server Error: ";
const String apiInvalidInput = "Invalid Input:";
const String apiServerTimeout = "Unable to connect to server:";

class ApiException implements Exception {
  final _message;
  final _prefix;

  ApiException([this._message, this._prefix]);

  @override
  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends ApiException {
  FetchDataException([String message]) : super(message, apiFetchData);
}

class BadRequestException extends ApiException {
  BadRequestException([message]) : super(message, apiBadRequest);
}

class UnauthorisedException extends ApiException {
  UnauthorisedException([message]) : super(message, apiUnauthorised);
}

class InternalServerExcepton extends ApiException {
  InternalServerExcepton([message]) : super(message, apiInteralServer);
}

class InvalidInputException extends ApiException {
  InvalidInputException([String message]) : super(message, apiInvalidInput);
}

class ServerTimeoutException extends ApiException {
  ServerTimeoutException([String message]) : super(message, apiServerTimeout);
}
