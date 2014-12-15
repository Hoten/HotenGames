part of particles;

class ParticleEmitter {
  final Interval sizeI, gravityI, dragI, colorI, fadeI, lifeI;
  final TrailMixin trailMixin;
  final ExplosionMixin explosionMixin;
  final explosionMixinClosure;
  
  ParticleEmitter({this.sizeI, this.gravityI, this.dragI, this.colorI, this.fadeI,
    this.lifeI, this.trailMixin, this.explosionMixin, ExplosionMixin this.explosionMixinClosure()})
  {
    if (sizeI == null) throw new ArgumentError("sizeI must be given");
    if (gravityI == null) throw new ArgumentError("gravityI must be given");
    if (dragI == null) throw new ArgumentError("dragI must be given");
    if (colorI == null) throw new ArgumentError("colorI must be given");
    if (fadeI == null) throw new ArgumentError("fadeI must be given");
    if (lifeI == null) throw new ArgumentError("lifeI must be given");
  }
  
  Particle create(ParticlePool pool, num x, num y) {
    return pool.create(
      x: x,
      y: y,
      size: sizeI.next(),
      color: colorI.next(),
      numRings: 4,
      growth: 1,
      drag: dragI.next(),
      fade: fadeI.next(),
      life: lifeI.next(),
      gravity: gravityI.next(),
      trailMixin: trailMixin,
      explosionMixin: explosionMixinClosure != null ? explosionMixinClosure() : explosionMixin
    );
  }
}