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
  GameStateManager gsm;
  double blockSpeed = 0.2;
  double accelerate = 1.0;

  BlockMovementSystem() : super(Aspect.getAspectForAllOf([Position, BlockType]).exclude([StickyBlock]));

  @override
  void processEntity(Entity entity) {
    pm[entity].y -= blockSpeed * world.delta * accelerate;
  }

  @override
  bool checkProcessing() => !gsm.gameOver;

  void reset() {
    blockSpeed = 0.2;
    accelerate = 1.0;
  }
}

class BlockConversionSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  Mapper<FallingBlock> fbm;
  GridManager gm;

  BlockConversionSystem() : super(Aspect.getAspectForAllOf([Position, FallingBlock]));

  @override
  void processEntity(Entity entity) {
    if (pm[entity].y < -0.5) {
      var fb = fbm[entity];
      entity
        ..addComponent(new StickyBlock(fb.col, 0))
        ..removeComponent(FallingBlock)
        ..changedInWorld();
      gm.addStickyBlock(entity);
    }
  }
}

class BlockDestructionSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  Mapper<FallingBlock> fbm;

  BlockDestructionSystem() : super(Aspect.getAspectForAllOf([Position]).exclude([StickyBlock]));

  @override
  void processEntity(Entity entity) {
    if (pm[entity].y < -1.0) {
      entity.deleteFromWorld();
    }
  }
}

class BeatFactorSystem extends VoidEntitySystem {
  double beatFactor = 1.0;
  double maxBeat = 5.0;
  List<int> byteFrequencyData;

  BeatFactorSystem(this.byteFrequencyData);

  @override
  void processSystem() {
    beatFactor = byteFrequencyData.reduce(sum) / byteFrequencyData.length;
    maxBeat = max(maxBeat, beatFactor);
    beatFactor = 1.0 + 50 * beatFactor / maxBeat;
  }

  int sum(int a, int b) => a + b;
}

class StickyBlockPositionUpdatingSystem extends EntityProcessingSystem {
  Mapper<StickyBlock> sbm;
  Mapper<Position> pm;
  GridManager gm;

  StickyBlockPositionUpdatingSystem() : super(Aspect.getAspectForAllOf([Position, StickyBlock]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var sb = sbm[entity];

    p.x = p.x * 0.8 + gm.getColPos(sb.col) * 0.2;
    p.y = p.y * 0.8 + (-0.475 + sb.row * -0.2 * gm.posFactor - 0.02 * gm.sizeFactor * (sb.row + 1)) * 0.2;
  }
}

class FallingBlockPositionUpdatingSystem extends EntityProcessingSystem {
  Mapper<FallingBlock> fbm;
  Mapper<Position> pm;
  GridManager gm;

  FallingBlockPositionUpdatingSystem() : super(Aspect.getAspectForAllOf([Position, FallingBlock]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var fb = fbm[entity];

    p.x = p.x * 0.8 + gm.getColPos(fb.col) * 0.2;
  }
}

class DelayedExplosionSystem extends EntityProcessingSystem {
  Mapper<DelayedExplosion> dem;
  Mapper<FallingBlock> fbm;
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
      gm.removeExplodingBlock(entity);
      world.createAndAddEntity([new SoundEffect('explode')]);
      entity.deleteFromWorld();
      for (int i = 0; i < 160; i++) {
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
  GridManager gm;
  BlockSpawnerSystem bss;
  BlockMovementSystem bms;

  ScoreSystem() : super(Aspect.getAspectForAllOf([Score]));

  @override
  void processEntity(Entity entity) {
    var s = sm[entity];
    s.delay -= world.delta;
    if (s.delay <= 0.0) {
      gsm.score += s.amount;
      bms.blockSpeed *= 1.01;
      bss.timeForNext *= 0.98;
      entity.deleteFromWorld();

      if (1 + log(2.5 * gsm.score) >= bss.colors.length) {
        bss.addColor();
      }
      if (1 + log(1.5 * gsm.score) >= gm.cols) {
        gm.addColumn();
      }
      if (2 + log(gsm.score) >= gm.rows) {
        gm.addRow();
      }
      if (gsm.score % 10 == 0) {
        gsm.lives++;
      }
    }
  }
}

class BlockSpawnerSystem extends VoidEntitySystem {
  GridManager gm;
  GameStateManager gsm;

  var spawnTimer = 1.0;
  var timeForNext = 3.0;
  List<double> colorPool = new List<double>();
  List<double> colors = [random.nextDouble()];
  double accelerate = 1.0;

  @override
  void initialize() {
    initColorPool();
  }

  void initColorPool() {
    var startColor = colors[0];
    for (int i = 0; i < 9; i++) {
      colorPool.add((startColor + 0.1 * i) % 1.0);
    }
    colorPool.shuffle(random);
  }

  @override
  void processSystem() {
    spawnTimer -= world.delta * accelerate;
    if (spawnTimer <= 0.0) {
      spawnTimer += timeForNext;
      world.createAndAddEntity([
        new Position(0.0, 1.1),
        new FallingBlock(random.nextInt(gm.cols)),
        new Color(colors[random.nextInt(colors.length)], 0.8, 0.8),
        new BlockType(BlockType.RECTANGLE)
      ]);
    }
  }

  void addColor() {
    if (colorPool.isNotEmpty) {
      colors.add(colorPool.removeLast());
    }
  }

  @override
  bool checkProcessing() => !gsm.gameOver;

  void reset() {
    spawnTimer = 1.0;
    timeForNext = 3.0;
    colors = [random.nextDouble()];
    accelerate = 1.0;
    initColorPool();
  }
}


class ControllerSystem extends EntityProcessingSystem {
  Mapper<Controller> cm;
  GridManager gm;
  GameStateManager gsm;

  ControllerSystem() : super(Aspect.getAspectForAllOf([Controller]));

  @override
  void processEntity(Entity entity) {
    var c = cm[entity];
    if (c.direction != 0) {
      gm.moveAllBlocks(c.direction);
    }
  }

  @override
  bool checkProcessing() => !gsm.gameOver;
}