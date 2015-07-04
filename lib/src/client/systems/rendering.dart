part of client;

class MusicVisualisationSystem extends VoidEntitySystem {
  Uint8List byteFrequencyData;
  RenderingContext gl;
  InputElement preventHeadache = querySelector('#preventHeadache');

  MusicVisualisationSystem(this.gl, this.byteFrequencyData);

  @override
  void processSystem() {
    if (preventHeadache.checked) {
      gl.clearColor(0.0, 0.0, 0.0, 1.0);
      gl.clear(RenderingContext.COLOR_BUFFER_BIT | RenderingContext.DEPTH_BUFFER_BIT);
      querySelector('body').style.backgroundColor = 'black';
    } else {
      var red = byteFrequencyData.getRange(0, byteFrequencyData.length ~/ 2).reduce(sum) ~/ byteFrequencyData.length;
      var green = byteFrequencyData
              .getRange(byteFrequencyData.length ~/ 4, 3 * byteFrequencyData.length ~/ 4)
              .reduce(sum) ~/
          byteFrequencyData.length;
      var blue = byteFrequencyData.getRange(byteFrequencyData.length ~/ 2, byteFrequencyData.length).reduce(sum) ~/
          byteFrequencyData.length;
      gl.clearColor(red / 256, green / 256, blue / 256, 1.0);
      gl.clear(RenderingContext.COLOR_BUFFER_BIT | RenderingContext.DEPTH_BUFFER_BIT);
      querySelector('body').style.backgroundColor = '#${toHex(red)}${toHex(green)}${toHex(blue)}';
    }
  }

  int sum(int a, int b) => a + b;
  String toHex(int a) => a.toRadixString(16).padLeft(2, '0');
}

class EqualizerSystem extends VoidWebGlRenderingSystem {
  Uint8List byteFrequencyData;
  Float32List items;
  Uint16List indices;
  List<Attrib> attributes;
  double width, height;

  EqualizerSystem(RenderingContext gl, this.byteFrequencyData) : super(gl) {
    items = new Float32List(byteFrequencyData.length * 3 * 4);
    indices = new Uint16List(byteFrequencyData.length * 6);
    attributes = [new Attrib('aPosition', 2), new Attrib('aValue', 1)];
    width = 2 / byteFrequencyData.length;
    height = 1 / 300;
  }

  @override
  void render() {
    for (int i = 0; i < byteFrequencyData.length; i++) {
      var index = i * 3 * 4;
      items[index + 0] = -byteFrequencyData[i] * width;
      items[index + 1] = 1.0 - i * height;
      items[index + 2] = byteFrequencyData[i].toDouble();

      items[index + 3] = -byteFrequencyData[i] * width;
      items[index + 4] = 1.0 - i * height - height;
      items[index + 5] = byteFrequencyData[i].toDouble();

      items[index + 6] = byteFrequencyData[i] * width;
      items[index + 7] = 1.0 - i * height - height;
      items[index + 8] = byteFrequencyData[i].toDouble();

      items[index + 9] = byteFrequencyData[i] * width;
      items[index + 10] = 1.0 - i * height;
      items[index + 11] = byteFrequencyData[i].toDouble();

      indices[i * 6] = index;
      indices[i * 6 + 1] = index + 3;
      indices[i * 6 + 2] = index + 6;
      indices[i * 6 + 3] = index;
      indices[i * 6 + 4] = index + 3;
      indices[i * 6 + 5] = index + 9;
    }
    bufferElements(attributes, items, indices);

    gl.drawElements(RenderingContext.TRIANGLES, byteFrequencyData.length * 2, RenderingContext.UNSIGNED_SHORT, 0);

    var aColor = gl.getUniformLocation(program, 'uColor');
    var color = hslToRgb(time / 25.6 % 1, 0.8, 0.8);
    gl.uniform3fv(aColor, new Float32List.fromList(color));
  }

  @override
  String get fShaderFile => 'EqualizerSystem';

  @override
  String get vShaderFile => 'EqualizerSystem';
}

class BlockRenderingSystem extends WebGlRenderingSystem {
  Mapper<Position> pm;
  Mapper<Color> cm;
  BeatFactorSystem bfs;

  Float32List items;
  Uint16List indices;
  List<Attrib> attributes;

  var x = [-0.04, -0.04, 0.04, 0.04];
  var y = [-0.02, 0.02, 0.02, -0.02];

  final int indicesPerBlock = 30;

  BlockRenderingSystem(RenderingContext gl) : super(gl, Aspect.getAspectForAllOf([Position, Color, BlockType])) {
    attributes = [new Attrib('aPosition', 2), new Attrib('aColor', 3)];
  }

  @override
  void processEntity(int index, Entity entity) {
    var p = pm[entity];
    var c = cm[entity];
    var sizeFactor = 0.8 + bfs.beatFactor / 50;
    var rgbOuter = hslToRgb(c.h + 0.1, c.s * sizeFactor, c.l * sizeFactor / 2);
    var rgb = hslToRgb(c.h, (c.s - 0.1) * sizeFactor, c.l);

    var offset = 5 * 4 * 2 * index;

    for (int i = 0; i < 4; i++) {
      items[offset + i * 10] = p.x + x[i] * sizeFactor * 1.5;
      items[offset + i * 10 + 1] = p.y + y[i] * sizeFactor * 1.5;
      items[offset + i * 10 + 2] = rgbOuter[0];
      items[offset + i * 10 + 3] = rgbOuter[1];
      items[offset + i * 10 + 4] = rgbOuter[2];

      items[offset + i * 10 + 5] = p.x + x[i] * sizeFactor;
      items[offset + i * 10 + 6] = p.y + y[i] * sizeFactor;
      items[offset + i * 10 + 7] = rgb[0];
      items[offset + i * 10 + 8] = rgb[1];
      items[offset + i * 10 + 9] = rgb[2];
    }

    indices[indicesPerBlock * index] = 8 * index;
    indices[indicesPerBlock * index + 1] = 8 * index + 3;
    indices[indicesPerBlock * index + 2] = 8 * index + 1;
    indices[indicesPerBlock * index + 3] = 8 * index;
    indices[indicesPerBlock * index + 4] = 8 * index + 2;
    indices[indicesPerBlock * index + 5] = 8 * index + 3;

    indices[indicesPerBlock * index + 6] = 8 * index + 2;
    indices[indicesPerBlock * index + 7] = 8 * index + 5;
    indices[indicesPerBlock * index + 8] = 8 * index + 3;
    indices[indicesPerBlock * index + 9] = 8 * index + 2;
    indices[indicesPerBlock * index + 10] = 8 * index + 4;
    indices[indicesPerBlock * index + 11] = 8 * index + 5;

    indices[indicesPerBlock * index + 12] = 8 * index + 4;
    indices[indicesPerBlock * index + 13] = 8 * index + 7;
    indices[indicesPerBlock * index + 14] = 8 * index + 5;
    indices[indicesPerBlock * index + 15] = 8 * index + 4;
    indices[indicesPerBlock * index + 16] = 8 * index + 6;
    indices[indicesPerBlock * index + 17] = 8 * index + 7;

    indices[indicesPerBlock * index + 18] = 8 * index + 6;
    indices[indicesPerBlock * index + 19] = 8 * index + 1;
    indices[indicesPerBlock * index + 20] = 8 * index + 7;
    indices[indicesPerBlock * index + 21] = 8 * index + 6;
    indices[indicesPerBlock * index + 22] = 8 * index + 0;
    indices[indicesPerBlock * index + 23] = 8 * index + 1;

    indices[indicesPerBlock * index + 24] = 8 * index + 1;
    indices[indicesPerBlock * index + 25] = 8 * index + 3;
    indices[indicesPerBlock * index + 26] = 8 * index + 5;
    indices[indicesPerBlock * index + 27] = 8 * index + 1;
    indices[indicesPerBlock * index + 28] = 8 * index + 5;
    indices[indicesPerBlock * index + 29] = 8 * index + 7;
  }

  @override
  void render(int length) {
    bufferElements(attributes, items, indices);

    gl.uniform1f(gl.getUniformLocation(program, 'uSize'), bfs.beatFactor / 10);

    gl.drawElements(TRIANGLES, length * indicesPerBlock, UNSIGNED_SHORT, 0);
  }

  @override
  void updateLength(int length) {
    indices = new Uint16List(length * indicesPerBlock);
    items = new Float32List(length * 5 * 4 * 2);
  }

  @override
  String get vShaderFile => 'BlockRenderingSystem';
  @override
  String get fShaderFile => 'BlockRenderingSystem';

}

class GridRenderingSystem extends VoidWebGlRenderingSystem {
  GridManager gm;
  BeatFactorSystem bfs;

  Float32List items;
  Uint16List indices;
  List<Attrib> attributes;

  var x = [-0.04, -0.04, 0.04, 0.04];
  var y = [-0.02, 0.02, 0.02, -0.02];

  GridRenderingSystem(RenderingContext gl) : super(gl) {
    attributes = [new Attrib('aPosition', 2)];
  }

  @override
  void render() {
    items = new Float32List(gm.rows * gm.cols * 4 * 2 + 4);
    indices = new Uint16List(gm.rows * gm.cols * 4 * 2 + 2);
    var sizeFactor = 1.6 * (0.8 + bfs.beatFactor / 50);
    var posFactor = 0.4 * (0.4 + bfs.beatFactor / 100);
    for (int row = 0; row < gm.rows; row++) {
      for (int col = 0; col < gm.cols; col++) {
        var blockNumber = row * gm.cols + col;
        var index = blockNumber * 4;
        for (int i = 0; i < 4; i++) {
          items[(index + i) * 2 + 0] = gm.getColPos(col) + x[i] * sizeFactor;
          items[(index + i) * 2 + 1] = -0.475 + row * -0.2 * posFactor + y[i] * sizeFactor - 0.02 * sizeFactor * (row+1);

          indices[(index + i) * 2 + 0] = index + (i % 4);
          indices[(index + i) * 2 + 1] = index + ((i + 1) % 4);
        }
      }
    }
    items[gm.rows * gm.cols * 8 + 0] = -1.0;
    items[gm.rows * gm.cols * 8 + 1] = -0.45;
    items[gm.rows * gm.cols * 8 + 2] = 1.0;
    items[gm.rows * gm.cols * 8 + 3] = -0.45;

    indices[gm.rows * gm.cols * 8 + 0] = gm.rows * gm.cols * 4;
    indices[gm.rows * gm.cols * 8 + 1] = gm.rows * gm.cols * 4 + 1;
    bufferElements(attributes, items, indices);

    gl.drawElements(LINES, indices.length, UNSIGNED_SHORT, 0);
  }

  @override
  String get vShaderFile => 'GridRenderingSystem';
  @override
  String get fShaderFile => 'GridRenderingSystem';
}

class ParticleRenderingSystem extends WebGlRenderingSystem {
  Mapper<Position> pm;
  Mapper<Color> cm;

  Float32List items;
  Uint16List indices;
  List<Attrib> attributes;

  ParticleRenderingSystem(RenderingContext gl) : super(gl, Aspect.getAspectForAllOf([Position, Color, Particle])) {
    attributes = [new Attrib('aPosition', 2), new Attrib('aColor', 3)];
  }

  @override
  void processEntity(int index, Entity entity) {
    var p = pm[entity];
    var c = cm[entity];
    var rgb = hslToRgb(c.h, c.s, c.l);
    int offset = index * 5;
    items[offset + 0] = p.x;
    items[offset + 1] = p.y;
    items[offset + 2] = rgb[0];
    items[offset + 3] = rgb[1];
    items[offset + 4] = rgb[2];

    indices[index] = index;
  }

  @override
  void render(int length) {
    bufferElements(attributes, items, indices);

    gl.drawElements(POINTS, length, UNSIGNED_SHORT, 0);
  }

  @override
  void updateLength(int length) {
    items = new Float32List(length * 5);
    indices = new Uint16List(length);
  }

  @override
  String get vShaderFile => 'ParticleRenderingSystem';
  @override
  String get fShaderFile => 'ParticleRenderingSystem';
}

class ScoreRenderingSystem extends VoidEntitySystem {
  CanvasRenderingContext2D ctx;
  GameStateManager gsm;

  ScoreRenderingSystem(this.ctx);

  @override
  void processSystem() {
    ctx..save()
       ..fillStyle = 'grey'
       ..fillText('Score: ${gsm.score}', 700, 10)
       ..fillText('Lives: ${gsm.lives}', 700, 30)
       ..restore();
  }
}

class GameOverSystem extends VoidEntitySystem {
  GameStateManager gsm;
  BeatFactorSystem bfs;

  CanvasRenderingContext2D ctx;

  GameOverSystem(this.ctx);

  @override
  void processSystem() {
    var fontSize = 200 - 5 * bfs.beatFactor;
    var height = fontSize * 1.6;
    ctx..save()
       ..font = '${fontSize}px Verdana';

    var gameWidth = ctx.measureText('GAME').width;
    var overWidth = ctx.measureText('OVER').width;
    ctx..fillStyle = 'red'
       ..fillText('GAME', 400 - gameWidth/2, 300 - height)
       ..fillText('OVER', 400 - overWidth/2, 250)
       ..font = '40px Verdana'
       ..strokeStyle = 'black'
       ..fillStyle = '#DDCCCC';

    var textWidth = ctx.measureText('click to try again').width;
    ctx..strokeText('click to try again', 400 - textWidth/2, 500)
       ..fillText('click to try again', 400 - textWidth/2, 500)
       ..restore();

  }

  @override
  bool checkProcessing() => gsm.gameOver;
}