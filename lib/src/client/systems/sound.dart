part of client;

class BackgroundMusicSystem extends VoidEntitySystem {
  BeatFactorSystem bfs;
  AudioContext audioContext;
  AnalyserNode analyser;
  AudioBuffer kick;
  AudioBuffer snare;
  AudioBuffer hihat;
  Uint8List byteFrequencyData;
  InputElement mute = querySelector('#mute');
  InputElement musicFile = querySelector('#music');

  BackgroundMusicSystem(this.audioContext, this.byteFrequencyData);

  @override
  void initialize() {
    analyser = audioContext.createAnalyser();
    analyser.fftSize = byteFrequencyData.length * 2;
    var sounds = <Future<HttpRequest>>[];
    sounds.add(HttpRequest.request('packages/zfx_action_7/assets/sfx/237581__frankum__ambient-electro-loop.ogg',
        responseType: 'arraybuffer'));
    var source = audioContext.createBufferSource();
    Future.wait(sounds).then((requests) {
      var audioBuffers = <Future<AudioBuffer>>[];
      requests.forEach((request) {
        audioBuffers.add(audioContext.decodeAudioData(request.response));
      });
      Future.wait(audioBuffers).then((buffers) {
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
    musicFile.accept = "";
    var formats = <String>[];
    var audio = new AudioElement();
    var goodAnswer = ['probably', 'maybe'];
    if (goodAnswer.contains(audio.canPlayType('audio/ogg'))) {
      formats.add('audio/ogg');
    }
    if (goodAnswer.contains(audio.canPlayType('audio/mp3'))) {
      formats.add('audio/mp3');
    }
    musicFile.accept = formats.join(',');
    musicFile.onChange.listen((data) {
      var files = data.target.files as List<File>;
      if (files.isNotEmpty) {
        var reader = new FileReader();
        reader.onLoadEnd.listen((event) {
          if (reader.readyState == FileReader.DONE) {
            audioContext.decodeAudioData(reader.result.buffer).then((audioBuffer) {
              source.buffer = audioBuffer;
              bfs.maxBeat = 1.0;
            });
          }
        });

        reader.readAsArrayBuffer(files[0].slice(0, files[0].size));
      }
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
