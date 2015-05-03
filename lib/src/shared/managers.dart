part of shared;

class GridManager extends Manager {
  Mapper<StickyBlock> sbm;
  Mapper<Color> cm;
  Mapper<DelayedExplosion> dem;
  BeatFactorSystem bfs;
  GameStateManager gsm;

  List<List<Entity>> grid = <List<Entity>>[[null, null, null]];
  var cols = 1;
  var rows = 3;
  double colOffset = 0.0;

  void addStickyBlock(Entity entity) {
    var sb = sbm[entity];
    var c = cm[entity];
    moveBlockTo(sb.col, sb.row, entity);
    matchIt(sb, c);
  }

  void matchIt(StickyBlock sb, Color c) {
    var matches = getMatches(sb.col, sb.row, c.h, new Set<int>());
    if (matches.length >= 3) {
      world.createAndAddEntity([new Score(matches.length - 2, 0.25)]);
      matches.forEach((block) {
        sb = sbm[block];
        block
          ..addComponent(new DelayedExplosion(0.2))
          ..changedInWorld();
      });
    }
  }

  void moveBlockTo(int x, int y, Entity block) {
    var sb = sbm[block];
    var oldBlock = grid[x][y];
    sb.row = y;
    grid[sb.col][sb.row] = block;
    if (oldBlock != null) {
      if (y + 1 < rows) {
        moveBlockTo(x, y + 1, oldBlock);
        matchIt(sbm[oldBlock], cm[oldBlock]);
      } else {
        oldBlock.deleteFromWorld();
        gsm.blockOut();
      }
    }
  }

  void moveAllBlocks(int direction) {
    List<Entity> columnToMove;
    if (direction == -1) {
      columnToMove = grid.removeAt(0);
      grid.add(columnToMove);
    } else {
      columnToMove = grid.removeLast();
      grid.insert(0, columnToMove);
    }
    grid.forEach((column) => column.where((block) => null != block).forEach((block) {
      var sb = sbm[block];
      sb.col = (sb.col + direction) % cols;
    }));
    columnToMove.where((block) => null != block).forEach((block) => matchIt(sbm[block], cm[block]));
  }

  void removeExplodingBlock(Entity block) {
    var sb = sbm[block];
    var column = grid[sb.col];
    column[sb.row] = null;
    for (int row = sb.row; row < rows-1; row++) {
      var blockToMove = column[row+1];
      column[row] = blockToMove;
      if (null != blockToMove) {
        sbm[blockToMove].row = row;
      }
      column[row+1] = null;
    }
    column.where((block) => null != block).forEach((block) => matchIt(sbm[block], cm[block]));
  }

  void addColumn() {
    cols++;
    colOffset -= 0.1;
    grid.add(new List.generate(rows, (_) => null));
  }

  void addRow() {
    rows++;
    grid.forEach((column) => column.add(null));
  }

  double getColPos(int col) => colOffset + col * 0.2;

  List<Entity> getMatches(int x, int y, double hue, Set<int> checked) {
    if (x >= 0 && x < cols && y >= 0 && y < rows) {
      var block = grid[x][y];
      if (null != block && !checked.contains(block.id) && cm[block].h == hue && !dem.has(block)) {
        checked.add(block.id);
        var result = [block];
        result.addAll(getMatches(x + 1, y, hue, checked));
        result.addAll(getMatches(x - 1, y, hue, checked));
        result.addAll(getMatches(x, y + 1, hue, checked));
        result.addAll(getMatches(x, y - 1, hue, checked));
        return result;
      }
    }
    return [];
  }

  double get posFactor => 0.4 * (0.4 + bfs.beatFactor / 100);
  double get sizeFactor => 1.6 * (0.8 + bfs.beatFactor / 50);

  void reset() {
    grid = <List<Entity>>[[null, null, null]];
    cols = 1;
    rows = 3;
    colOffset = 0.0;
  }
}

class GameStateManager extends Manager {
  int score = 0;
  int lives = 3;
  bool gameOver = false;
  GridManager gm;
  BlockSpawnerSystem bss;
  BlockMovementSystem bms;

  void blockOut() {
    lives--;
    if (lives <= 0 && !gameOver) {
      gameOver = true;
      world.createAndAddEntity([new SoundEffect('gameover')]);
    }
  }

  void restart() {
    score = 0;
    lives = 3;
    gameOver = false;
    world.deleteAllEntities();
    gm.reset();
    bss.reset();
    bms.reset();
    world.createAndAddEntity([new Controller()]);
  }
}
