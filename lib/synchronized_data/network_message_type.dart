enum NetworkMessageType {
  setDevices(isGameChange: false), // This is unique in that it is sent by the server.
  setGameConfiguration(isGameChange: false),
  changeDeviceControls(isGameChange: false),
  inputToGame(isGameChange: true);

  // ignore: unused_element
  const NetworkMessageType({this.isGameChange = true, this.isSynchronizedDataChange = true});

  final bool isSynchronizedDataChange;
  final bool isGameChange;
}
