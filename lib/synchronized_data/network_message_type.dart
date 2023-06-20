enum NetworkMessageType {
  addPlayer(isGameChange: true),
  addDevice(isGameChange: false),
  changeDeviceControls(isGameChange: false);

  // ignore: unused_element
  const NetworkMessageType({required this.isGameChange, this.isSynchronizedDataChange = true});

  final bool isSynchronizedDataChange;
  final bool isGameChange;
}
