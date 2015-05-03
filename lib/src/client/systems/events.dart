part of client;

class InputHandlingSystem extends GenericInputHandlingSystem {
  Mapper<Controller> cm;
  GameStateManager gsm;

  InputHandlingSystem() : super(Aspect.getAspectForAllOf([Controller]));

  @override
  void initialize() {
    super.initialize();
    querySelector('#hud').onClick.listen((_) {
      if (gsm.gameOver) {
        gsm.restart();
      }
    });
  }

  @override
  void processEntity(Entity entity) {
    var c = cm[entity];
    if (left) {
      unpress[KeyCode.LEFT] = true;
      unpress[KeyCode.A] = true;
      c.direction = -1;
    } else if (right) {
      unpress[KeyCode.RIGHT] = true;
      unpress[KeyCode.D] = true;
      c.direction = 1;
    } else {
      c.direction = 0;
    }
  }
}
