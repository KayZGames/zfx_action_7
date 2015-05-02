part of shared;

class Position extends Component {
  double x, y;
  Position(this.x, this.y);
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
