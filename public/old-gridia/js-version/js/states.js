function MovingState(dx, dy) {
  this.dx = dx;
  this.dy = dy;
  this.update = function (hero, delta) {
    var speed = (dx !== 0 && dy !== 0) ? 0.7 * hero.speed : hero.speed;
    if (16 in keysDown) speed *= 2;
    hero.tx += dx * speed * delta;
    hero.ty += dy * speed * delta;
    if (dx !== 0 && Math.abs(hero.tx) >= 32 || dy !== 0 && Math.abs(hero.ty) >= 32) {
      hero.x += dx;
      hero.y += dy;
      hero.tx = hero.ty = 0;
      hero.x = game.map.wrap(hero.x);
      hero.y = game.map.wrap(hero.y);
      hero.state = waitingState;
    }
  };
}

var waitingState = {
  update : function (hero) {
    var dx = 0, dy = 0;
    if (38 in keysDown || 87 in keysDown) dy = -1;
    if (40 in keysDown || 83 in keysDown) dy = 1;
    if (37 in keysDown || 65 in keysDown) dx = -1;
    if (39 in keysDown || 68 in keysDown) dx = 1;
    if ((dx !== 0 || dy !== 0) && game.isWalkable(hero.x + dx, hero.y + dy))
      hero.state = new MovingState(dx, dy);
  }
};