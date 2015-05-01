part of shared;


class BlockMovementSystem extends EntityProcessingSystem {
  Mapper<Position> pm;

  BlockMovementSystem() : super(Aspect.getAspectForAllOf([Position]));

  @override
  void processEntity(Entity entity) {
    pm[entity].y -= 0.01;
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
