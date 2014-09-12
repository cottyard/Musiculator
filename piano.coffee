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

util = { round_rect }

key_count = 26
keyboard_start = 3
keyboard_end = 603

keyboard_width = keyboard_end - keyboard_start

key_width = keyboard_width / (key_count - 1)
key_height = key_width * 5

halfkey_width = key_width * 3 / 5
halfkey_height = key_width * 3

key_radius = key_width / 5

key_positions_x = (x for x in [keyboard_start..keyboard_end] by key_width)
key_position_y = 5

halfkey_offset_x = key_width * 7 / 10
halfkey_positions_x = (x for x in [keyboard_start + halfkey_offset_x..keyboard_end] by key_width)
halfkey_position_y = key_position_y - 1

#ctx is really noisy!

draw_piano = ->
  canvas = document.getElementById 'piano'
  ctx = canvas.getContext '2d'
  
  for n in [1..key_count]
    draw_key_released ctx, n
    
  draw_key_pressed ctx, 3

  for n in [1..key_count]
    draw_halfkey_released ctx, n
    
  draw_halfkey_pressed ctx, 1

  #round_rect ctx, 100, 100, width, height, radius, true
  #round_rect ctx, 185, 99, 30, 150, radius, true
  #ctx.fillStyle = 'rgb(0, 0, 0)'
  #round_rect ctx, 135, 99, 30, 150, radius, true

with_transparent_blue = (ctx, func) ->
  ->
    fs = ctx.fillStyle
    ctx.fillStyle = 'rgba(0, 0, 255, 0.5)'
    func.apply @, arguments
    ctx.fillStyle = fs

draw_key = (ctx, num, fill) ->
  util.round_rect(
    ctx, 
    key_positions_x[num - 1], key_position_y, 
    key_width, key_height, 
    key_radius, fill)

draw_key_released = (ctx, num) ->
  draw_key ctx, num

draw_key_pressed = (ctx, num) ->
  (with_transparent_blue ctx, draw_key) ctx, num, true
  

draw_halfkey = (ctx, num) ->
  unless num % 7 in [3, 0]
    util.round_rect(
      ctx, 
      halfkey_positions_x[num - 1], halfkey_position_y, 
      halfkey_width, halfkey_height, 
      key_radius, true)

draw_halfkey_released = (ctx, num) ->
  draw_halfkey ctx, num

draw_halfkey_pressed = (ctx, num) ->
  (with_transparent_blue ctx, draw_halfkey) ctx, num

window.draw_piano = draw_piano
