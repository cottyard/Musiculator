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

key_texts = [
  '' , '3', '4', '5',
  '7', '1', '2', '+',
  '4', '5', '6', 
  '1', '2', '3', '-',
  '#',      'b',
]

key_event_codes = [
  [      ], [48    ], [ 45, 189], [ 61, 187],
  [55    ], [56    ], [ 57     ], [115,  83],
  [52    ], [53    ], [ 54     ],
  [49    ], [50    ], [ 51     ], [120,  88],
  [97, 65],           [122,  90],
]

keyboard_press_handlers = {}
keyboard_release_handlers = {}

$(document).keydown (event) ->
  event.preventDefault()
  keyboard_press_handlers[event.which]?()
  
$(document).keyup (event) ->
  event.preventDefault()
  keyboard_release_handlers[event.which]?()


draw_keys = ->
  canvas = document.getElementById 'keys'
  ctx = canvas.getContext '2d'
  
  keys = for pos, i in key_positions
    new Key(ctx, pos, key_sizes[i], key_texts[i], key_event_codes[i])

  k.draw() for k in keys


class Key
  constructor: (@ctx, @position, @size, @text, @event_code) ->
    keyboard_press_handlers[c] = @draw_pressed for c in @event_code
    keyboard_release_handlers[c] = @draw for c in @event_code

  draw: () =>
    clear_rect @ctx, @position, @size
    draw_curved_rect @ctx, @position, @size
    draw_text @ctx, @position, @text

  draw_pressed: () =>
    clear_rect @ctx, @position, @size
    draw_curved_rect @ctx, @position, @size, true
    draw_text @ctx, @position, @text, true


draw_text = (ctx, [pos_x, pos_y], text, inverse) ->
  ctx.font = "40px Courier New"
  fs = ctx.fillStyle
  ctx.fillStyle = if inverse then 'white' else 'black'
  ctx.fillText text, pos_x, pos_y
  ctx.fillStyle = fs

clear_rect = (ctx, [pos_x, pos_y], [size_x, size_y]) ->
  size_y ?= size_x
  ctx.clearRect \
    pos_x - size_x - 1, pos_y - size_y - 1, 
    size_x * 2 + 2, size_y * 2 + 2

draw_curved_rect = (ctx, [pos_x, pos_y], [size_x, size_y], filled) ->
  size_y ?= size_x

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


window.draw_keys = draw_keys
