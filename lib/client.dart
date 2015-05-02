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

  void createEntities() {
  }

  List<EntitySystem> getSystems() {
    return [
      new BlockSpawnerSystem(),
      new BlockMovementSystem(),

      new BackgroundMusicSystem(audioContext, byteFrequencyData),
      new MusicVisualisationSystem(ctx, byteFrequencyData),
      new EqualizerSystem(ctx, byteFrequencyData),
      new BlockRenderingSystem(ctx, byteFrequencyData),

      new BlockDestructionSystem(),
    ];
  }
}
