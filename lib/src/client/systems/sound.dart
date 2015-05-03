part of client;

class BackgroundMusicSystem extends VoidEntitySystem {
  AudioContext audioContext;
  AnalyserNode analyser;
  AudioBuffer kick;
  AudioBuffer snare;
  AudioBuffer hihat;
  Uint8List byteFrequencyData;
  InputElement mute = querySelector('#mute');

  BackgroundMusicSystem(this.audioContext, this.byteFrequencyData);

  @override
  void initialize() {
    analyser = audioContext.createAnalyser();
    analyser.fftSize = byteFrequencyData.length * 2;
    var sounds = <Future<HttpRequest>>[];
    sounds.add(HttpRequest.request('packages/zfx_action_7/assets/sfx/237581__frankum__ambient-electro-loop.ogg',
        responseType: 'arraybuffer'));
//    sounds.add(HttpRequest.request('packages/zfx_action_7/assets/sfx/misanthropy.ogg', responseType: 'arraybuffer'));
//    sounds.add(HttpRequest.request('packages/zfx_action_7/assets/sfx/26903__vexst__snare-4.ogg', responseType: 'arraybuffer'));
//    sounds.add(HttpRequest.request('packages/zfx_action_7/assets/sfx/26880__vexst__closed-hi-hat-2.ogg', responseType: 'arraybuffer'));
    Future.wait(sounds).then((requests) {
      var audioBuffers = <Future<AudioBuffer>>[];
      requests.forEach((request) {
        audioBuffers.add(audioContext.decodeAudioData(request.response));
      });
      Future.wait(audioBuffers).then((buffers) {
        var source = audioContext.createBufferSource();
        source.buffer = buffers[0];
        if (!mute.checked) {
          source.connectNode(audioContext.destination);
        }
        source.connectNode(analyser);
        source.loop = true;
        source.start(0);
        mute.onChange.listen((data) {
          if (mute.checked) {
            source.disconnect(0);
            source.connectNode(analyser);
          } else {
            source.connectNode(audioContext.destination);
          }
        });
      });
    });
  }

  @override
  void processSystem() {
    analyser.getByteFrequencyData(byteFrequencyData);
  }
}

class SoundSystem extends EntityProcessingSystem {
  Mapper<SoundEffect> sm;
  BackgroundMusicSystem bms;

  AudioContext audioContext;
  Map<String, List<AudioBuffer>> sounds = {'explode': []};
  InputElement mute = querySelector('#mute');

  SoundSystem(this.audioContext) : super(Aspect.getAspectForAllOf([SoundEffect]));

  @override
  void initialize() {
    for (int i = 0; i < 3; i++) {
      HttpRequest
          .request('packages/zfx_action_7/assets/sfx/179265__jorickhoofd__exploding-lightbulb-1-$i.ogg',
              responseType: 'arraybuffer')
          .then((request) {
        audioContext.decodeAudioData(request.response).then((buffer) {
          sounds['explode'].add(buffer);
        });
      });
    }
  }

  @override
  void processEntity(Entity entity) {
    var s = sm[entity];
    var buffers = sounds[s.name];
    if (buffers.isNotEmpty) {
      var source = audioContext.createBufferSource();
      source.buffer = buffers[random.nextInt(buffers.length)];
      if (!mute.checked) {
        source.connectNode(audioContext.destination);
      }
      source.connectNode(bms.analyser);
      source.start(0);
      source.loop = false;
      mute.onChange.listen((data) {
        if (mute.checked) {
          source.disconnect(0);
          source.connectNode(bms.analyser);
        } else {
          source.connectNode(audioContext.destination);
        }
      });
    }
    entity.deleteFromWorld();
  }
}
