import 'failures.dart';

class ErrorHandler {
  static String mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is CacheFailure) {
      return failure.message;
    } else if (failure is AuthFailure) {
      return failure.message;
    } else if (failure is HealthDataFailure) {
      return failure.message;
    }
    return 'Unexpected Error';
  }
}
