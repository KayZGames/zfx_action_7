part of client;

class BackgroundMusicSystem extends VoidEntitySystem {
  AudioContext audioContext;
  AnalyserNode analyser;
  AudioBuffer kick;
  AudioBuffer snare;
  AudioBuffer hihat;
  Uint8List byteFrequencyData;

  BackgroundMusicSystem(this.audioContext, this.byteFrequencyData);

  @override
  void initialize() {
    analyser = audioContext.createAnalyser();
    analyser.fftSize = byteFrequencyData.length * 2;
    var sounds = <Future<HttpRequest>>[];
    sounds.add(HttpRequest.request('packages/zfx_action_7/assets/sfx/237581__frankum__ambient-electro-loop.ogg', responseType: 'arraybuffer'));
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
        source.connectNode(audioContext.destination);
        source.connectNode(analyser);
        source.loop = true;
        source.start(time);
      });
    });
  }

  @override
  void processSystem() {
    analyser.getByteFrequencyData(byteFrequencyData);
  }

  void playSound(buffer, startTime, delay) {
    var source = audioContext.createBufferSource();
    source.buffer = buffer;
    source.connectNode(audioContext.destination);
    source.connectNode(analyser);
    source.start(time);
  }
}
