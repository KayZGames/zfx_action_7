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
    var matches = getMatches(sb.col, sb.row, c.h, new Set<int>());
    if (matches.length >= 3) {
      world.createAndAddEntity([new Score(matches.length - 2, 0.25)]);
      matches.forEach((block) {
        sb = sbm[block];
        grid[sb.col][sb.row] = null;
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
      } else {
        oldBlock.deleteFromWorld();
      }
    }
  }

  void moveAllBlocks(int direction) {
    if (direction == -1) {
      grid.add(grid.removeAt(0));
    } else {
      grid.insert(0, grid.removeLast());
    }
    grid.forEach((column) => column.where((block) => null != block).forEach((block) {
      var sb = sbm[block];
      sb.col = (sb.col + direction) % cols;
    }));
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
      if (null != block && !checked.contains(block.id) && cm[block].h == hue) {
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
}

class GameStateManager extends Manager {
  int score = 0;
}
