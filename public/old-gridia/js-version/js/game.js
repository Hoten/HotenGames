$(document).ready(function(){
  $("#itemdata").load("items.txt", start);
});

var keysDown = {};
addEventListener("keydown", function (e) {
  keysDown[e.keyCode] = true;
  console.log(e.keyCode);
}, false);
addEventListener("keyup", function (e) {
  delete keysDown[e.keyCode];
}, false);

function whichNumKey() {
  for (var i = 49; i <= 57; i++) {
    if (keysDown[i]) return (i - 48);
  }
}

var game;
var start = function() {
  //regex tomfoolery to remove ruby's symbols and 
  //replace them with regular object properties
  var itemsYAML = document.getElementById('itemdata').innerHTML.replace(/( +):/g, "$1")
  
  game = new Game(jsyaml.load(itemsYAML));
  game.startGame();
}

var Game = function(items) {
  var max_view = { width: 75, height: 20 };
  
  // Create the canvas
  //TODO: better names for tilesWidth, tilesHeight
  var canvas_middle, tilesWidth, tilesHeight;
  var canvas = document.getElementById("canvas");
  var ctx = canvas.getContext("2d");
  document.body.appendChild(canvas);

  //create black mask
  function createMask() {
    var mask = document.getElementById("mask");
    var mask_ctx = mask.getContext("2d");
    mask.width = window.innerWidth;
    mask.height = window.innerHeight;
    mask_ctx.fillStyle = "black";
    mask_ctx.fillRect(0, 0, mask.width, mask.height);
    
    mask_ctx.clearRect(
      (canvas_middle.x - Math.floor(tilesWidth / 2)) * 32, 
      (canvas_middle.y - Math.floor(tilesHeight / 2)) * 32, 
      tilesWidth * 32, 
      tilesHeight * 32);
    document.body.appendChild(mask);
  }

  window.onload = window.onresize = function() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    canvas_middle = { x: Math.floor(canvas.width / 32 / 2), 
      y: Math.floor(canvas.height / 32 / 2) };
    tilesWidth = Math.min(Math.ceil(canvas.width / 32) + 1, max_view.width);
    tilesHeight = Math.min(Math.ceil(canvas.height / 32) + 1, max_view.height);
    menu.canvas = { width:tilesWidth*32, height:canvas_middle.y*32 + tilesHeight/2*32 };
    createMask();
    reset();
  };
    
  this.isWalkable = function(x, y) {
    var itemId = map.getTile(x, y).item.type;
    if (itemId === 0) return true;
    return items[itemId].block_movement === undefined;
  };

  // Game objects
  function Entity(speed, image) {
    this.speed = speed;
    this.image = image;
    this.tx = this.ty = this.x = this.y = 0;
    this.state = waitingState;
  }
  
  //lazily load assets
  function assetLoader(baseString, numImages) {
    var sheets = [];
    return function(index) {
      var spriteSheetId = Math.floor(index / 100);
      if (spriteSheetId >= numImages) throw new Error("Invalid image index");
      if (!(spriteSheetId in sheets)) {
        sheets[spriteSheetId] = new Image();
        sheets[spriteSheetId].src = "images/" + baseString + spriteSheetId + ".png";
      }
      return sheets[spriteSheetId];
    };
  }

  var getFloorSpriteSheet = assetLoader("efloor", 5);
  var getItemSpriteSheet = assetLoader("item", 27);
  var getPlayerSpriteSheet = assetLoader("player", 8);
  
  var map = this.map = new Map(1000);
  var menu = new TabbedMenu(canvas);
  menu.addTab( {ss:getItemSpriteSheet(0), x:0, y:0} );
  menu.addTab( {ss:getItemSpriteSheet(0), x:32, y:32} );

  var hero = new Entity(32 * 3.5, Math.floor(Math.random() * 200));
  var monster = new Entity(256, Math.floor(Math.random() * 200));
  var itemSelected = "Nothing";
  
  var reset = function () {
    //hero.x = hero.y = 0;
    //hero.state = waitingState;
  };

  function getTileAtScreenPosition(x, y) {
    var loc = getTileLocationAtScreenPosition(x, y);
    return map.getTile(loc.x, loc.y);
  }
  
  function getTileLocationAtScreenPosition(x, y) {
    return { 
      x : Math.floor(x / 32) - canvas_middle.x + hero.x,
      y : Math.floor(y / 32) - canvas_middle.y + hero.y
    };
  }
  
  var update = function (time, delta) {
    hero.state.update(hero, delta);

    var t = time * (1 / 2000) * (Math.PI);

    monster.x = 20 * (16*Math.pow(Math.sin(t), 3)) / 32;
    monster.y = -20 * (13*Math.cos(t) - 5*Math.cos(2 * t)  - 2*Math.cos(3 * t) - Math.cos(4 * t)) / 32;
  };

  var render = function() {
    var tileLocToScreen = function(x, y) {
      return {
        x : (map.wrappedDistBetween(x, hero.x) + canvas_middle.x) * 32 - hero.tx, 
        y : (map.wrappedDistBetween(y, hero.y) + canvas_middle.y) * 32 - hero.ty
      }
    }
    var drawEntity = function(entity) {
      var at = tileLocToScreen(entity.x + entity.tx/32, entity.y + entity.ty/32);
      drawImageAt(getPlayerSpriteSheet(entity.image), entity.image % 100, at);
    };
    var drawFloor = function(floor, x, y) {
      drawImageAt(getFloorSpriteSheet(floor), floor % 100, tileLocToScreen(x, y));
    };
    var drawItem = function(item, x, y) {
      if (item.type !== 0) {
        var animIndex = items[item.type].animations[0];
        var at = tileLocToScreen(x, y);
        drawImageAt(getItemSpriteSheet(animIndex), animIndex % 100, at);
        at.y += 20;
        if (item.quantity != 1) drawTextAt(item.quantity, at);
      }
    };
    var drawImageAt = function(ss, index, at) {
      ctx.drawImage(ss, Math.floor(index % 10) * 32, Math.floor(index / 10) * 32, 32, 32, at.x, at.y, 32, 32);
    };
    var drawTextAt = function(text, at) {
      ctx.font = "10px verdana";
      ctx.fillText(text, at.x, at.y);
    };
    
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    var start = { x: hero.x - Math.floor(tilesWidth / 2),
      y: hero.y - Math.floor(tilesHeight / 2) };
    
    for (var i = -1; i <= tilesWidth; i++){
      var x = i + start.x;
      for (var j = -1; j <= tilesHeight; j++){
        var y = j + start.y;
        var tile = map.getTile(x, y);
        drawFloor(tile.floor, x, y);
        drawItem(tile.item, x, y);
      }
    }
    
    drawEntity(hero);
    drawEntity(monster);
    
    ctx.fillStyle = "rgb(250, 250, 250)";
    ctx.font = "24px Helvetica";
    ctx.textAlign = "left";
    ctx.textBaseline = "top";
    
    ctx.fillText(hero.x + "," + hero.y, 10, (canvas_middle.y - tilesHeight / 2) * 32);
    ctx.fillText(itemSelected, 10, (canvas_middle.y - tilesHeight / 2) * 32 + 32);
    
    menu.draw(ctx);
  };

  var then = Date.now();
  var lag = 0, targetFps = 60, FIXED_DELTA_MS = 1000 / targetFps;
  var main = function () {
    var now = Date.now();
    var delta = now - then;
    then = now;
    lag += delta;
    
    while (lag >= FIXED_DELTA_MS) {
      update(now, FIXED_DELTA_MS / 1000);
      lag -= FIXED_DELTA_MS;
    }
    
    render();
  };
  
  this.startGame = function() {
    var down = { x : 0, y : 0 };
    $(document).mousedown(function(e) {
      e.preventDefault();
      down = getTileLocationAtScreenPosition(e.clientX, e.clientY);
      down.tile = map.getTile(down.x, down.y);
      itemSelected = items[down.tile.item.type].name;
    });
    $(document).mouseup(function(e) {
      e.preventDefault();
      var up = getTileLocationAtScreenPosition(e.clientX, e.clientY);
      up.tile = map.getTile(up.x, up.y);
      if (!(up.x === down.x && up.y === down.y)) {
        //if number key is down, move that many. if number key is down + shift key, move 10*that many
        //otherwise, move all.
        var amountToMove = whichNumKey();
        if (amountToMove === undefined) {
          if (e.shiftKey) amountToMove = Math.ceil(down.tile.item.quantity / 2);
          else amountToMove = down.tile.item.quantity;
        }else amountToMove = Math.min(down.tile.item.quantity, amountToMove * (e.shiftKey ? 10 : 1));
        
        if (up.tile.item.type === 0) {
          up.tile.item.quantity = amountToMove;
          up.tile.item.type = down.tile.item.type;
          down.tile.item.quantity -= amountToMove;
        } else if (up.tile.item.type === down.tile.item.type && items[down.tile.item.type].stackable) {
          up.tile.item.quantity += amountToMove;
          down.tile.item.quantity -= amountToMove;
        }
        if (down.tile.item.quantity == 0) down.tile.item = { type : 0, quantity : 1 };
      }
    });
    window.onload();
    setInterval(main, 1);
  };
};