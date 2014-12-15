part of particles;

class Interval {  
  final next;
  
  Interval(num this.next());
  
  Interval.uniform(num min, num max) : next = (() => range(min, max));
  
  Interval.constant(num constant) : next = (() => constant);
  
  //see http://en.wikipedia.org/wiki/Marsaglia_polar_method
  factory Interval.normal({num mean: 0, num sd: 1, num min: -double.MAX_FINITE}) {
    num storedValue;
    bool hasStored = false;
    num normalDist() {
      if (hasStored) {
        hasStored = false;
        return max(mean + sd * storedValue, min);
      }
      
      while (true) {
        final x = 2 * rand.nextDouble() - 1;
        final y = 2 * rand.nextDouble() - 1;
        final s = x * x + y * y;
        if (s < 1) {
          final squareRootTerm = sqrt(-2 * log(s) / s);
          storedValue = x * squareRootTerm;
          hasStored = true;
          return max(mean + sd * y * squareRootTerm, min);
        }
      }
    }
    return new Interval(normalDist);
  }
}

