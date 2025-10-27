class LockControlResult {
  final int lockTime;
  final int batteryLevel;
  final int uniqueId;
  final String lockData;

  const LockControlResult({
    required this.lockTime,
    required this.batteryLevel,
    required this.uniqueId,
    required this.lockData,
  });
}
