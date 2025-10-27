import 'package:ttlock_flutter/ttlock.dart';

class TTLockException implements Exception {
  final TTLockError errorCode;
  final String message;

  const TTLockException(this.errorCode, this.message);

  @override
  String toString() => 'TTLockException: ${errorCode.name} - $message';
}