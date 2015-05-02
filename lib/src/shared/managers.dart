part of shared;

class GridManager extends Manager {
  Mapper<StickyBlock> sbm;
  Mapper<Color> cm;
  Mapper<DelayedExplosion> dem;

  var grid = <List<Entity>>[[null, null, null]];
  var cols = 1;
  var rows = 3;

  @override
  void changed(Entity entity) {
    if (sbm.has(entity) && !dem.has(entity)) {
      var sb = sbm[entity];
      var c = cm[entity];
      moveBlock(sb.x, sb.y, entity);
      var matches = getMatches(sb.x, sb.y, c.h, new Set<int>());
      if (matches.length >= 3) {
        matches.forEach((block) {
          sb = sbm[block];
          grid[sb.x][sb.y] = null;
          block
            ..addComponent(new DelayedExplosion(0.2))
            ..changedInWorld();
        });
        world.processEntityChanges();
      }
    }
  }

  void moveBlock(int x, int y, Entity block) {
    if (grid[x][y] != null) {
      var oldBlock = grid[x][y];
      if (y + 1 < rows) {
        moveBlock(x, y + 1, oldBlock);
        var sb = sbm[oldBlock];
        sb.y += 1;
      } else {
        oldBlock.deleteFromWorld();
      }
    }
    grid[x][y] = block;
  }

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
}
