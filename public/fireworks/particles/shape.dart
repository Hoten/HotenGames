part of particles;

class Shape {
  
  static List<Point> _getVerticesForRegularPolygon(int numPoints, num size) {
    return new List.generate(numPoints, (i) {
      final theta = i / numPoints * PI2;
      return new Point(size * cos(theta), size * sin(theta));
    });
  }
  
  //see http://en.wikipedia.org/wiki/Star_polygon
  static List<Point> _getVerticesForStar(int p, int q, num size) {
    final regularVertices = _getVerticesForRegularPolygon(p, size);
    final starVertices = [regularVertices.first];
    var prev = regularVertices.first;
    var currentIndex = 0;
    while ((currentIndex = (currentIndex + q) % p) != 0) {
      starVertices.add(regularVertices[currentIndex]);
    }
    return starVertices;
  }
  
  final List<Point> vertices, directions;
  final List<num> lengths;
  final num perimeter;
  
  Shape._private(this.vertices, this.directions, this.lengths, this.perimeter);
  
  factory Shape(List<Point> vertices) {
    var perimeter = 0.0;
    final lengths = [];
    final directions = [];
    for (var i = 0; i < vertices.length; i++) {
      final current = vertices[i];
      final next = vertices[(i + 1) % vertices.length];
      final len = current.distanceTo(next);
      final dir = new Point(next.x - current.x, next.y - current.y);
      dir.normalize(1);
      
      perimeter += len;
      lengths.add(len);
      directions.add(dir);
    }
    return new Shape._private(vertices, directions, lengths, perimeter);
  }
  
  factory Shape.regular(int numPoints, num size) =>
    new Shape(_getVerticesForRegularPolygon(numPoints, size));
  
  factory Shape.star(int p, int q, num size) =>
    new Shape(_getVerticesForStar(p, q, size));
}