//see http://www.calculushumor.com/3/post/2012/11/the-batman-curve.html

part of particles;

class BatmanExplosion extends ParametricExplosion {
  
  factory BatmanExplosion({ParticleEmitter emitter, Interval numParticlesI, Interval thetaOffsetI, Interval sizeI}) {
    //TODO: benchmark and find out if (x - a) * (x - a) is faster than pow(x-a, 2)
    
    //bottom sides
    num g(num x) {
      return -3 * sqrt(1 - pow(x / 7, 2));
    }
    
    //bottom curves
    num h(num x) {
      final xabs = x.abs();
      return xabs / 2 - 0.0913722 * x * x - 3 + sqrt(1 - pow((xabs - 2).abs() - 1, 2));
    }
    
    //top dips
    num j(num x) {
      final xabs = x.abs();
      return 5.11052 - xabs / 2 - 1.35526 * sqrt(4 - pow(xabs - 1, 2));
    }
    
    //top sides
    num f(num x) {
      final xabs = x.abs();
      return 2 * sqrt(1 - pow(x / 7, 2)) * (1 + (xabs - 3).abs() / (xabs - 3));
    }
    
    //top ears
    num e(num x) {
      final xabs = x.abs();
      return (5 + 0.97 * ((x - 0.5).abs() + (x + 0.5).abs() - 3 * ((x - 0.75).abs() + (x + 0.75).abs()))) * (1 + (1 - xabs).abs() / (1 - xabs));
    }
    
    //ensures that the slopes of the ears are emphasized
    final amount = 0.2; //amount to redirect to slopes of ears
    num tTransform(num t) {
      if (t <= 1 - amount) {
        return t / (1 - amount);
      } else {
        t = (1 - t) / amount;
        return 0.21 + ((t * 2) % 1) / 35 + (t >= 0.5 ? 1/20 : 0);
      }
    }
    
    num tToX(num t) {
      return (t > 0.5 ? t - 0.5 : t) * 2 - 0.5;
    }
    
    num xt(num _t) {
      final t = tTransform(_t);
      return tToX(t);
    }
    
    num yt(num _t) {
      final t = tTransform(_t);
      final x = tToX(t) * 14;
      
      num y;
      
      if (t > 0.5) {
        //bottom half
        if (x >= 4 || x <= -4) y = g(x);
        else y = h(x);
      } else {
        //top half
        if ((x >= -3 && x <= -1) || (x >= 1 && x <= 3)) y = j(x);
        else if (x >= 3.5 || x <= -3.5) y = f(x);
        else y = e(x);
      } 
      
      return -y / 14;
    }
    
    return new BatmanExplosion._private(xt: xt, yt: yt, emitter: emitter, numParticlesI: numParticlesI, thetaOffsetI: thetaOffsetI, sizeI: sizeI);
  }
  
  BatmanExplosion._private({num xt(num t), num yt(num t), ParticleEmitter emitter, Interval numParticlesI, Interval thetaOffsetI, Interval sizeI}) :
    super(xt: xt, yt: yt, emitter: emitter, numParticlesI: numParticlesI, thetaOffsetI: thetaOffsetI, sizeI: sizeI);
}