part of client;

class MusicVisualisationSystem extends VoidEntitySystem {
  Uint8List byteFrequencyData;
  RenderingContext gl;

  MusicVisualisationSystem(this.gl, this.byteFrequencyData);

  @override
  void processSystem() {
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
      items[index] = -1.0 + i * width;
      items[index + 1] = -byteFrequencyData[i] * height;
      items[index + 2] = byteFrequencyData[i].toDouble();

      items[index + 3] = -1.0 + i * width + width;
      items[index + 4] = -byteFrequencyData[i] * height;
      items[index + 5] = byteFrequencyData[i].toDouble();

      items[index + 6] = -1.0 + i * width + width;
      items[index + 7] = byteFrequencyData[i] * height;
      items[index + 8] = byteFrequencyData[i].toDouble();

      items[index + 9] = -1.0 + i * width;
      items[index + 10] = byteFrequencyData[i] * height;
      items[index + 11] = byteFrequencyData[i].toDouble();

      indices[i * 6] = index;
      indices[i * 6 + 1] = index + 3;
      indices[i * 6 + 2] = index + 6;
      indices[i * 6 + 3] = index;
      indices[i * 6 + 4] = index + 6;
      indices[i * 6 + 5] = index + 9;
    }
    bufferElements(attributes, items, indices);

    gl.drawElements(RenderingContext.TRIANGLES, byteFrequencyData.length * 2, RenderingContext.UNSIGNED_SHORT, 0);
  }

  @override
  String get fShaderFile => 'EqualizerSystem';

  @override
  String get vShaderFile => 'EqualizerSystem';
}

class BlockRenderingSystem extends WebGlRenderingSystem {
  Mapper<Position> pm;
  Mapper<Color> cm;

  Float32List items;
  Uint16List indices;
  List<Attrib> attributes;

  BlockRenderingSystem(RenderingContext gl) : super(gl, Aspect.getAspectForAllOf([Position, Color])) {
    attributes = [new Attrib('aPosition', 2), new Attrib('aColor', 3)];
  }

  @override
  void processEntity(int index, Entity entity) {
    var p = pm[entity];
    var c = cm[entity];

    var offset = 5 * index;

    items[offset] = p.x;
    items[offset + 1] = p.y;
    items[offset + 2] = c.r;
    items[offset + 3] = c.g;
    items[offset + 4] = c.b;

    indices[index] = index;
  }

  @override
  void render(int length) {
    bufferElements(attributes, items, indices);

    gl.drawElements(POINTS, length, UNSIGNED_SHORT, 0);
  }

  @override
  void updateLength(int length) {
    indices = new Uint16List(length);
    items = new Float32List(length * 5);
  }

  @override
  String get vShaderFile => 'BlockRenderingSystem';
  @override
  String get fShaderFile => 'BlockRenderingSystem';
}
