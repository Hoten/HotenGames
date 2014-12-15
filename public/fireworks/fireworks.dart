import 'dart:html' as html;
import 'package:stagexl/stagexl.dart' hide Shape;
import 'particles/particles.dart';
import 'dart:math' hide Point;

final stage = new Stage(html.querySelector("#stage"), color: Color.Transparent);
final display = new ParticleDisplay();

void main() {
  stage.scaleMode = StageScaleMode.NO_SCALE;
  stage.align = StageAlign.TOP_LEFT;
  
  var resourceManager = new ResourceManager()
      ..addBitmapData('moon', 'images/moon.png');

  resourceManager.load().then((result) {
    var moon = new Bitmap(resourceManager.getBitmapData('moon'));
    moon.alpha = 0.6;
    
    stage.addChild(moon);
    stage.addChild(display);
    
    new RenderLoop().addStage(stage);
    start();
  });
}

void start() {
  initializeFireworksSelection();
  final fireworkInterval = 1.5;
  final xI = new Interval.normal(mean: stage.stageWidth / 2, sd: 200);
  var constantLaunching = true;
  var timeElapsed = 0.0;
  
  stage.onEnterFrame.listen((event) {
    if (timeElapsed > 5) timeElapsed = 0;
    timeElapsed += event.passedTime;
    if (timeElapsed >= fireworkInterval && constantLaunching) {
      timeElapsed -= fireworkInterval;
      final x = xI.next();
      final y = range(stage.stageHeight / 3, stage.stageHeight / 3 * 2);
      createFireworks(new Point(x, y));
    }
  });
    
  html.querySelector("body").onClick.listen((event) {
    createFireworks(new Point(event.client.x, event.client.y));
  });
  
  html.querySelector("body").onKeyUp.listen((event) {
    if (event.keyCode == html.KeyCode.SPACE) constantLaunching = !constantLaunching;
  });
}

final List<ParticleEmitter> fireworksSelection = [];

void initializeFireworksSelection() {
  final pool = display.pool;
  
  //define common components
  final sizeI = new Interval.normal(mean: 2.5, sd: 0.5, min: 1);
  final colorI = new Interval(randomLightColor);
  final dragI = new Interval.constant(1);
  final gravityI = new Interval.constant(10);
  final fadeI = new Interval.constant(0);
  final lifeI = new Interval.constant(1);
  final trailMixin = new DefaultTrail(colorI: colorI, frequency: 0.005);
  final PI2 = PI * 2;
  
  //common explosion components
  final explosionEmitter = new ParticleEmitter(
    sizeI: sizeI, colorI: colorI, dragI: new Interval.constant(0.1), fadeI: new Interval.constant(0.95),
    gravityI: new Interval.constant(100), lifeI: lifeI, trailMixin: new DefaultTrail(colorI: colorI, frequency: 0.1),
    explosionMixin: null
  );
  final thetaOffsetI = new Interval.uniform(-PI / 4, PI / 4);
  final numParticlesI = new Interval.normal(mean: 25, sd: 8, min: 5);
  final numParticlesI_2 = new Interval.normal(mean: 45, sd: 8, min: 20);
  final explosionSizeI = new Interval.normal(mean: 150, sd: 25, min: 20);
  
  //begin designing fireworks
  
  //a square explosion
  final squareVertices = [
    new Point(-0.5, 0.5), new Point(-0.5, -0.5),
    new Point(0.5, -0.5), new Point(0.5, 0.5)
  ];
  fireworksSelection.add(new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixin: new ShapeExplosion(
      shape: new Shape(squareVertices), emitter: explosionEmitter,
      numParticlesI: numParticlesI, thetaOffsetI: thetaOffsetI, sizeI: explosionSizeI
    )
  ));
  
  //a circular explosion
  fireworksSelection.add(new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixin: new RingExplosion(
      emitter: explosionEmitter, numParticlesI: numParticlesI,
      thetaOffsetI: thetaOffsetI, sizeI: explosionSizeI
    )
  ));
  
  //a star explosion
  fireworksSelection.add(new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixinClosure: () {
      final p = range(5, 10).toInt();
      final q = range(2, 3).toInt();
      return new ShapeExplosion(
        shape: new Shape.star(p, q, 1), emitter: explosionEmitter, thetaOffsetI: thetaOffsetI,
        numParticlesI: numParticlesI_2, sizeI: explosionSizeI
      );
    } 
  ));
  
  //an elliptic explosion
  fireworksSelection.add(new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixinClosure: () {
      return new ParametricExplosion.ellipse(
        xyRatio: rand.nextBool() ? range(0.6, 0.85) : 1 - range(0.6, 0.85), sizeI: explosionSizeI,
        numParticlesI: numParticlesI_2,
        emitter: explosionEmitter, thetaOffsetI: thetaOffsetI
      );
    }
  ));
  
  //a heart explosion
  fireworksSelection.add(new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixin: new ParametricExplosion(
      xt: (t) => pow(sin(t * PI2), 3),
      yt: (t) => -(13 * cos(t * PI2) - 5 * cos(2 * t * PI2) - 2 * cos(3 * t * PI2) - cos(4 * t * PI2)) / 16,
      numParticlesI: numParticlesI_2, emitter: explosionEmitter,
      thetaOffsetI: thetaOffsetI, sizeI: explosionSizeI
    )
  ));
  
  //a batman explosion
  fireworksSelection.add(new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixin: new BatmanExplosion(
      sizeI: new Interval.normal(mean: 300, sd: 50, min: 150), emitter: explosionEmitter,
      thetaOffsetI: thetaOffsetI, numParticlesI: new Interval.normal(mean: 60, sd: 10, min: 40)
    )
  ));
  
  //okay so now here are some explosions using some cool parametric equations
    
  //astroid
  fireworksSelection.add(new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixin: new ParametricExplosion(
      xt: (t) { final cost = cos(t * PI2); return cost * cost * cost; },
      yt: (t) { final sint = sin(t * PI2); return sint * sint * sint; },
      numParticlesI: numParticlesI_2, emitter: explosionEmitter,
      thetaOffsetI: thetaOffsetI, sizeI: explosionSizeI
    )
  ));
  
  //nephroid
  fireworksSelection.add(new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixinClosure: () {
      final a = range(0.25, 1.0);
      final b = a / 2;
      return new ParametricExplosion(
        xt: (t) => (a + b) * cos(t * PI2 * 2) - b * cos(t * PI2 * 2 * (a / b + 1)),
        yt: (t) => (a + b) * sin(t * PI2 * 2) - b * sin(t * PI2 * 2 * (a / b + 1)),
        numParticlesI: numParticlesI_2, emitter: explosionEmitter,
        thetaOffsetI: thetaOffsetI, sizeI: explosionSizeI
      );
    }
  ));
  
  //involute of a circle
  fireworksSelection.add(new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixin: new ParametricExplosion(
      xt: (t) { final T = t * PI2 * 2; return cos(T) + T * sin(T); },
      yt: (t) { final T = t * PI2 * 2; return sin(T) - T * cos(T); },
      numParticlesI: numParticlesI_2, emitter: explosionEmitter,
      thetaOffsetI: thetaOffsetI, sizeI: new Interval.normal(mean: 15, sd: 5, min: 5)
    )
  ));
  
  //triscuspoid
  fireworksSelection.add(new ParticleEmitter(
    sizeI: sizeI, gravityI: gravityI, dragI: dragI, colorI: colorI,
    fadeI: fadeI, trailMixin: trailMixin, lifeI: lifeI,
    explosionMixin: new ParametricExplosion(
      xt: (t) { final T = t * PI2; return cos(T) + cos(2 * T) / 2; },
      yt: (t) { final T = t * PI2; return sin(T) - sin(2 * T) / 2; },
      numParticlesI: numParticlesI_2, emitter: explosionEmitter,
      thetaOffsetI: thetaOffsetI, sizeI: explosionSizeI
    )
  ));
}

void createFireworks(Point destination) {
  final speed = range(400, 700);
  final origin = new Point(new Interval.normal(mean: stage.stageWidth / 2, sd: 100).next(), stage.stageHeight);
  final positionDelta = destination.subtract(origin);
  final theta = atan2(positionDelta.y, positionDelta.x);
  final distanceToTravel = positionDelta.length;
  final travelTime = distanceToTravel / speed;
  final velocity = new Point(speed * cos(theta), speed * sin(theta));
  final Particle particle = fireworksSelection[rand.nextInt(fireworksSelection.length)].create(display.pool, origin.x, origin.y);
  particle
      ..xVel = velocity.x
      ..yVel = velocity.y
      ..life = travelTime;
  display.add(particle);
}

//generates a random color of a light pallete by averaging a random color with white
int randomLightColor() => 0xff000000 | (range(0, 255) + 255) ~/ 2 | (range(0, 255) + 255) ~/ 2 << 8 | (range(0, 255) + 255) ~/ 2 << 16;