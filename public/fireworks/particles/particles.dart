library particles;

import 'package:stagexl/stagexl.dart';
import 'dart:math' hide Point;

part 'particle.dart';
part 'emitter.dart';
part 'particle-display.dart';
part 'particle-pool.dart';
part 'explosion-mixin.dart';
part 'trail-mixin.dart';
part 'shape.dart';
part 'interval.dart';
part 'batman-explosion.dart';
part 'particle-emitter.dart';

final Random rand = new Random();
const num PI2 = PI * 2;
num range(num min, num max) => rand.nextDouble() * (max - min) + min;