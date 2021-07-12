import 'package:flutter/services.dart';
import 'package:memory_info_platform_interface/memory_info_platform_interface.dart';
import 'package:meta/meta.dart';

class MethodChannelMemoryInfo extends MemoryInfoPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  MethodChannel channel = MethodChannel('github.com/MrOlolo/memory_info');

  @override
  Future<DiskSpace> diskSpace() async {
    return DiskSpace.fromMap(
      (await channel.invokeMethod('getDiskSpace')).cast<String, dynamic>(),
    );
  }

  @override
  Future<Memory> memoryInfo() async{
    return Memory.fromMap(
      (await channel.invokeMethod('getMemoryInfo')).cast<String, dynamic>(),
    );
  }
}
