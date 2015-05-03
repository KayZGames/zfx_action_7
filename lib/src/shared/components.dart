part of shared;

class Position extends Component {
  double x, y;
  Position(this.x, this.y);
}

class Velocity extends Component {
  double x, y;
  Velocity(this.x, this.y);
}

class Color extends Component {
  double h, s, l;
  Color(this.h, this.s, this.l);
}

class BlockType extends Component {
  static const RECTANGLE = 0;
  int type;
  BlockType(this.type);
}

class StickyBlock extends Component {
  int col, row;
  StickyBlock(this.col, this.row);
}

class FallingBlock extends Component {
  int col;
  FallingBlock(this.col);
}

class DelayedExplosion extends Component {
  double delay;
  DelayedExplosion(this.delay);
}

class Particle extends Component {}

class Score extends Component {
  int amount;
  double delay;
  Score(this.amount, this.delay);
}

class Controller extends Component {
  int direction = 0;
}
