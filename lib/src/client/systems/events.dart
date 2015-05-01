part of client;

class BlockSpawnerSystem extends VoidEntitySystem {
  Uint8List byteFrequencyData;
  Uint8List lastByteFrequencyData;

  BlockSpawnerSystem(this.byteFrequencyData) {
    lastByteFrequencyData = new Uint8List.fromList(byteFrequencyData);
  }

  @override
  void processSystem() {
    for (int i = 0; i < byteFrequencyData.length; i++) {
      var value = byteFrequencyData[i];
      if (value > lastByteFrequencyData[i] + 50) {
        world.createAndAddEntity([
          new Position(-1.0 + 2 * (i / byteFrequencyData.length), 1.0),
          new Color(1.0, 1.0, 1.0)
        ]);
      }
    }
    lastByteFrequencyData = new Uint8List.fromList(byteFrequencyData);
  }
}
