import 'dart:async';

import 'package:memory_info_platform_interface/model/disk_space.dart';
import 'package:memory_info_platform_interface/model/memory.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel/method_channel_memory_info.dart';

export 'model/disk_space.dart';
export 'model/memory.dart';

abstract class MemoryInfoPlatform extends PlatformInterface {
  MemoryInfoPlatform() : super(token: _token);

  static final Object _token = Object();

  static MemoryInfoPlatform _instance = MethodChannelMemoryInfo();

  static MemoryInfoPlatform get instance => _instance;

  static set instance(MemoryInfoPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<DiskSpace> diskSpace() {
    throw UnimplementedError('diskSpace() has not been implemented.');
  }

  Future<Memory> memoryInfo() {
    throw UnimplementedError('memoryInfo() has not been implemented.');
  }
}
