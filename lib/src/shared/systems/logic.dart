part of shared;


class BlockMovementSystem extends EntityProcessingSystem {
  Mapper<Position> pm;

  BlockMovementSystem() : super(Aspect.getAspectForAllOf([Position]).exclude([StickyBlock]));

  @override
  void processEntity(Entity entity) {
    pm[entity].y -= 0.5 * world.delta;
  }
}

class BlockConversionSystem extends EntityProcessingSystem {
  Mapper<Position> pm;

  BlockConversionSystem() : super(Aspect.getAspectForAllOf([Position]).exclude([StickyBlock]));

  @override
  void processEntity(Entity entity) {
    if (pm[entity].y < -0.5) {
      entity.addComponent(new StickyBlock(0, 0));
      entity.changedInWorld();
    }
  }
}

class BlockDestructionSystem extends EntityProcessingSystem {
  Mapper<Position> pm;

  BlockDestructionSystem() : super(Aspect.getAspectForAllOf([Position]));

  @override
  void processEntity(Entity entity) {
    if (pm[entity].y < -1.0) {
      entity.deleteFromWorld();
    }
  }
}

class BeatFactorSystem extends VoidEntitySystem {
  double beatFactor = 1.0;
  List<int> byteFrequencyData;

  BeatFactorSystem(this.byteFrequencyData);

  @override
  void processSystem() {
    beatFactor = byteFrequencyData.reduce(sum) / byteFrequencyData.length;
  }

  int sum(int a, int b) => a + b;
}

class DelayedExplosionSystem extends EntityProcessingSystem {
  Mapper<DelayedExplosion> dem;

  DelayedExplosionSystem() : super(Aspect.getAspectForAllOf([DelayedExplosion]));

  @override
  void processEntity(Entity entity) {
    var de = dem[entity];
    de.delay -= world.delta;
    if (de.delay <= 0.0) {
      entity.deleteFromWorld();
    }
  }
}