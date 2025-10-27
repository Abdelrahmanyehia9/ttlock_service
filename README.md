# ttlock_service

A Flutter package for seamless integration with TTLock smart lock systems. This package provides a high-level API to control TTLock devices, enabling features like lock scanning, passcode management, unlocking/locking, WiFi configuration, and firmware upgrades. It simplifies interactions with TTLock hardware, making it ideal for IoT, home automation, or hospitality apps.

## Features

- **Lock Scanning**: Discover nearby TTLock devices via a stream-based API.
- **Lock Initialization**: Initialize locks with MAC address and version details.
- **Passcode Management**:
  - Generate one-time or scheduled passcodes with customizable validity.
  - Create, update, delete, or retrieve passcodes.
  - Reset all passcodes or manage admin passcodes.
- **Lock Control**: Unlock or lock devices with battery and timestamp feedback.
- **State Queries**: Retrieve lock state, battery level, operation history, system info, and auto-lock settings.
- **WiFi Integration**: Scan for WiFi networks, configure lock WiFi, and retrieve WiFi info.
- **Remote Features**: Enable/disable remote unlock and adjust lock sound volume.
- **Reset Operations**: Reset eKeys or the entire lock.
- **Firmware Upgrades**: Support for lock and gateway firmware updates.
- **Robust Error Handling**: Custom exceptions with TTLock-specific error codes.

## Getting Started

iOS: 
1. In XCode,Add Key`Privacy - Bluetooth Peripheral Usage Description` Value `your description for bluetooth` to your project's `info` ➜ `Custom iOS Target Projectes`

Android:
AndroidManifest.xml configuration:
1. add 'xmlns:tools="http://schemas.android.com/tools"' to <manifest> element
2. add 'tools:replace="android:label"' to <application> element
3. additional permissions:
```  
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```
4. in MainActivity extends FlutterActivity, you need add permissions result to ttlock plugin. 
       
first add import

```
import com.ttlock.ttlock_flutter.TtlockFlutterPlugin
```

second add below callback code:   
java code:

```
@Override
public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        TtlockFlutterPlugin ttlockflutterpluginPlugin = (TtlockFlutterPlugin) getFlutterEngine().getPlugins().get(TtlockFlutterPlugin.class);
        if (ttlockflutterpluginPlugin != null) {
            ttlockflutterpluginPlugin.onRequestPermissionsResult(requestCode, permissions, grantResults);
        }
    }
```
kotlin code:
```
override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        val ttlockflutterpluginPlugin = flutterEngine!!.plugins[TtlockFlutterPlugin::class.java] as TtlockFlutterPlugin?
        ttlockflutterpluginPlugin?.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }
```

5.you need config buildTypes in build.gradle file.like this:

```
    buildTypes {
        release {
            minifyEnabled false
            shrinkResources false
        }
    }

### Prerequisites
- Flutter SDK: `>=1.17.0`
- Dart SDK: `^3.9.2`


### Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  ttlock_service:
    git:
      url: https://github.com/Abdelrahmanyehia9/ttlock_service.git
