class DiskSpace {
  final num? freeSpace;
  final num? totalSpace;

  DiskSpace(this.freeSpace, this.totalSpace);

  num? get usedSpace => (totalSpace ?? 0) - (freeSpace ?? 0);

  factory DiskSpace.fromMap(Map<String, dynamic> map) =>
      DiskSpace(map['diskFreeSpace'], map['diskTotalSpace']);

  Map<String, dynamic> toMap() => {
        'diskFreeSpace': freeSpace,
        'diskTotalSpace': totalSpace,
      };
}
