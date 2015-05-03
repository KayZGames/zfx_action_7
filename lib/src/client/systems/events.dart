part of client;

class InputHandlingSystem extends GenericInputHandlingSystem {
  Mapper<Controller> cm;
  GameStateManager gsm;
  BlockMovementSystem bms;
  BlockSpawnerSystem bss;

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
    if (down) {
      bms.accelerate = 7.5;
      bss.accelerate = 7.5;
    } else {
      bms.accelerate = 1.0;
      bss.accelerate = 1.0;
    }
  }
}
