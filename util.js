// Generated by CoffeeScript 1.7.1
(function() {
  var clear_canvas, clear_rect, clear_rect_native, curved_rect, print_text, round_rect;

  round_rect = function(ctx, x, y, width, height, radius, fill) {
    ctx.beginPath();
    ctx.moveTo(x + radius, y);
    ctx.lineTo(x + width - radius, y);
    ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
    ctx.lineTo(x + width, y + height - radius);
    ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
    ctx.lineTo(x + radius, y + height);
    ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
    ctx.lineTo(x, y + radius);
    ctx.quadraticCurveTo(x, y, x + radius, y);
    ctx.closePath();
    if (fill) {
      return ctx.fill();
    } else {
      return ctx.stroke();
    }
  };

  clear_rect_native = function(ctx, x, y, width, height) {
    return ctx.clearRect(x, y, width, height);
  };

  print_text = function(ctx, _arg, text, inverse) {
    var fs, pos_x, pos_y;
    pos_x = _arg[0], pos_y = _arg[1];
    ctx.font = "40px Courier New";
    fs = ctx.fillStyle;
    ctx.fillStyle = inverse ? 'white' : 'black';
    ctx.fillText(text, pos_x, pos_y);
    return ctx.fillStyle = fs;
  };

  clear_rect = function(ctx, _arg, _arg1) {
    var pos_x, pos_y, size_x, size_y;
    pos_x = _arg[0], pos_y = _arg[1];
    size_x = _arg1[0], size_y = _arg1[1];
    return ctx.clearRect(pos_x - size_x - 1, pos_y - size_y - 1, size_x * 2 + 2, size_y * 2 + 2);
  };

  curved_rect = function(ctx, _arg, _arg1, filled) {
    var bottom, bottom_left, bottom_right, curve_to, left, move_to, pos_x, pos_x_l, pos_x_r, pos_y, pos_y_b, pos_y_t, right, size_x, size_y, top, top_left, top_right;
    pos_x = _arg[0], pos_y = _arg[1];
    size_x = _arg1[0], size_y = _arg1[1];
    curve_to = function(_arg2, _arg3) {
      var cp_x, cp_y, x, y;
      cp_x = _arg2[0], cp_y = _arg2[1];
      x = _arg3[0], y = _arg3[1];
      return ctx.bezierCurveTo(cp_x, cp_y, cp_x, cp_y, x, y);
    };
    move_to = function(_arg2) {
      var x, y;
      x = _arg2[0], y = _arg2[1];
      return ctx.moveTo(x, y);
    };
    pos_x_l = pos_x - size_x;
    pos_x_r = pos_x + size_x;
    pos_y_t = pos_y - size_y;
    pos_y_b = pos_y + size_y;
    top = [pos_x, pos_y_t];
    left = [pos_x_l, pos_y];
    right = [pos_x_r, pos_y];
    bottom = [pos_x, pos_y_b];
    top_left = [pos_x_l, pos_y_t];
    top_right = [pos_x_r, pos_y_t];
    bottom_left = [pos_x_l, pos_y_b];
    bottom_right = [pos_x_r, pos_y_b];
    ctx.beginPath();
    move_to(left);
    curve_to(top_left, top);
    curve_to(top_right, right);
    curve_to(bottom_right, bottom);
    curve_to(bottom_left, left);
    if (filled) {
      return ctx.fill();
    } else {
      return ctx.stroke();
    }
  };

  clear_canvas = function(ctx, canvas) {
    ctx.save();
    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    return ctx.restore();
  };

  window.util = {
    round_rect: round_rect,
    print_text: print_text,
    clear_rect_native: clear_rect_native,
    clear_rect: clear_rect,
    curved_rect: curved_rect,
    clear_canvas: clear_canvas
  };

}).call(this);