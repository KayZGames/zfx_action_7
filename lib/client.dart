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

  Game() : super.noAssets('zfx_action_7', 'canvas', 800, 600, webgl: true);

  void createEntities() {}

  Map<int, List<EntitySystem>> getSystems() {
    return {
      0: [
        new BackgroundMusicSystem(audioContext, byteFrequencyData),
        new BeatFactorSystem(byteFrequencyData),
        new MusicVisualisationSystem(ctx, byteFrequencyData),
        new EqualizerSystem(ctx, byteFrequencyData),
        new GridRenderingSystem(ctx),
        new DefaultBlockRenderingSystem(ctx),
        new StickyBlockRenderingSystem(ctx),
      ],
      1: [
        new BlockSpawnerSystem(),
        new BlockMovementSystem(),
        new BlockConversionSystem(),
        new BlockDestructionSystem(),
        new DelayedExplosionSystem(),
      ]
    };
  }

  onInit() {
    world.addManager(new GridManager());
  }
}
