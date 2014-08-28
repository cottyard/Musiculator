draw_keys = ->
  canvas = document.getElementById 'keys'
  ctx = canvas.getContext '2d'
  
  key_positions = [
    [100, 100], [180, 100], [260, 100], [340, 100],
    [100, 180], [180, 180], [260, 180], [340, 220],
    [100, 260], [180, 260], [260, 260], 
    [100, 340], [180, 340], [260, 340], [340, 380],
    [140, 420],             [260, 420], 
  ]
  key_sizes = [
    [35], [35], [35], [35],
    [35], [35], [35], [35, 75],
    [35], [35], [35], 
    [35], [35], [35], [35, 75],
    [75, 35],   [35], 
  ]
  for key, i in key_positions
    [size_x, size_y] = key_sizes[i]
    draw_curved_rect ctx, key, size_x, size_y

draw_curved_rect = (ctx, [point_x, point_y], size_x, size_y=size_x) ->
  curve_to = ([cp_x, cp_y], [x, y]) ->    
    ctx.quadraticCurveTo cp_x, cp_y, x, y

  move_to = ([x, y]) ->
    ctx.moveTo x, y

  point_x_l = point_x - size_x
  point_x_r = point_x + size_x
  point_y_t = point_y - size_y
  point_y_b = point_y + size_y

  top = [point_x, point_y_t]
  left = [point_x_l, point_y]
  right = [point_x_r, point_y]
  bottom = [point_x, point_y_b]

  top_left = [point_x_l, point_y_t]
  top_right = [point_x_r, point_y_t]
  bottom_left = [point_x_l, point_y_b]
  bottom_right = [point_x_r, point_y_b]

  ctx.beginPath()
  move_to left
  curve_to top_left, top
  curve_to top_right, right
  curve_to bottom_right, bottom
  curve_to bottom_left, left
  ctx.stroke()
