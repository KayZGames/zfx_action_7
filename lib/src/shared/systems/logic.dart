part of shared;

class MovementSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  Mapper<Velocity> vm;

  MovementSystem() : super(Aspect.getAspectForAllOf([Position, Velocity]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var v = vm[entity];

    p.x = p.x + v.x * world.delta;
    p.y = p.y + v.y * world.delta;
  }
}

class BlockMovementSystem extends EntityProcessingSystem {
  Mapper<Position> pm;

  BlockMovementSystem() : super(Aspect.getAspectForAllOf([Position, BlockType]).exclude([StickyBlock]));

  @override
  void processEntity(Entity entity) {
    pm[entity].y -= 0.5 * world.delta;
  }
}

class BlockConversionSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  GridManager gm;

  BlockConversionSystem() : super(Aspect.getAspectForAllOf([Position, BlockType]).exclude([StickyBlock]));

  @override
  void processEntity(Entity entity) {
    if (pm[entity].y < -0.5) {
      entity.addComponent(new StickyBlock(0, 0));
      entity.changedInWorld();
      gm.addStickyBlock(entity);
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

class StickyBlockPositionUpdatingSystem extends EntityProcessingSystem {
  Mapper<StickyBlock> sbm;
  Mapper<Position> pm;
  BeatFactorSystem bfs;
  GridManager gm;

  StickyBlockPositionUpdatingSystem() : super(Aspect.getAspectForAllOf([Position, StickyBlock]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var sb = sbm[entity];

    p.x = p.x * 0.8 + 0.2 * sb.x * 0.2;
    p.y = p.y * 0.8 + (-0.475 + sb.y * -0.2 * gm.posFactor - 0.02 * gm.sizeFactor * (sb.y + 1)) * 0.2;
  }
}

class DelayedExplosionSystem extends EntityProcessingSystem {
  Mapper<DelayedExplosion> dem;
  Mapper<Position> pm;
  Mapper<Color> cm;
  GridManager gm;

  DelayedExplosionSystem() : super(Aspect.getAspectForAllOf([DelayedExplosion, Position, Color]));

  @override
  void processEntity(Entity entity) {
    var de = dem[entity];
    de.delay -= world.delta;
    if (de.delay <= 0.0) {
      var p = pm[entity];
      var c = cm[entity];
      entity.deleteFromWorld();
      for (int i = 0; i < 250; i++) {
        var posX = p.x + 0.04 * gm.sizeFactor * (-1 + 2 * random.nextDouble());
        var posY = p.y + 0.02 * gm.sizeFactor * (-1 + 2 * random.nextDouble());
        var velX = (posX - p.x) * 5;
        var velY = (posY - p.y) * 10;
        world.createAndAddEntity(
            [new Position(posX, posY), new Velocity(velX, velY), new Color(c.h, c.s, c.l), new Particle()]);
        if (i % 20 == 0) {
          world.createAndAddEntity(
              [new Position(0.92, 0.92), new Velocity(velX, velY), new Color(c.h, c.s, c.l), new Particle()]);
        }
      }
    }
  }
}

class GravitySystem extends EntityProcessingSystem {
  Mapper<Velocity> vm;

  GravitySystem() : super(Aspect.getAspectForAllOf([Velocity]));

  @override
  void processEntity(Entity entity) {
    var v = vm[entity];

    v.x *= 0.99;
    v.y -= world.delta;
  }
}

class ScoreSystem extends EntityProcessingSystem {
  Mapper<Score> sm;
  GameStateManager gsm;

  ScoreSystem() : super(Aspect.getAspectForAllOf([Score]));

  @override
  void processEntity(Entity entity) {
    var s = sm[entity];
    s.delay -= world.delta;
    if (s.delay <= 0.0) {
      gsm.score += s.amount;
      entity.deleteFromWorld();
    }
  }
}