part of client;

class BlockSpawnerSystem extends VoidEntitySystem {
  var spawnTimer = 1.0;

  @override
  void processSystem() {
    spawnTimer -= world.delta;
    if (spawnTimer <= 0.0) {
      spawnTimer += 0.5;
      world.createAndAddEntity([
        new Position(0.0, 1.0),
        new Color(random.nextDouble(), 0.8, 0.8),
        new BlockType(BlockType.RECTANGLE)
      ]);
    }
  }
}
