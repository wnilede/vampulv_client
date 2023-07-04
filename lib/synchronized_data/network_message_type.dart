enum NetworkMessageType {
  setDevices(isGameChange: false),
  setIdentifier(isGameChange: false),
  setGameConfiguration(isGameChange: false),
  changeDeviceControls(isGameChange: false),
  setSynchronizedData(isGameChange: false);

  // ignore: unused_element
  const NetworkMessageType({this.isGameChange = true, this.isSynchronizedDataChange = true});

  final bool isSynchronizedDataChange;
  final bool isGameChange;
}
