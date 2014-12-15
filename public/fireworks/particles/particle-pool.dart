part of particles;

class ParticlePool {
  final List<Particle> pool;
  
  ParticlePool([int initialSize = 100]) : pool = new List.generate(initialSize, (_) => new Particle._private());

  Particle createFrom(Particle mold) =>
    create(x: mold.x, y: mold.y, size: mold.scaleX, color: mold.color,
      numRings: mold.numRings, life: mold.life, growth: mold.growth,
      drag: mold.drag, xVel: mold.xVel, yVel: mold.yVel, fade: mold.fade,
      onStartDeath: mold._onStartDeath, duringDeath: mold._duringDeath,
      flickerRate: mold.flickerRate, explosionMixin: mold.explosionMixin,
      trailMixin: mold.trailMixin);
  
  Particle create(
  {
    x: 0.0,
    y: 0.0,
    size: 1.0,
    color: Color.White,
    numRings: 3,
    life: 3,
    growth: 1,
    drag: 1,
    xVel: 0,
    yVel: 0,
    fade: 0,
    gravity: 0,
    flickerRate: 0,
    explosionMixin: null,
    trailMixin: null,
    void onStartDeath(Particle p): null,
    void duringDeath(Particle p, double dt): null
  })
  {
    onStartDeath = onStartDeath == null ? (Particle p) => p.fade = 3 : onStartDeath;
    duringDeath = duringDeath == null ? (Particle p, double dt) {} : duringDeath;
    final p = pool.isNotEmpty ? pool.removeLast() : new Particle._private();
    p.init(x: x, y: y, size: size, color: color, numRings: numRings, life: life,
      growth: growth, drag: drag, xVel: xVel, yVel: yVel, flickerRate: flickerRate,
      fade: fade, gravity: gravity, onStartDeath: onStartDeath, duringDeath: duringDeath,
      explosionMixin: explosionMixin, trailMixin: trailMixin);
    return p;
  }
  
  void returnToPool(Particle particle) {
    pool.add(particle);
  }
}