part of particles;

class ParticleDisplay extends Sprite {
  final ParticlePool pool = new ParticlePool(100);
  final List<Particle> activeParticles = new List();
  
  ParticleDisplay() {
    onEnterFrame.listen((event) => _update(event.passedTime));
//    this.filters.add(new BlurFilter(8, 8));
  }
  
  num timeElapsed = 0;
  void _update(num dt) {
    timeElapsed += dt;
    final newParticles = new List();
    activeParticles.removeWhere((particle) {
      particle.update(dt);
      
      if (particle.trailMixin != null) {
        final trail = particle.trailMixin.createTrailParticle(pool, dt, particle.x, particle.y);
        if (trail != null) newParticles.add(trail);
      }
      
      final isDead = !particle.stillAlive();
      if (isDead) {
        if (particle.explosionMixin != null) {
          particle.explosionMixin.explode(pool, particle.x, particle.y).forEach((newParticle) {
            newParticles.add(newParticle);
          });
        }
        removeChild(particle); //O(n)...
        pool.returnToPool(particle);
      }
      return isDead;
    });
    
    if (newParticles.isNotEmpty) addAll(newParticles);
  }
  
  void add(Particle particles) {
    addChild(particles);
    activeParticles.add(particles);
  }
  
  void addAll(List<Particle> particles) {
   activeParticles.addAll(particles);
   activeParticles.forEach((_) => _.addTo(this));
  }
}