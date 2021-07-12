class Memory {
  ///
  /// ONLY iOS
  /// Not work on Android
  ///
  final num? appMem;
  final num? totalMem;
  final num? freeMem;

  ///
  /// ONLY ANDROID
  /// Not work on iOS
  ///
  final bool? lowMemory;

  Memory(this.appMem, this.totalMem, this.freeMem, this.lowMemory);

  factory Memory.fromMap(Map<String, dynamic> map) =>
      Memory(map['usedByApp'], map['total'], map['free'], map['lowMemory']);

  Map<String, dynamic> toMap() => {
        'usedByApp': appMem,
        'total': totalMem,
        'free': freeMem,
        'lowMemory': lowMemory,
      };
}
