round_rect = (ctx, x, y, width, height, radius, fill) ->
  ctx.beginPath()
  ctx.moveTo x + radius, y
  ctx.lineTo x + width - radius, y
  ctx.quadraticCurveTo x + width, y, x + width, y + radius
  ctx.lineTo x + width, y + height - radius
  ctx.quadraticCurveTo x + width, y + height, x + width - radius, y + height
  ctx.lineTo x + radius, y + height
  ctx.quadraticCurveTo x, y + height, x, y + height - radius
  ctx.lineTo x, y + radius
  ctx.quadraticCurveTo x, y, x + radius, y
  ctx.closePath()
  
  if fill then ctx.fill() else ctx.stroke()
  
clear_rect_native = (ctx, x, y, width, height) ->
  ctx.clearRect x, y, width, height
  
print_text = (ctx, [pos_x, pos_y], text, inverse) ->
  ctx.font = "40px Courier New"
  fs = ctx.fillStyle
  ctx.fillStyle = if inverse then 'white' else 'black'
  ctx.fillText text, pos_x, pos_y
  ctx.fillStyle = fs

clear_rect = (ctx, [pos_x, pos_y], [size_x, size_y]) ->
  ctx.clearRect \
    pos_x - size_x - 1, pos_y - size_y - 1, 
    size_x * 2 + 2, size_y * 2 + 2

curved_rect = (ctx, [pos_x, pos_y], [size_x, size_y], filled) ->
  curve_to = ([cp_x, cp_y], [x, y]) -> 
    ctx.bezierCurveTo cp_x, cp_y, cp_x, cp_y, x, y

  move_to = ([x, y]) ->
    ctx.moveTo x, y

  pos_x_l = pos_x - size_x
  pos_x_r = pos_x + size_x
  pos_y_t = pos_y - size_y
  pos_y_b = pos_y + size_y

  top = [pos_x, pos_y_t]
  left = [pos_x_l, pos_y]
  right = [pos_x_r, pos_y]
  bottom = [pos_x, pos_y_b]

  top_left = [pos_x_l, pos_y_t]
  top_right = [pos_x_r, pos_y_t]
  bottom_left = [pos_x_l, pos_y_b]
  bottom_right = [pos_x_r, pos_y_b]

  ctx.beginPath()
  move_to left
  curve_to top_left, top
  curve_to top_right, right
  curve_to bottom_right, bottom
  curve_to bottom_left, left
  if filled then ctx.fill() else ctx.stroke()

clear_canvas = (ctx, canvas) ->
  ctx.save()
  ctx.setTransform(1, 0, 0, 1, 0, 0)
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.restore();

window.util = { 
  round_rect,
  print_text,
  clear_rect_native,
  clear_rect,
  curved_rect,
  clear_canvas
}