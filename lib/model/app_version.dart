class AppVersion {
  String os;
  int buildNumber;
  DateTime releasedAt;
  bool isForceUpdate;
  String appId;

  AppVersion(this.os, this.buildNumber, this.releasedAt, this.isForceUpdate, this.appId);

  factory AppVersion.fromMap(Map<String, dynamic> map) {
    return new AppVersion(
      map['os'],
      map['buildNumber'],
      DateTime.parse(map['releasedAt']),
      map['isForceUpdate'],
      map['appId'],
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'os': this.os,
      'buildNumber': this.buildNumber,
      'releasedAt': this.releasedAt,
      'isForceUpdate': this.isForceUpdate,
      'appId': this.appId,
    } as Map<String, dynamic>;
  }
}
