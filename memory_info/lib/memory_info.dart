import 'dart:async';

import 'package:memory_info_platform_interface/memory_info_platform_interface.dart';
export 'package:memory_info_platform_interface/memory_info_platform_interface.dart';

class MemoryInfoPlugin {
  MemoryInfoPlugin();

  static MemoryInfoPlatform get _platform => MemoryInfoPlatform.instance;

  Future<DiskSpace> get diskSpace => _platform.diskSpace();

  Future<Memory> get memoryInfo => _platform.memoryInfo();
}
