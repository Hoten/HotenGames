var Map = function(size) {
  var wrap = function wrap (x) {
    var mod = x % size;
    return mod < 0 ? size + mod : mod;
  }
  
  //set floors and items
  var tiles = [];
  var possibleItems = [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 150];
  for (var i = 0; i < size; i++) {
    tiles[i] = [];
    for (var j = 0; j < size; j++) {     
        tiles[i][j] = {floor: 120 + (i + j) % 5, 
        item: {
          type : possibleItems[Math.floor(Math.random() * possibleItems.length)],
          quantity : 1
        }
      };
    }
  }
  //create a spiraling granite wall
  for (var t = 0; t < Math.PI * 6; t += 0.001) {
    var r = t * t;
    var x = Math.floor(size * r * Math.cos(t) / 375 / 2);
    var y = Math.floor(size * r * Math.sin(t) / 375 / 2) + 1;
    tiles[wrap(x)][wrap(y)].item.type = 10;
  }
  
  return {
    tiles: tiles,
    wrap: wrap,
    getTile: function (x, y) {
      return tiles[wrap(x)][wrap(y)];
    },
    wrappedDistBetween: function (x1, x2) {
      x1 = wrap(x1);
      x2 = wrap(x2);
      var d1 = x1 - x2;
      var d2 = -(size - x1 + x2);
      var d3 = size + x1 - x2;

      if (Math.abs(d1) < Math.abs(d2)) {
        if (Math.abs(d1) < Math.abs(d3)) {
          return d1;
        } else {
          return d3;
        }
      } else {
        if (Math.abs(d2) < Math.abs(d3)) {
          return d2;
        } else {
          return d3;
        }
      }
    }
  }
}