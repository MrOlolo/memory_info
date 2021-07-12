#import "MemoryInfoPlugin.h"
#if __has_include(<memory_info/memory_info-Swift.h>)
#import <memory_info/memory_info-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "memory_info-Swift.h"
#endif

@implementation MemoryInfoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMemoryInfoPlugin registerWithRegistrar:registrar];
}
@end
