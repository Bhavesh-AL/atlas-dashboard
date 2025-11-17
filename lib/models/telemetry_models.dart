import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

// --- HELPER FUNCTION ---
// This is the most important fix to prevent runtime type errors from Firebase.
Map<String, dynamic> safeMapCast(dynamic map) {
  if (map == null) return {};
  final result = <String, dynamic>{};
  if (map is Map) {
    map.forEach((key, value) {
      if (key is String) {
        result[key] = value;
      }
    });
  }
  return result;
}

// --- BASE MODELS (Nested Data) ---

class AppInfo extends Equatable {
  final String packageName;
  final String versionName;
  final int threadCount;
  final DateTime firstInstallTime;

  const AppInfo({
    required this.packageName,
    required this.versionName,
    required this.threadCount,
    required this.firstInstallTime,
  });

  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      packageName: json['package_name'] as String? ?? 'N/A',
      versionName: json['version_name'] as String? ?? 'N/A',
      threadCount: json['thread_count'] as int? ?? 0,
      firstInstallTime: DateTime.fromMillisecondsSinceEpoch(
          json['first_install_time'] as int? ?? 0),
    );
  }
  @override
  List<Object> get props => [packageName, versionName, threadCount, firstInstallTime];
}

class AppStorage extends Equatable {
  final int appCacheBytes;
  final int appDataBytes;
  final int appTotalBytes;

  const AppStorage({
    required this.appCacheBytes,
    required this.appDataBytes,
    required this.appTotalBytes,
  });

  factory AppStorage.fromJson(Map<String, dynamic> json) {
    return AppStorage(
      appCacheBytes: json['app_cache_bytes'] as int? ?? 0,
      appDataBytes: json['app_data_bytes'] as int? ?? 0,
      appTotalBytes: json['app_total_bytes'] as int? ?? 0,
    );
  }
  @override
  List<Object> get props => [appCacheBytes, appDataBytes, appTotalBytes];
}

class BatteryInfo extends Equatable {
  final int capacityPercent;
  final double temperatureC;
  final String health;
  final int voltage;

  const BatteryInfo({
    required this.capacityPercent,
    required this.temperatureC,
    required this.health,
    required this.voltage,
  });

  factory BatteryInfo.fromJson(Map<String, dynamic> json) {
    return BatteryInfo(
      capacityPercent: json['capacity_percent'] as int? ?? 0,
      temperatureC: (json['battery_temp_c'] as num? ?? 0.0).toDouble(),
      health: json['health'] as String? ?? 'N/A',
      voltage: json['voltage'] as int? ?? 0,
    );
  }
  @override
  List<Object> get props => [capacityPercent, temperatureC, health, voltage];
}

class CpuInfo extends Equatable {
  final int coreCount;
  final List<Map<String, dynamic>> cores;

  const CpuInfo({required this.coreCount, required this.cores});

  factory CpuInfo.fromJson(Map<String, dynamic> json) {
    return CpuInfo(
      coreCount: json['logical_core_count'] as int? ?? 0,
      cores: (json['cores'] as List<dynamic>?)
          ?.map((core) => safeMapCast(core))
          .toList() ??
          [],
    );
  }
  @override
  List<Object> get props => [coreCount, cores];
}

class NetworkUsage extends Equatable {
  final String totalRxHuman;
  final String totalTxHuman;
  final int totalRxBytes;
  final int totalTxBytes;

  const NetworkUsage({
    required this.totalRxHuman,
    required this.totalTxHuman,
    required this.totalRxBytes,
    required this.totalTxBytes,
  });

  factory NetworkUsage.fromJson(Map<String, dynamic> json) {
    return NetworkUsage(
      totalRxHuman: json['total_rx_human'] as String? ?? '0 B',
      totalTxHuman: json['total_tx_human'] as String? ?? '0 B',
      totalRxBytes: json['total_rx_bytes'] as int? ?? 0,
      totalTxBytes: json['total_tx_bytes'] as int? ?? 0,
    );
  }
  @override
  List<Object> get props => [totalRxHuman, totalTxHuman, totalRxBytes, totalTxBytes];
}

class BuildInfo extends Equatable {
  final String release;
  final int sdkInt;
  final String socModel;
  final String manufacturer;
  final String socManufacturer;
  final String model;
  final String brand;

  const BuildInfo({
    required this.release,
    required this.sdkInt,
    required this.socModel,
    required this.manufacturer,
    required this.socManufacturer,
    required this.model,
    required this.brand,
  });

  factory BuildInfo.fromJson(Map<String, dynamic> json) {
    return BuildInfo(
      release: json['release'] as String? ?? 'N/A',
      sdkInt: json['sdk_int'] as int? ?? 0,
      socModel: json['soc_model'] as String? ?? 'N/A',
      manufacturer: json['manufacturer'] as String? ?? 'N/A',
      socManufacturer: json['soc_manufacturer'] as String? ?? 'N/A',
      model: json['model'] as String? ?? 'N/A',
      brand: json['brand'] as String? ?? 'N/A',
    );
  }
  @override
  List<Object> get props => [release, sdkInt, socModel, manufacturer, socManufacturer, model, brand];
}

class GpuInfo extends Equatable {
  final String eglRenderer;
  final String eglVendor;
  final String eglVersion;

  const GpuInfo({required this.eglRenderer, required this.eglVendor, required this.eglVersion});

  factory GpuInfo.fromJson(Map<String, dynamic> json) {
    return GpuInfo(
      eglRenderer: json['egl_renderer'] as String? ?? 'N/A',
      eglVendor: json['egl_vendor'] as String? ?? 'N/A',
      eglVersion: json['egl_version'] as String? ?? 'N/A',
    );
  }
  @override
  List<Object> get props => [eglRenderer, eglVendor, eglVersion];
}

class MemoryInfo extends Equatable {
  final int totalMem;
  final int availMem;

  const MemoryInfo({required this.totalMem, required this.availMem});

  factory MemoryInfo.fromJson(Map<String, dynamic> json) {
    return MemoryInfo(
      totalMem: json['totalMem'] as int? ?? 0,
      availMem: json['availMem'] as int? ?? 0,
    );
  }
  @override
  List<Object> get props => [totalMem, availMem];
}

class WifiInfo extends Equatable {
  final int linkSpeedMbps;
  final int rssiDbm;
  final String ssid;
  final String bssid;
  final String ipAddress;
  final bool enabled;

  const WifiInfo({
    required this.linkSpeedMbps,
    required this.rssiDbm,
    required this.ssid,
    required this.bssid,
    required this.ipAddress,
    required this.enabled,
  });

  factory WifiInfo.fromJson(Map<String, dynamic> json) {
    return WifiInfo(
      linkSpeedMbps: json['link_speed_mbps'] as int? ?? 0,
      rssiDbm: json['rssi_dbm'] as int? ?? 0,
      ssid: json['ssid'] as String? ?? 'N/A',
      bssid: json['bssid'] as String? ?? 'N/A',
      ipAddress: json['ip_address'] as String? ?? 'N/A',
      enabled: json['enabled'] as bool? ?? false,
    );
  }
  @override
  List<Object> get props => [linkSpeedMbps, rssiDbm, ssid, bssid, ipAddress, enabled];
}

class PermissionInfo extends Equatable {
  final List<String> grantedPermissions;
  final List<String> deniedPermissions;

  const PermissionInfo({required this.grantedPermissions, required this.deniedPermissions});

  factory PermissionInfo.fromJson(Map<String, dynamic> json) {
    return PermissionInfo(
      grantedPermissions: List<String>.from(json['granted_permissions'] as List? ?? []),
      deniedPermissions: List<String>.from(json['denied_permissions'] as List? ?? []),
    );
  }
  @override
  List<Object> get props => [grantedPermissions, deniedPermissions];
}

class SystemSettings extends Equatable {
  final bool usbDebuggingEnabled;
  final bool airplaneModeEnabled;
  final bool autoRotateEnabled;
  final bool batterySaverEnabled;
  final bool darkModeEnabled;

  const SystemSettings({
    required this.usbDebuggingEnabled,
    required this.airplaneModeEnabled,
    required this.autoRotateEnabled,
    required this.batterySaverEnabled,
    required this.darkModeEnabled,
  });

  factory SystemSettings.fromJson(Map<String, dynamic> json) {
    return SystemSettings(
      usbDebuggingEnabled: json['usb_debugging_enabled'] as bool? ?? false,
      airplaneModeEnabled: json['airplane_mode_enabled'] as bool? ?? false,
      autoRotateEnabled: json['auto_rotate_enabled'] as bool? ?? false,
      batterySaverEnabled: json['battery_saver_enabled'] as bool? ?? false,
      darkModeEnabled: json['dark_mode_enabled'] as bool? ?? false,
    );
  }
  @override
  List<Object> get props => [usbDebuggingEnabled, airplaneModeEnabled, autoRotateEnabled, batterySaverEnabled, darkModeEnabled];
}

class RootDetection extends Equatable {
  final bool isRooted;

  const RootDetection({required this.isRooted});

  factory RootDetection.fromJson(Map<String, dynamic> json) {
    return RootDetection(
      isRooted: json['is_rooted'] as bool? ?? false,
    );
  }
  @override
  List<Object> get props => [isRooted];
}

class SecurityInfo extends Equatable {
  final RootDetection rootDetection;

  const SecurityInfo({required this.rootDetection});

  factory SecurityInfo.fromJson(Map<String, dynamic> json) {
    return SecurityInfo(
      rootDetection: RootDetection.fromJson(safeMapCast(json['root_detection'])),
    );
  }
  @override
  List<Object> get props => [rootDetection];
}

class InstalledPackages extends Equatable {
  final int systemAppCount;
  final int userAppCount;
  final List<String> systemApplications;
  final List<String> userApplications;

  const InstalledPackages({
    required this.systemAppCount,
    required this.userAppCount,
    required this.systemApplications,
    required this.userApplications,
  });

  factory InstalledPackages.fromJson(Map<String, dynamic> json) {
    return InstalledPackages(
      systemAppCount: json['system_app_count'] as int? ?? 0,
      userAppCount: json['user_app_count'] as int? ?? 0,
      systemApplications: List<String>.from(json['system_applications'] as List? ?? []),
      userApplications: List<String>.from(json['user_applications'] as List? ?? []),
    );
  }
  @override
  List<Object> get props => [systemAppCount, userAppCount, systemApplications, userApplications];
}

class Sensor extends Equatable {
  final String name;
  final String vendor;
  final int type;
  final double power;

  const Sensor({
    required this.name,
    required this.vendor,
    required this.type,
    required this.power,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      name: json['name'] as String? ?? 'N/A',
      vendor: json['vendor'] as String? ?? 'N/A',
      type: json['type'] as int? ?? 0,
      power: (json['power'] as num? ?? 0.0).toDouble(),
    );
  }
  @override
  List<Object> get props => [name, vendor, type, power];
}

class SensorInfo extends Equatable {
  final List<Sensor> sensorList;
  final Map<String, dynamic> currentReadings;

  const SensorInfo({
    required this.sensorList,
    required this.currentReadings,
  });

  factory SensorInfo.fromJson(Map<String, dynamic> json) {
    return SensorInfo(
      sensorList: (json['sensor_list'] as List<dynamic>?)
          ?.map((sensor) => Sensor.fromJson(safeMapCast(sensor)))
          .toList() ?? [],
      currentReadings: safeMapCast(json['current_readings']),
    );
  }
  @override
  List<Object> get props => [sensorList, currentReadings];
}

class Codec extends Equatable {
  final String name;
  final List<String> supportedTypes;

  const Codec({required this.name, required this.supportedTypes});

  factory Codec.fromJson(Map<String, dynamic> json) {
    return Codec(
      name: json['name'] as String? ?? 'N/A',
      supportedTypes: List<String>.from(json['supported_types'] as List? ?? []),
    );
  }
  @override
  List<Object> get props => [name, supportedTypes];
}

class MediaCodecs extends Equatable {
  final List<Codec> decoders;
  final List<Codec> encoders;

  const MediaCodecs({required this.decoders, required this.encoders});

  factory MediaCodecs.fromJson(Map<String, dynamic> json) {
    return MediaCodecs(
      decoders: (json['decoders'] as List<dynamic>?)
          ?.map((codec) => Codec.fromJson(safeMapCast(codec)))
          .toList() ?? [],
      encoders: (json['encoders'] as List<dynamic>?)
          ?.map((codec) => Codec.fromJson(safeMapCast(codec)))
          .toList() ?? [],
    );
  }
  @override
  List<Object> get props => [decoders, encoders];
}

class DisplayInfo extends Equatable {
  final int height;
  final int width;
  final int dpi;
  final double refreshRate;

  const DisplayInfo({
    required this.height,
    required this.width,
    required this.dpi,
    required this.refreshRate,
  });

  factory DisplayInfo.fromJson(Map<String, dynamic> json) {
    return DisplayInfo(
      height: json['height_pixels'] as int? ?? 0,
      width: json['width_pixels'] as int? ?? 0,
      dpi: json['density_dpi'] as int? ?? 0,
      refreshRate: (json['current_refresh_rate_hz'] as num? ?? 0.0).toDouble(),
    );
  }
  @override
  List<Object> get props => [height, width, dpi, refreshRate];
}

class AppsMemoryInfo extends Equatable {
  final List<Map<String, dynamic>> processes;
  const AppsMemoryInfo({required this.processes});

  factory AppsMemoryInfo.fromJson(Map<String, dynamic> json) {
    return AppsMemoryInfo(
      processes: (json['processes'] as List<dynamic>?)
          ?.map((p) => safeMapCast(p))
          .toList() ?? [],
    );
  }

  int get totalPssKb {
    if (processes.isEmpty) return 0;
    return processes.first['totalPssKb'] as int? ?? 0;
  }

  @override
  List<Object> get props => [processes];
}

class BluetoothInfo extends Equatable {
  final bool enabled;
  final bool supported;
  final List<Map<String, dynamic>> bondedDevices;

  const BluetoothInfo({required this.enabled, required this.supported, required this.bondedDevices});

  factory BluetoothInfo.fromJson(Map<String, dynamic> json) {
    return BluetoothInfo(
      enabled: json['enabled'] as bool? ?? false,
      supported: json['supported'] as bool? ?? false,
      bondedDevices: (json['bonded_devices'] as List<dynamic>?)
          ?.map((d) => safeMapCast(d))
          .toList() ?? [],
    );
  }
  @override
  List<Object> get props => [enabled, supported, bondedDevices];
}

class CellularInfo extends Equatable {
  final String carrier;
  final List<Map<String, dynamic>> cells;

  const CellularInfo({required this.carrier, required this.cells});

  factory CellularInfo.fromJson(Map<String, dynamic> json) {
    return CellularInfo(
      carrier: json['carrier'] as String? ?? 'N/A',
      cells: (json['cells'] as List<dynamic>?)
          ?.map((c) => safeMapCast(c))
          .toList() ?? [],
    );
  }
  @override
  List<Object> get props => [carrier, cells];
}

class DeviceStorageInfo extends Equatable {
  final int availableBytes;
  final int totalBytes;
  final String path;

  const DeviceStorageInfo({required this.availableBytes, required this.totalBytes, required this.path});

  factory DeviceStorageInfo.fromJson(Map<String, dynamic> json) {
    final dataDir = safeMapCast(json['data_dir']);
    return DeviceStorageInfo(
      availableBytes: dataDir['available_bytes'] as int? ?? 0,
      totalBytes: dataDir['total_bytes'] as int? ?? 0,
      path: dataDir['path'] as String? ?? '/data',
    );
  }

  double get percentUsed => (totalBytes == 0) ? 0.0 : (1.0 - (availableBytes / totalBytes));

  @override
  List<Object> get props => [availableBytes, totalBytes, path];
}

class NfcInfo extends Equatable {
  final bool hardwareSupported;
  final bool isEnabled;

  const NfcInfo({required this.hardwareSupported, required this.isEnabled});

  factory NfcInfo.fromJson(Map<String, dynamic> json) {
    return NfcInfo(
      hardwareSupported: json['hardware_supported'] as bool? ?? false,
      isEnabled: json['is_enabled'] as bool? ?? false,
    );
  }
  @override
  List<Object> get props => [hardwareSupported, isEnabled];
}

class VpnInfo extends Equatable {
  final bool isVpnActive;

  const VpnInfo({required this.isVpnActive});

  factory VpnInfo.fromJson(Map<String, dynamic> json) {
    return VpnInfo(
      isVpnActive: json['is_vpn_active'] as bool? ?? false,
    );
  }
  @override
  List<Object> get props => [isVpnActive];
}

class SimInfo extends Equatable {
  final String simCountryIso;
  final String simOperatorName;

  const SimInfo({required this.simCountryIso, required this.simOperatorName});

  factory SimInfo.fromJson(Map<String, dynamic> json) {
    return SimInfo(
      simCountryIso: json['sim_country_iso'] as String? ?? 'N/A',
      simOperatorName: json['sim_operator_name'] as String? ?? 'N/A',
    );
  }
  @override
  List<Object> get props => [simCountryIso, simOperatorName];
}

class LocationInfo extends Equatable {
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy;
  final String reason;

  const LocationInfo({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    required this.reason,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      latitude: (json['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (json['longitude'] as num? ?? 0.0).toDouble(),
      altitude: (json['altitude'] as num? ?? 0.0).toDouble(),
      accuracy: (json['accuracy_meters'] as num? ?? 0.0).toDouble(),
      reason: json['reason'] as String? ?? '',
    );
  }
  bool get hasData => reason.isEmpty;
  @override
  List<Object> get props => [latitude, longitude, altitude, accuracy, reason];
}

class AudioInfo extends Equatable {
  final String ringerMode;
  final Map<String, dynamic> volumes;
  final List<Map<String, dynamic>> devices;

  const AudioInfo({required this.ringerMode, required this.volumes, required this.devices});

  factory AudioInfo.fromJson(Map<String, dynamic> json) {
    return AudioInfo(
      ringerMode: json['ringer_mode'] as String? ?? 'N/A',
      volumes: safeMapCast(json['volumes']),
      devices: (json['devices'] as List<dynamic>?)
          ?.map((d) => safeMapCast(d))
          .toList() ?? [],
    );
  }
  @override
  List<Object> get props => [ringerMode, volumes, devices];
}

class CameraInfo extends Equatable {
  final List<Map<String, dynamic>> cameras;
  final String reason;

  const CameraInfo({required this.cameras, required this.reason});

  factory CameraInfo.fromJson(Map<String, dynamic> json) {
    return CameraInfo(
      cameras: (json['cameras'] as List<dynamic>?)
          ?.map((c) => safeMapCast(c))
          .toList() ?? [],
      reason: json['reason'] as String? ?? '',
    );
  }
  bool get hasData => reason.isEmpty;
  @override
  List<Object> get props => [cameras, reason];
}

class VibratorInfo extends Equatable {
  final bool hardwareSupported;
  final bool hasAmplitudeControl;

  const VibratorInfo({required this.hardwareSupported, required this.hasAmplitudeControl});

  factory VibratorInfo.fromJson(Map<String, dynamic> json) {
    return VibratorInfo(
      hardwareSupported: json['hardware_supported'] as bool? ?? false,
      hasAmplitudeControl: json['has_amplitude_control'] as bool? ?? false,
    );
  }
  @override
  List<Object> get props => [hardwareSupported, hasAmplitudeControl];
}

// --- NEW USB MODELS ---

@immutable
class UsbDevice extends Equatable {
  final String deviceName;
  final String manufacturerName;
  final String productName;
  final int vendorId;
  final int productId;

  const UsbDevice({
    required this.deviceName,
    required this.manufacturerName,
    required this.productName,
    required this.vendorId,
    required this.productId,
  });

  factory UsbDevice.fromJson(Map<String, dynamic> json) {
    return UsbDevice(
      deviceName: json['device_name'] as String? ?? 'N/A',
      manufacturerName: json['manufacturer_name'] as String? ?? 'N/A',
      productName: json['product_name'] as String? ?? 'N/A',
      vendorId: json['vendor_id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
    );
  }

  @override
  List<Object> get props => [deviceName, manufacturerName, productName, vendorId, productId];
}

@immutable
class UsbInfo extends Equatable {
  final List<UsbDevice> devices;
  final String? reason; // For errors like permission denied

  const UsbInfo({required this.devices, this.reason});

  factory UsbInfo.fromJson(Map<String, dynamic> json) {
    return UsbInfo(
      devices: (json['devices'] as List<dynamic>?)
          ?.map((d) => UsbDevice.fromJson(safeMapCast(d)))
          .toList() ?? [],
      reason: json['reason'] as String?,
    );
  }

  bool get hasData => reason == null;

  @override
  List<Object?> get props => [devices, reason];
}

// --- END OF NEW USB MODELS ---


// --- MAIN TELEMETRY SNAPSHOT MODEL (Fully Complete) ---

class TelemetrySnapshot extends Equatable {
  final String timestampKey;
  final DateTime collectedAt;
  final AppInfo appInfo;
  final AppStorage appStorage;
  final AppsMemoryInfo appsMemory;
  final AudioInfo audio;
  final BatteryInfo batteryInfo;
  final BluetoothInfo bluetooth;
  final BuildInfo build;
  final CameraInfo camera;
  final CellularInfo cellularSignals;
  final CpuInfo cpuInfo;
  final double cpuTempC;
  final DisplayInfo display;
  final GpuInfo gpuInfo;
  final InstalledPackages installedPackages;
  final LocationInfo location;
  final MediaCodecs mediaCodecs;
  final MemoryInfo memory;
  final NetworkUsage networkUsage;
  final NfcInfo nfc;
  final PermissionInfo permissionInfo;
  final SecurityInfo securityInfo;
  final SensorInfo sensors;
  final SimInfo sim;
  final DeviceStorageInfo storage;
  final SystemSettings systemSettings;
  final VibratorInfo vibrator;
  final VpnInfo vpnInfo;
  final WifiInfo wifi;
  final UsbInfo usb; // Added usb

  const TelemetrySnapshot({
    required this.timestampKey,
    required this.collectedAt,
    required this.appInfo,
    required this.appStorage,
    required this.appsMemory,
    required this.audio,
    required this.batteryInfo,
    required this.bluetooth,
    required this.build,
    required this.camera,
    required this.cellularSignals,
    required this.cpuInfo,
    required this.cpuTempC,
    required this.display,
    required this.gpuInfo,
    required this.installedPackages,
    required this.location,
    required this.mediaCodecs,
    required this.memory,
    required this.networkUsage,
    required this.nfc,
    required this.permissionInfo,
    required this.securityInfo,
    required this.sensors,
    required this.sim,
    required this.storage,
    required this.systemSettings,
    required this.vibrator,
    required this.vpnInfo,
    required this.wifi,
    required this.usb, // Added usb
  });

  factory TelemetrySnapshot.fromJson(String timestampKey, Map<String, dynamic> json) {
    final collectedAtMs = json['atlas_metadata']?['collected_at_ms'] as int? ?? 0;

    return TelemetrySnapshot(
      timestampKey: timestampKey,
      collectedAt: DateTime.fromMillisecondsSinceEpoch(collectedAtMs),
      appInfo: AppInfo.fromJson(safeMapCast(json['app_info'])),
      appStorage: AppStorage.fromJson(safeMapCast(json['app_storage'])),
      appsMemory: AppsMemoryInfo.fromJson(safeMapCast(json['apps_memory'])),
      audio: AudioInfo.fromJson(safeMapCast(json['audio'])),
      batteryInfo: BatteryInfo.fromJson(safeMapCast(json['battery'])),
      bluetooth: BluetoothInfo.fromJson(safeMapCast(json['bluetooth'])),
      build: BuildInfo.fromJson(safeMapCast(json['build'])),
      camera: CameraInfo.fromJson(safeMapCast(json['camera'])),
      cellularSignals: CellularInfo.fromJson(safeMapCast(json['cellular_signals'])),
      cpuInfo: CpuInfo.fromJson(safeMapCast(json['system_uptime']?['cpu'])),
      cpuTempC: (json['cpu_temp_c'] as num? ?? 0.0).toDouble(),
      display: DisplayInfo.fromJson(safeMapCast(json['display'])),
      gpuInfo: GpuInfo.fromJson(safeMapCast(json['gpu_info'])),
      installedPackages: InstalledPackages.fromJson(safeMapCast(json['installed_packages'])),
      location: LocationInfo.fromJson(safeMapCast(json['location'])),
      mediaCodecs: MediaCodecs.fromJson(safeMapCast(json['media_codecs'])),
      memory: MemoryInfo.fromJson(safeMapCast(json['memory'])),
      networkUsage: NetworkUsage.fromJson(safeMapCast(json['network_usage'])),
      nfc: NfcInfo.fromJson(safeMapCast(json['nfc'])),
      permissionInfo: PermissionInfo.fromJson(safeMapCast(json['permission_info'])),
      securityInfo: SecurityInfo.fromJson(safeMapCast(json['security_info'])),
      sensors: SensorInfo.fromJson(safeMapCast(json['sensors'])),
      sim: SimInfo.fromJson(safeMapCast(json['sim'])),
      storage: DeviceStorageInfo.fromJson(safeMapCast(json['storage'])),
      systemSettings: SystemSettings.fromJson(safeMapCast(json['system_settings'])),
      vibrator: VibratorInfo.fromJson(safeMapCast(json['vibrator'])),
      vpnInfo: VpnInfo.fromJson(safeMapCast(json['vpn_info'])),
      wifi: WifiInfo.fromJson(safeMapCast(json['wifi'])),
      usb: UsbInfo.fromJson(safeMapCast(json['usb'])), // Added usb
    );
  }

  String get formattedTime => DateFormat('MMM d, hh:mm:ss a').format(collectedAt.toLocal());

  @override
  List<Object> get props => [
    timestampKey,
    collectedAt,
    appInfo,
    appStorage,
    appsMemory,
    audio,
    batteryInfo,
    bluetooth,
    build,
    camera,
    cellularSignals,
    cpuInfo,
    cpuTempC,
    display,
    gpuInfo,
    installedPackages,
    location,
    mediaCodecs,
    memory,
    networkUsage,
    nfc,
    permissionInfo,
    securityInfo,
    sensors,
    sim,
    storage,
    systemSettings,
    vibrator,
    vpnInfo,
    wifi,
    usb, // Added usb
  ];
}

// --- High-Level Client/Device Models for Navigation ---

class DeviceData extends Equatable {
  final String deviceId;
  final Map<String, TelemetrySnapshot> snapshots;
  final String deviceModel;

  const DeviceData({
    required this.deviceId,
    required this.snapshots,
    required this.deviceModel,
  });

  factory DeviceData.fromJson(String deviceId, Map<String, dynamic> json) {
    final snapshots = <String, TelemetrySnapshot>{};
    String latestModel = 'N/A';

    final rawSnapshots = safeMapCast(json['snapshots']);

    rawSnapshots.forEach((key, value) {
      if (key is String && value is Map) {
        final snapshot = TelemetrySnapshot.fromJson(key, safeMapCast(value));
        snapshots[key] = snapshot;
        latestModel = snapshot.build.model;
      }
    });

    // Sort snapshots by timestamp (latest first)
    final sortedKeys = snapshots.keys.toList()
      ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));

    final sortedSnapshots = {
      for (var key in sortedKeys) key: snapshots[key]!
    };

    return DeviceData(
      deviceId: deviceId,
      snapshots: sortedSnapshots,
      deviceModel: latestModel,
    );
  }

  TelemetrySnapshot? get latestSnapshot => snapshots.isNotEmpty
      ? snapshots[snapshots.keys.first]
      : null;

  @override
  List<Object> get props => [deviceId, snapshots, deviceModel];
}

class ClientData extends Equatable {
  final String clientId;
  final Map<String, DeviceData> devices;

  const ClientData({required this.clientId, required this.devices});

  factory ClientData.fromJson(String clientId, Map<String, dynamic> json) {
    final devices = <String, DeviceData>{};
    safeMapCast(json['devices']).forEach((key, value) {
      devices[key] = DeviceData.fromJson(key, safeMapCast(value));
    });
    return ClientData(clientId: clientId, devices: devices);
  }

  @override
  List<Object> get props => [clientId, devices];
}

class DashboardData extends Equatable {
  final Map<String, ClientData> clients;

  const DashboardData({required this.clients});

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final clients = <String, ClientData>{};
    safeMapCast(json['clients']).forEach((key, value) {
      clients[key] = ClientData.fromJson(key, safeMapCast(value));
    });
    return DashboardData(clients: clients);
  }

  @override
  List<Object> get props => [clients];
}