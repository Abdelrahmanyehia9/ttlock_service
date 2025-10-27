
---
## ✨ Features

- 🔍 **Bluetooth Lock Scanning** - Discover nearby TTLock devices
- 🔐 **Passcode Management** - Generate OTP, scheduled codes, custom passcodes
- 🔓 **Lock Control** - Unlock/lock remotely via Bluetooth or WiFi
- 📡 **WiFi Configuration** - Connect locks to WiFi networks
- 🔋 **Battery Monitoring** - Check battery levels and get low battery alerts
- 📊 **Operation History** - Track who opened the lock and when
- ⚙️ **Advanced Settings** - Auto-lock, sound volume, remote unlock
- 🚀 **Clean Architecture** - No print statements, proper error handling
- 📦 **Singleton Pattern** - Easy to use throughout your app

---

## 📦 Installation

Add to your `pubspec.yaml`:
```yaml
dependencies:
  ttlock_service:
    git:
      url: https://github.com/Abdelrahmanyehia9/ttlock_service.git
```

Or for local development:
```yaml
dependencies:
  ttlock_service:
    path: ../ttlock_service
```

Install dependencies:
```bash
flutter pub get
```

---

## ⚙️ Setup

### Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
    
    <manifest>
    <uses-permission android:name="android.permission.BLUETOOTH"/>
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN"/>
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>


```

### iOS Permissions

Add to `ios/Runner/Info.plist`:
```xml
NSBluetoothAlwaysUsageDescription
We need Bluetooth to connect to your smart lock

NSBluetoothPeripheralUsageDescription
We need Bluetooth to control your smart lock

NSLocationWhenInUseUsageDescription
Location is required for Bluetooth scanning
```

---

## 🚀 Quick Start

### Initialize Service
```dart
import 'package:ttlock_service/ttlock_service.dart';

final lockService = TTLockService.instance;
```

### Complete Flow Example
```dart
class LockManager {
  final _lockService = TTLockService.instance;
  StreamSubscription? _scanSubscription;

  // 1. Scan for locks
  Future findLock() async {
    final completer = Completer();
    
    _scanSubscription = _lockService.scanForLocks().listen((lock) {
      print('Found: ${lock.lockName} (${lock.lockMac})');
      
      if (!lock.isInited) {
        _lockService.stopScanning();
        completer.complete(lock);
      }
    });

    // Timeout after 15 seconds
    Future.delayed(Duration(seconds: 15), () {
      if (!completer.isCompleted) {
        _lockService.stopScanning();
        completer.complete(null);
      }
    });

    return completer.future;
  }

  // 2. Pair new lock
  Future pairLock(TTLockScanModel lock) async {
    try {
      final lockData = await _lockService.initialize(
        lockMac: lock.lockMac,
        lockVersion: lock.lockVersion,
        isInited: lock.isInited,
      );

      await _saveLockData(lockData, lock.lockMac);
      return true;
    } on TTLockException catch (e) {
      print('Pairing failed: ${e.message}');
      return false;
    }
  }

  // 3. Load saved lock
  Future loadLock() async {
    final prefs = await SharedPreferences.getInstance();
    final lockData = prefs.getString('lock_data');
    final lockMac = prefs.getString('lock_mac');

    if (lockData != null) {
      _lockService.setLockData(lockData, lockMac: lockMac);
    }
  }

  Future _saveLockData(String lockData, String lockMac) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lock_data', lockData);
    await prefs.setString('lock_mac', lockMac);
  }

  void dispose() {
    _scanSubscription?.cancel();
  }
}
```

---

## 📚 Usage Examples

### Passcode Management

#### Generate OTP for Delivery
```dart
Future createDeliveryOTP() async {
  try {
    final otp = await lockService.generateOneTimePasscode(
      validityMinutes: 30,
      length: 6,
    );
    
    print('OTP: $otp (valid for 30 minutes)');
    return otp;
  } on TTLockException catch (e) {
    print('Error: ${e.message}');
    return null;
  }
}
```

#### Create Scheduled Passcode
```dart
Future createScheduledCode() async {
  try {
    final startTime = DateTime.now();
    final endTime = startTime.add(Duration(hours: 24));
    
    final code = await lockService.createScheduledPasscode(
      startDate: startTime,
      endDate: endTime,
      length: 6,
    );
    
    print('Scheduled code: $code');
    return code;
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
```

#### Delete Passcode
```dart
Future deleteCode(String passcode) async {
  try {
    await lockService.deletePasscode(passcode);
    print('Passcode deleted');
  } on TTLockException catch (e) {
    print('Failed to delete: ${e.message}');
  }
}
```

#### Get All Active Passcodes
```dart
Future<List> getActiveCodes() async {
  try {
    final codes = await lockService.getAllPasscodes();
    print('Active passcodes: ${codes.length}');
    return codes;
  } catch (e) {
    print('Error: $e');
    return [];
  }
}
```

### Lock Control

#### Unlock/Lock
```dart
Future unlockBox() async {
  try {
    final result = await lockService.unlock();
    print('Unlocked! Battery: ${result.batteryLevel}%');
    
    if (result.batteryLevel < 20) {
      print('⚠️ Low battery warning!');
    }
  } on TTLockException catch (e) {
    print('Failed to unlock: ${e.message}');
  }
}

Future lockBox() async {
  try {
    final result = await lockService.lock();
    print('Locked! Battery: ${result.batteryLevel}%');
  } catch (e) {
    print('Failed to lock: $e');
  }
}
```

#### Check Lock State
```dart
Future checkStatus() async {
  try {
    final state = await lockService.getLockState();
    
    switch (state) {
      case TTLockSwitchState.lock:
        print('🔒 Locked');
        break;
      case TTLockSwitchState.unlock:
        print('🔓 Unlocked');
        break;
      case TTLockSwitchState.unknown:
        print('❓ Unknown');
        break;
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

#### Auto-Lock Timer
```dart
Future setAutoLock() async {
  try {
    // Auto-lock after 5 seconds
    await lockService.setAutoLockTime(5);
    print('Auto-lock set to 5 seconds');
  } catch (e) {
    print('Error: $e');
  }
}

Future getAutoLockTime() async {
  try {
    final seconds = await lockService.getAutoLockTime();
    print('Auto-lock time: $seconds seconds');
  } catch (e) {
    print('Error: $e');
  }
}
```

### Monitoring

#### Battery Level
```dart
Future checkBattery() async {
  try {
    final battery = await lockService.getBatteryLevel();
    print('🔋 Battery: $battery%');
    
    if (battery < 20) {
      await sendLowBatteryAlert();
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

#### Operation History
```dart
Future getHistory() async {
  try {
    final records = await lockService.getOperationHistory(
      type: TTOperateRecordType.latest,
    );
    
    print('Operation logs: $records');
    // Parse JSON to display who opened the lock
  } catch (e) {
    print('Error: $e');
  }
}
```

#### System Information
```dart
Future getLockInfo() async {
  try {
    final info = await lockService.getSystemInfo();
    
    print('Model: ${info.modelNum}');
    print('Firmware: ${info.firmwareRevision}');
    print('Hardware: ${info.hardwareRevision}');
    print('Battery: ${info.electricQuantity}%');
  } catch (e) {
    print('Error: $e');
  }
}
```

### WiFi Configuration (WiFi Locks Only)

#### Scan WiFi Networks
```dart
Future scanWifi() async {
  try {
    final result = await lockService.scanWifiNetworks();
    
    for (var network in result.networks) {
      print('SSID: ${network['ssid']}');
      print('Signal: ${network['rssi']} dBm');
    }
  } catch (e) {
    print('WiFi scan failed: $e');
  }
}
```

#### Connect to WiFi
```dart
Future connectToWifi() async {
  try {
    await lockService.configureWifi(
      ssid: 'MyWiFi',
      password: 'password123',
    );
    
    print('✅ WiFi configured successfully');
  } on TTLockException catch (e) {
    if (e.errorCode == TTLockError.wrongWifi) {
      print('Invalid WiFi network');
    } else if (e.errorCode == TTLockError.wrongWifiPassword) {
      print('Wrong password');
    } else {
      print('Error: ${e.message}');
    }
  }
}
```

#### Get WiFi Info
```dart
Future getWifiStatus() async {
  try {
    final info = await lockService.getWifiInfo();
    print('WiFi MAC: ${info.wifiMac}');
    print('Signal: ${info.wifiRssi} dBm');
  } catch (e) {
    print('Error: $e');
  }
}
```

#### Enable/Disable Remote Unlock
```dart
Future toggleRemoteUnlock(bool enable) async {
  try {
    await lockService.setRemoteUnlock(enable);
    print('Remote unlock ${enable ? "enabled" : "disabled"}');
  } catch (e) {
    print('Error: $e');
  }
}

Future checkRemoteUnlock() async {
  try {
    return await lockService.isRemoteUnlockEnabled();
  } catch (e) {
    print('Error: $e');
    return false;
  }
}
```

### Sound Settings
```dart
Future setSoundVolume() async {
  try {
    await lockService.setSoundVolume(
      TTSoundVolumeType.thirdLevel, // 1-5 or off
    );
    print('Volume set');
  } catch (e) {
    print('Error: $e');
  }
}

Future getSoundVolume() async {
  try {
    final volume = await lockService.getSoundVolume();
    print('Current volume: ${volume.name}');
  } catch (e) {
    print('Error: $e');
  }
}
```

### Maintenance

#### Reset Lock
```dart
Future resetToFactory() async {
  try {
    await lockService.resetLock();
    print('✅ Lock reset to factory settings');
    // lockData is now cleared
  } catch (e) {
    print('Reset failed: $e');
  }
}
```

#### Update Admin Passcode
```dart
Future changeAdminCode() async {
  try {
    await lockService.updateAdminPasscode('654321');
    print('Admin passcode updated');
  } catch (e) {
    print('Error: $e');
  }
}
```

#### Get Admin Passcode
```dart
Future getAdminCode() async {
  try {
    return await lockService.getAdminPasscode();
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
```

---

## 📖 API Reference

### Core Methods

| Method | Description | Returns |
|--------|-------------|---------|
| `scanForLocks()` | Start scanning for nearby locks | `Stream<TTLockScanModel>` |
| `stopScanning()` | Stop scanning | `void` |
| `initialize()` | Pair new lock | `Future<String>` |
| `setLockData()` | Load saved lock data | `void` |
| `clearLockData()` | Clear lock data | `void` |

### Passcode Management

| Method | Description | Returns |
|--------|-------------|---------|
| `generateOneTimePasscode()` | Create OTP | `Future<String>` |
| `createScheduledPasscode()` | Create scheduled code | `Future<String>` |
| `createCustomPasscode()` | Create custom code | `Future<void>` |
| `deletePasscode()` | Delete specific code | `Future<void>` |
| `updatePasscode()` | Modify existing code | `Future<void>` |
| `resetAllPasscodes()` | Delete all codes (except admin) | `Future<String>` |
| `getAllPasscodes()` | Get all active codes | `Future<List<dynamic>>` |
| `getAdminPasscode()` | Get admin code | `Future<String>` |
| `updateAdminPasscode()` | Change admin code | `Future<void>` |

### Lock Control

| Method | Description | Returns |
|--------|-------------|---------|
| `unlock()` | Unlock the lock | `Future<LockControlResult>` |
| `lock()` | Lock the lock | `Future<LockControlResult>` |
| `getLockState()` | Get current state | `Future<TTLockSwitchState>` |
| `setAutoLockTime()` | Set auto-lock timer | `Future<void>` |
| `getAutoLockTime()` | Get auto-lock timer | `Future<int>` |

### Monitoring

| Method | Description | Returns |
|--------|-------------|---------|
| `getBatteryLevel()` | Get battery percentage | `Future<int>` |
| `getOperationHistory()` | Get operation logs | `Future<String>` |
| `getSystemInfo()` | Get system information | `Future<TTLockSystemModel>` |

### WiFi Configuration

| Method | Description | Returns |
|--------|-------------|---------|
| `scanWifiNetworks()` | Scan available networks | `Future<WifiScanResult>` |
| `configureWifi()` | Connect to WiFi | `Future<void>` |
| `getWifiInfo()` | Get WiFi status | `Future<TTWifiInfoModel>` |
| `isRemoteUnlockEnabled()` | Check remote unlock status | `Future<bool>` |
| `setRemoteUnlock()` | Enable/disable remote unlock | `Future<String>` |

### Sound Settings

| Method | Description | Returns |
|--------|-------------|---------|
| `getSoundVolume()` | Get current volume | `Future<TTSoundVolumeType>` |
| `setSoundVolume()` | Set volume level | `Future<void>` |

### Maintenance

| Method | Description | Returns |
|--------|-------------|---------|
| `resetLock()` | Factory reset | `Future<void>` |
| `resetEkey()` | Reset electronic keys | `Future<String>` |
| `getBluetoothState()` | Get Bluetooth status | `Future<TTBluetoothState>` |
| `lockUpgrade()` | Upgrade lock firmware | `void` |
| `gatewayUpgrade()` | Upgrade gateway firmware | `void` |

---

## ⚠️ Error Handling

### Exception Types
```dart
try {
  await lockService.unlock();
} on TTLockException catch (e) {
  switch (e.errorCode) {
    case TTLockError.bluetoothOff:
      print('Please enable Bluetooth');
      break;
    case TTLockError.bluetoothConnectTimeout:
      print('Connection timeout - move closer to lock');
      break;
    case TTLockError.lockIsBusy:
      print('Lock is busy - please wait');
      break;
    case TTLockError.wrongWifiPassword:
      print('Incorrect WiFi password');
      break;
    case TTLockError.invalidLockData:
      print('Lock not initialized');
      break;
    default:
      print('Error: ${e.message}');
  }
}
```

### Common Error Codes

| Error Code | Description | Solution |
|------------|-------------|----------|
| `bluetoothOff` | Bluetooth is disabled | Enable Bluetooth |
| `bluetoothConnectTimeout` | Connection timeout | Move closer to lock |
| `lockIsBusy` | Lock is processing another command | Wait and retry |
| `invalidLockData` | Lock not initialized | Call `setLockData()` first |
| `wrongWifiPassword` | Incorrect WiFi password | Check credentials |
| `noPermission` | No admin permission | Must be lock owner |

---

## 💡 Best Practices

### 1. Always Check Initialization
```dart
if (!lockService.isInitialized) {
  await loadSavedLock();
}
```

### 2. Handle Bluetooth State
```dart
final bluetoothState = await lockService.getBluetoothState();
if (bluetoothState != TTBluetoothState.turnOn) {
  showDialog('Please enable Bluetooth');
  return;
}
```

### 3. Secure lockData Storage
```dart
// Use flutter_secure_storage for production
final storage = FlutterSecureStorage();
await storage.write(key: 'lock_data', value: lockData);
```

### 4. Timeout Scans
```dart
_scanSubscription = lockService.scanForLocks().listen(onLockFound);

Future.delayed(Duration(seconds: 15), () {
  lockService.stopScanning();
  _scanSubscription?.cancel();
});
```

### 5. Battery Monitoring
```dart
final result = await lockService.unlock();

if (result.batteryLevel < 20) {
  showNotification('Low battery: ${result.batteryLevel}%');
}
```

### 6. Filter Scans by MAC Address
```dart
final myLockMac = 'AA:BB:CC:DD:EE:FF';

lockService.scanForLocks().listen((lock) {
  if (lock.lockMac == myLockMac) {
    lockService.stopScanning();
    // Connect to this lock
  }
});
```

---

## 🔧 Troubleshooting

### Lock Not Found During Scan

**Causes:**
- Lock is out of Bluetooth range (>10m)
- Lock battery is dead
- Bluetooth is disabled
- Missing location permissions

**Solutions:**
```dart
// 1. Check Bluetooth
final state = await lockService.getBluetoothState();
if (state != TTBluetoothState.turnOn) {
  // Enable Bluetooth
}

// 2. Request permissions
await Permission.bluetoothScan.request();
await Permission.location.request();

// 3. Increase scan time
Future.delayed(Duration(seconds: 30), () {
  lockService.stopScanning();
});
```

### Connection Timeout

**Causes:**
- Too far from lock
- Lock is busy
- Interference

**Solutions:**
```dart
try {
  await lockService.unlock();
} on TTLockException catch (e) {
  if (e.errorCode == TTLockError.bluetoothConnectTimeout) {
    // Retry after delay
    await Future.delayed(Duration(seconds: 2));
    await lockService.unlock();
  }
}
```

### Lock Already Paired

**Solution:**
```dart
if (scannedLock.isInited) {
  print('Lock is already paired with another device');
  print('Please reset lock physically or use reset code');
}
```

### WiFi Configuration Fails

**Solutions:**
```dart
try {
  await lockService.configureWifi(
    ssid: wifiName,
    password: wifiPassword,
  );
} on TTLockException catch (e) {
  if (e.errorCode == TTLockError.wrongWifi) {
    print('WiFi network not found - check SSID');
  } else if (e.errorCode == TTLockError.wrongWifiPassword) {
    print('Incorrect password');
  }
}
```

---

## 📱 Complete Example - Smart Parcel Box
```dart
import 'package:flutter/material.dart';
import 'package:ttlock_service/ttlock_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParcelBoxManager {
  final _lockService = TTLockService.instance;
  StreamSubscription? _scanSubscription;

  Future initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final lockData = prefs.getString('lock_data');
    final lockMac = prefs.getString('lock_mac');

    if (lockData != null) {
      _lockService.setLockData(lockData, lockMac: lockMac);
    }
  }

  Future pairNewLock() async {
    final completer = Completer();

    _scanSubscription = _lockService.scanForLocks().listen((lock) {
      if (!lock.isInited) {
        _lockService.stopScanning();
        _pairLock(lock).then((success) => completer.complete(success));
      }
    });

    Future.delayed(Duration(seconds: 15), () {
      if (!completer.isCompleted) {
        _lockService.stopScanning();
        completer.complete(false);
      }
    });

    return completer.future;
  }

  Future _pairLock(TTLockScanModel lock) async {
    try {
      final lockData = await _lockService.initialize(
        lockMac: lock.lockMac,
        lockVersion: lock.lockVersion,
        isInited: lock.isInited,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lock_data', lockData);
      await prefs.setString('lock_mac', lock.lockMac);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future createDeliveryCode() async {
    try {
      return await _lockService.generateOneTimePasscode(
        validityMinutes: 30,
        length: 6,
      );
    } catch (e) {
      return null;
    }
  }

  Future deleteCode(String code) async {
    try {
      await _lockService.deletePasscode(code);
    } catch (e) {
      // Handle error
    }
  }

  Future unlockBox() async {
    try {
      final result = await _lockService.unlock();
      
      if (result.batteryLevel < 20) {
        _sendLowBatteryAlert(result.batteryLevel);
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future lockBox() async {
    try {
      await _lockService.lock();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future getStatus() async {
    try {
      final state = await _lockService.getLockState();
      final battery = await _lockService.getBatteryLevel();

      return BoxStatus(
        isLocked: state == TTLockSwitchState.lock,
        batteryLevel: battery,
      );
    } catch (e) {
      return BoxStatus(isLocked: false, batteryLevel: 0);
    }
  }

  void _sendLowBatteryAlert(int battery) {
    // Send notification
    print('⚠️ Low battery: $battery%');
  }

  void dispose() {
    _scanSubscription?.cancel();
  }
}

class BoxStatus {
  final bool isLocked;
  final int batteryLevel;

  BoxStatus({required this.isLocked, required this.batteryLevel});
}
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---


---

## 🔗 Links

- [GitHub Repository](https://github.com/Abdelrahmanyehia9/ttlock_service)

---

## 📧 Support

For issues and questions:
- Open an issue on [GitHub](https://github.com/Abdelrahmanyehia9/ttlock_service/issues)
---

## ⭐ Show Your Support

Give a ⭐️ if this project helped you!

---

Made with ❤️ by [Abdelrahman Yehia](https://github.com/Abdelrahmanyehia9)
