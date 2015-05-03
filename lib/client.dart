library client;

import 'dart:html' hide Player, Timeline;
import 'dart:web_audio';
import 'dart:typed_data';
import 'dart:web_gl';

import 'package:zfx_action_7/shared.dart';

import 'package:gamedev_helpers/gamedev_helpers.dart';
export 'package:gamedev_helpers/gamedev_helpers.dart';

//part 'src/client/systems/name.dart';
part 'src/client/systems/events.dart';
part 'src/client/systems/rendering.dart';
part 'src/client/systems/sound.dart';

class Game extends GameBase {
  AudioContext audioContext = new AudioContext();
  Uint8List byteFrequencyData = new Uint8List(1024);
  CanvasElement hudCanvas;
  CanvasRenderingContext2D hudCtx;

  Game() : super.noAssets('zfx_action_7', 'canvas', 800, 600, webgl: true) {
    hudCanvas = querySelector('#hud');
    hudCtx = hudCanvas.context2D;
    hudCtx..textBaseline = 'top'
          ..font = '16px Verdana';
  }

  void createEntities() {
    addEntity([new Controller()]);
  }

  Map<int, List<EntitySystem>> getSystems() {
    return {
      0: [
        new BackgroundMusicSystem(audioContext, byteFrequencyData),
        new BeatFactorSystem(byteFrequencyData),
        new MusicVisualisationSystem(ctx, byteFrequencyData),
        new EqualizerSystem(ctx, byteFrequencyData),
        new GridRenderingSystem(ctx),
        new BlockRenderingSystem(ctx),
        new ParticleRenderingSystem(ctx),
        new CanvasCleaningSystem(hudCanvas),
        new ScoreRenderingSystem(hudCtx),
      ],
      1: [
        new InputHandlingSystem(),
        new ControllerSystem(),

        new BlockSpawnerSystem(),
        new MovementSystem(),
        new BlockMovementSystem(),
        new FallingBlockPositionUpdatingSystem(),
        new BlockConversionSystem(),
        new StickyBlockPositionUpdatingSystem(),
        new GravitySystem(),

        new BlockDestructionSystem(),
        new DelayedExplosionSystem(),
        new ScoreSystem(),
      ]
    };
  }

  onInit() {
    world.addManager(new GridManager());
    world.addManager(new GameStateManager());
  }
}

List<double> hslToRgb(double h, double s, double l) {
  double r, g, b;
  if (s == 0.0) {
    r = g = b = l;
  } else {
    num q = l < 0.5 ? l * (1 + s) : l + s - l * s;
    num p = 2 * l - q;
    r = hue2rgb(p, q, h + 1 / 3);
    g = hue2rgb(p, q, h);
    b = hue2rgb(p, q, h - 1 / 3);
  }
  return [r, g, b];
}

num hue2rgb(num p, num q, num t) {
  if (t < 0) t += 1;
  if (t > 1) t -= 1;
  if (t < 1 / 6) return p + (q - p) * 6 * t;
  if (t < 1 / 2) return q;
  if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
  return p;
}
