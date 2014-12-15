var TabbedMenu = function(canvas) {
  this.canvas = canvas;
  var tabs = [];
  this.addTab = function(tabGfx) {
    tabs.push( {tabGfx : tabGfx} );
  };
  this.draw = function(ctx) {
    ctx.fillStyle = "rgba(0, 0, 0, 0.5)";
    for (var i = 0; i < tabs.length; i++) {
      var tab = tabs[i];
      ctx.fillRect(i * 32, this.canvas.height - 32, 32, 32);
      ctx.drawImage(tab.tabGfx.ss, tab.tabGfx.x, tab.tabGfx.y, 32, 32, i * 32, this.canvas.height - 32, 32, 32);
    }
  };
}