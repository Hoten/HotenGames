part of particles;

abstract class ExplosionMixin {
  final ParticleEmitter emitter;
  final Interval numParticlesI;
  final Interval thetaOffsetI;
  final Interval sizeI;
  
  ExplosionMixin({this.emitter, this.numParticlesI, this.thetaOffsetI, this.sizeI}) {
    if (emitter == null) throw new ArgumentError("emitter must be given");
    if (numParticlesI == null) throw new ArgumentError("numParticlesI must be given");
    if (thetaOffsetI == null) throw new ArgumentError("thetaOffsetI must be given");
    if (sizeI == null) throw new ArgumentError("sizeI must be given");
  }

  List<Particle> explode(ParticlePool pool, num x, num y);

  /*
   * dist = integral of initialSpeed * drag^t * dt from 0 to 1
   *      = (drag - 1) * initialSpeed / ln(drag)
   * solve for necessary initial speed given following constraints:
   * (1) particle's speed is multiplied by a drag value w/ respect to time
   * (2) given the particle lives long enough, it will stop moving at
   *     a distance of 'dist' from the center
   */
  //TODO: account for explosion durations other than 1
  num _calculateSpeed(num dist, num drag) => dist * log(drag) / (drag - 1);
}

class RingExplosion extends ExplosionMixin {
  RingExplosion({ParticleEmitter emitter, Interval numParticlesI, Interval thetaOffsetI, Interval sizeI}) :
    super(emitter: emitter, numParticlesI: numParticlesI, thetaOffsetI: thetaOffsetI, sizeI: sizeI);
  
  List<Particle> explode(ParticlePool pool, num x, num y) {
    final mold = emitter.create(pool, x, y);
    final radius = sizeI.next();
    final speed = _calculateSpeed(radius, mold.drag);
    final thetaOffset = thetaOffsetI.next();
    final numParticles = numParticlesI.next().toInt();
    
    return new List.generate(numParticles, (i) {
      final theta = PI2 * i / numParticles + thetaOffset;
      
      final particle = pool.createFrom(mold);
      particle
          ..xVel = speed * cos(theta)
          ..yVel = speed * sin(theta);
      return particle;
    });
  }
}

class ShapeExplosion extends ExplosionMixin {
  final Shape shape;
  
  ShapeExplosion({this.shape, ParticleEmitter emitter, Interval numParticlesI, Interval thetaOffsetI, Interval sizeI}) :
    super(emitter: emitter, numParticlesI: numParticlesI, thetaOffsetI: thetaOffsetI, sizeI: sizeI);
  
  List<Particle> explode(ParticlePool pool, num x, num y) {
    final mold = emitter.create(pool, x, y);
    final size = sizeI.next();
    var runningLength = 0;
    var currentIndex = 0;
    final thetaOffset = thetaOffsetI.next();
    final numParticles = numParticlesI.next().toInt();
    
    return new List.generate(numParticles, (i) {
      while ((shape.lengths[currentIndex] + runningLength) / shape.perimeter < i / numParticles ) {
        runningLength += shape.lengths[currentIndex];
        currentIndex++;
      }
            
      final currentLength = shape.lengths[currentIndex];
      final currentPercentage = (runningLength) / shape.perimeter;
      final nextPercentage = (currentLength + runningLength) / shape.perimeter;
      final interpolated = (i / numParticles - currentPercentage) / (nextPercentage - currentPercentage);
      
      final dir = shape.directions[currentIndex];
      final point = new Point(shape.vertices[currentIndex].x + dir.x * currentLength * interpolated, shape.vertices[currentIndex].y + dir.y * currentLength * interpolated);
      point.x *= size;
      point.y *= size;
      final distance = point.length;
      final theta = atan2(point.y, point.x) + thetaOffset;
      final speed = _calculateSpeed(distance, mold.drag);
      
      final particle = pool.createFrom(mold);
      particle
          ..xVel = speed * cos(theta)
          ..yVel = speed * sin(theta);
      return particle;
    });
  }
}

class ParametricExplosion extends ExplosionMixin {
  final xt, yt;
  
  ParametricExplosion({num this.xt(num t), num this.yt(num t), ParticleEmitter emitter, Interval numParticlesI, Interval thetaOffsetI, Interval sizeI}) :
    super(emitter: emitter, numParticlesI: numParticlesI, thetaOffsetI: thetaOffsetI, sizeI: sizeI);
  
  //TODO: fix sizing
  ParametricExplosion.ellipse({num xyRatio, ParticleEmitter emitter, Interval numParticlesI, Interval thetaOffsetI, Interval sizeI}) :
    super(emitter: emitter, numParticlesI: numParticlesI, thetaOffsetI: thetaOffsetI, sizeI: sizeI),
    xt = ((t) => xyRatio * cos(t * PI2)),
    yt = ((t) => (1 - xyRatio) * sin(t* PI2));
  
  List<Particle> explode(ParticlePool pool, num x, num y) {
    final mold = emitter.create(pool, x, y);
    final size = sizeI.next();
    var runningLength = 0;
    var currentIndex = 0;
    final thetaOffset = thetaOffsetI.next();
    final numParticles = numParticlesI.next().toInt();
    
    return new List.generate(numParticles, (i) {
      final t = i / numParticles;
      final point = new Point(size * xt(t), size * yt(t));
      final distance = point.length;
      final theta = atan2(point.y, point.x) + thetaOffset;
      final speed = _calculateSpeed(distance, mold.drag);
      
      final particle = pool.createFrom(mold);
      particle
          ..xVel = speed * cos(theta)
          ..yVel = speed * sin(theta);
      return particle;
    });
  }
}