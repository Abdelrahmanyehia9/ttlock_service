import 'dart:async';
import 'dart:math';
import 'package:ttlock_flutter/ttlock.dart';
import 'package:ttlock_upgrade_flutter/ttlock_upgrade.dart' hide TTSuccessCallback;

import 'models/lock_controll_result.dart';
import 'models/ttlock_exception.dart';
import 'models/wifi_scan_result.dart';

class TTLockService {
  TTLockService._();

  static final TTLockService _instance = TTLockService._();

  factory TTLockService() => _instance;

  static TTLockService get instance => _instance;
  String? _lockData;
  String? _lockMac;

  String? get lockData => _lockData;

  String? get lockMac => _lockMac;

  bool get isInitialized => _lockData != null;

  Stream<TTLockScanModel> scanForLocks() {
    final controller = StreamController<TTLockScanModel>();
    TTLock.startScanLock((scanModel) {
      _lockMac = scanModel.lockMac;
      controller.add(scanModel);
    });
    return controller.stream;
  }

  void stopScanning() => TTLock.stopScanLock();

  Future<String> initialize({
    required String lockMac,
    required String lockVersion,
    required bool isInited,
  }) async {
    final completer = Completer<String>();
    final initData = {
      "lockMac": lockMac,
      "lockVersion": lockVersion,
      "isInited": isInited,
    };

    TTLock.initLock(
      initData,
      (lockData) {
        _lockData = lockData;
        _lockMac = lockMac;
        completer.complete(lockData);
      },
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  void setLockData(String lockData, {String? lockMac}) {
    _lockData = lockData;
    if (lockMac != null) _lockMac = lockMac;
  }

  Future<String> generateOneTimePasscode({
    required int validityMinutes,
    int length = 6,
  }) async {
    _ensureInitialized();
    final completer = Completer<String>();
    final passcode = _generateSecurePasscode(length);
    final startTime = DateTime.now().millisecondsSinceEpoch;
    final endTime = startTime + (validityMinutes * 60 * 1000);

    TTLock.createCustomPasscode(
      passcode,
      startTime,
      endTime,
      _lockData!,
      () => completer.complete(passcode),
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<String> createScheduledPasscode({
    required DateTime startDate,
    required DateTime endDate,
    int length = 6,
  }) async {
    _ensureInitialized();
    final completer = Completer<String>();
    final passcode = _generateSecurePasscode(length);

    TTLock.createCustomPasscode(
      passcode,
      startDate.millisecondsSinceEpoch,
      endDate.millisecondsSinceEpoch,
      _lockData!,
      () => completer.complete(passcode),
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<void> createCustomPasscode({
    required String passcode,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _ensureInitialized();
    final completer = Completer<void>();

    TTLock.createCustomPasscode(
      passcode,
      startDate.millisecondsSinceEpoch,
      endDate.millisecondsSinceEpoch,
      _lockData!,
      () => completer.complete(),
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<void> deletePasscode(String passcode) async {
    _ensureInitialized();
    final completer = Completer<void>();

    TTLock.deletePasscode(
      passcode,
      _lockData!,
      () => completer.complete(),
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<void> updatePasscode({
    required String currentPasscode,
    String? newPasscode,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _ensureInitialized();
    final completer = Completer<void>();

    TTLock.modifyPasscode(
      currentPasscode,
      newPasscode,
      startDate.millisecondsSinceEpoch,
      endDate.millisecondsSinceEpoch,
      _lockData!,
      () => completer.complete(),
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<String> resetAllPasscodes() async {
    _ensureInitialized();
    final completer = Completer<String>();

    TTLock.resetPasscode(
      _lockData!,
      (newLockData) {
        _lockData = newLockData;
        completer.complete(newLockData);
      },
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<List<dynamic>> getAllPasscodes() async {
    _ensureInitialized();
    final completer = Completer<List<dynamic>>();

    TTLock.getAllValidPasscode(
      _lockData!,
      (passcodeList) => completer.complete(passcodeList),
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<String> getAdminPasscode() async {
    _ensureInitialized();
    final completer = Completer<String>();

    TTLock.getAdminPasscode(
      _lockData!,
      (adminPasscode) => completer.complete(adminPasscode),
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<void> updateAdminPasscode(String newPasscode) async {
    _ensureInitialized();
    final completer = Completer<void>();

    TTLock.modifyAdminPasscode(
      newPasscode,
      _lockData!,
      () => completer.complete(),
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<LockControlResult> unlock() async {
    _ensureInitialized();
    final completer = Completer<LockControlResult>();

    TTLock.controlLock(
      _lockData!,
      TTControlAction.unlock,
      (lockTime, battery, uniqueId, lockData) {
        _lockData = lockData;
        completer.complete(
          LockControlResult(
            lockTime: lockTime,
            batteryLevel: battery,
            uniqueId: uniqueId,
            lockData: lockData,
          ),
        );
      },
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<LockControlResult> lock() async {
    _ensureInitialized();
    final completer = Completer<LockControlResult>();

    TTLock.controlLock(
      _lockData!,
      TTControlAction.lock,
      (lockTime, battery, uniqueId, lockData) {
        _lockData = lockData;
        completer.complete(
          LockControlResult(
            lockTime: lockTime,
            batteryLevel: battery,
            uniqueId: uniqueId,
            lockData: lockData,
          ),
        );
      },
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<TTLockSwitchState> getLockState() async {
    _ensureInitialized();
    final completer = Completer<TTLockSwitchState>();

    TTLock.getLockSwitchState(
      _lockData!,
      (state) => completer.complete(state),
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<int> getBatteryLevel() async {
    _ensureInitialized();
    final completer = Completer<int>();

    TTLock.getLockPower(
      _lockData!,
      (batteryLevel) => completer.complete(batteryLevel),
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<String> getOperationHistory({
    TTOperateRecordType type = TTOperateRecordType.latest,
  }) async {
    _ensureInitialized();
    final completer = Completer<String>();

    TTLock.getLockOperateRecord(
      type,
      _lockData!,
      (records) => completer.complete(records),
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<TTLockSystemModel> getSystemInfo() async {
    _ensureInitialized();
    final completer = Completer<TTLockSystemModel>();

    TTLock.getLockSystemInfo(
      _lockData!,
      (systemModel) => completer.complete(systemModel),
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<int> getAutoLockTime() async {
    _ensureInitialized();
    final completer = Completer<int>();

    TTLock.getLockAutomaticLockingPeriodicTime(
      _lockData!,
      (currentTime, minTime, maxTime) => completer.complete(currentTime),
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<void> setAutoLockTime(int seconds) async {
    _ensureInitialized();
    final completer = Completer<void>();

    TTLock.setLockAutomaticLockingPeriodicTime(
      seconds,
      _lockData!,
      () => completer.complete(),
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<WifiScanResult> scanWifiNetworks() async {
    _ensureInitialized();
    final completer = Completer<WifiScanResult>();
    final allNetworks = <dynamic>[];

    TTLock.scanWifi(
      _lockData!,
      (finished, wifiList) {
        allNetworks.addAll(wifiList);
        if (finished) {
          completer.complete(
            WifiScanResult(networks: allNetworks, isComplete: true),
          );
        }
      },
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<void> configureWifi({
    required String ssid,
    required String password,
  }) async {
    _ensureInitialized();
    final completer = Completer<void>();

    TTLock.configWifi(
      ssid,
      password,
      _lockData!,
      () => completer.complete(),
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<TTWifiInfoModel> getWifiInfo() async {
    _ensureInitialized();
    final completer = Completer<TTWifiInfoModel>();

    TTLock.getWifiInfo(
      _lockData!,
      (wifiInfo) => completer.complete(wifiInfo),
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<bool> isRemoteUnlockEnabled() async {
    _ensureInitialized();
    final completer = Completer<bool>();

    TTLock.getLockRemoteUnlockSwitchState(
      _lockData!,
      (isEnabled) => completer.complete(isEnabled),
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<String> setRemoteUnlock(bool enable) async {
    _ensureInitialized();
    final completer = Completer<String>();

    TTLock.setLockRemoteUnlockSwitchState(
      enable,
      _lockData!,
      (lockData) {
        _lockData = lockData;
        completer.complete(lockData);
      },
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<TTSoundVolumeType> getSoundVolume() async {
    _ensureInitialized();
    final completer = Completer<TTSoundVolumeType>();

    TTLock.getLockSoundWithSoundVolume(
      _lockData!,
      (volume) => completer.complete(volume),
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<void> setSoundVolume(TTSoundVolumeType volume) async {
    _ensureInitialized();
    final completer = Completer<void>();

    TTLock.setLockSoundWithSoundVolume(
      volume,
      _lockData!,
      () => completer.complete(),
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<String> resetEkey() async {
    _ensureInitialized();
    final completer = Completer<String>();

    TTLock.resetEkey(
      _lockData!,
      (newLockData) {
        _lockData = newLockData;
        completer.complete(newLockData);
      },
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<void> resetLock() async {
    _ensureInitialized();
    final completer = Completer<void>();

    TTLock.resetLock(
      _lockData!,
      () {
        _clearLocalData();
        completer.complete();
      },
      (errorCode, errorMsg) =>
          completer.completeError(TTLockException(errorCode, errorMsg)),
    );

    return completer.future;
  }

  Future<TTBluetoothState> getBluetoothState() async {
    final completer = Completer<TTBluetoothState>();
    TTLock.getBluetoothState((state) => completer.complete(state));
    return completer.future;
  }

  String _generateSecurePasscode(int length) {
    final random = Random.secure();
    const digits = '0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => digits.codeUnitAt(random.nextInt(digits.length)),
      ),
    );
  }

  void _ensureInitialized() {
    if (!isInitialized) {
      throw TTLockException(
        TTLockError.invalidLockData,
        'Lock not initialized',
      );
    }
  }

  void _clearLocalData() {
    _lockData = null;
    _lockMac = null;
  }

  void clearLockData() => _clearLocalData();

  void lockUpgrade({required String firmwarePackage}) {
    if (_lockMac != null && _lockData != null) {
      TtlockUpgrade.startUpgradeLock(
        _lockMac!,
        _lockData!,
        firmwarePackage,
        (status, progress) {},
        (String newLockData) {},
        (errorCode, errorMsg) {},
      );
    }
  }
  void gatewayUpgrade({
  required TTDfuType dfuType,
 required String clientId,
 required String accessToken,
 required int gatewayId,
 required String gatewayMac,
 required TTUpgradeProgressCallback progressCallback,
 required TTSuccessCallback successCallback,
 required TTUpgradeFailedCallback failedCallback}) {
    TtlockUpgrade.startUpgradeGateway(dfuType,  clientId, accessToken, gatewayId, gatewayMac, (status, progress) {

    }, () {
      print("upgrade success");
    }, (errorCode, errorMsg) { }


    ) ;

  }


}
