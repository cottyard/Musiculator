key_positions = [
  [100, 100], [180, 100], [260, 100], [340, 100],
  [100, 180], [180, 180], [260, 180], [340, 220],
  [100, 260], [180, 260], [260, 260], 
  [100, 340], [180, 340], [260, 340], [340, 380],
  [140, 420],             [260, 420], 
]

key_sizes = [
  [35, 35], [35, 35], [35, 35], [35, 35],
  [35, 35], [35, 35], [35, 35], [35, 75],
  [35, 35], [35, 35], [35, 35], 
  [35, 35], [35, 35], [35, 35], [35, 75],
  [75, 35],           [35, 35], 
]

key_texts = [
  '' , '3', '4', '5',
  '7', '1', '2', '+',
  '4', '5', '6', 
  '1', '2', '3', '-',
  '#',      'b',
]

key_event_codes = [
  [       ], [48, 111], [189, 106], [187, 109],
  [55, 103], [56, 104], [ 57, 105], [ 83, 107],
  [52, 100], [53, 101], [ 54, 102],
  [49,  97], [50,  98], [ 51,  99], [ 88,  13],
  [65,  96],            [ 90, 110],
]


get_action_play = (note) ->
  -> play_note note

get_action_suspend = (note) ->
  -> suspend_note note

get_action_transpose = (scale) ->
  -> transpose scale

  
key_action_begin_funcs = [
                 (->), get_action_play(76), get_action_play(77), get_action_play(79),
  get_action_play(71), get_action_play(72), get_action_play(74), get_action_transpose(12),
  get_action_play(65), get_action_play(67), get_action_play(69),
  get_action_play(60), get_action_play(62), get_action_play(64), get_action_transpose(-12),
  get_action_transpose(1),                  get_action_transpose(-1),
]

key_action_end_funcs = [
                    (->), get_action_suspend(76), get_action_suspend(77), get_action_suspend(79),
  get_action_suspend(71), get_action_suspend(72), get_action_suspend(74), get_action_transpose(-12),
  get_action_suspend(65), get_action_suspend(67), get_action_suspend(69),
  get_action_suspend(60), get_action_suspend(62), get_action_suspend(64), get_action_transpose(12),
  get_action_transpose(-1),                       get_action_transpose(1),
]

keyboard_press_handlers = {}
keyboard_release_handlers = {}

$(document).keydown (event) ->
  keyboard_press_handlers[event.which]?()
  
$(document).keyup (event) ->
  keyboard_release_handlers[event.which]?()


draw_keys = ->
  canvas = document.getElementById 'keys'
  ctx = canvas.getContext '2d'
  
  keys = for pos, i in key_positions
    new Key(
      ctx, pos, 
      key_sizes[i], 
      key_texts[i], 
      key_event_codes[i],
      key_action_begin_funcs[i],
      key_action_end_funcs[i],
    )

  k.draw() for k in keys


class Key
  constructor: (@ctx, @position, @size, @text, @event_code, @action_begin, @action_end) ->
    keyboard_press_handlers[c] = @press for c in @event_code
    keyboard_release_handlers[c] = @release for c in @event_code
    @is_pressed = false
    
  press: =>
    return if @is_pressed
    @is_pressed = true
    @draw_pressed()
    @action_begin()
    
  release: =>
    return unless @is_pressed
    @is_pressed = false
    @draw()
    @action_end()

  draw: ->
    clear_rect @ctx, @position, @size
    draw_curved_rect @ctx, @position, @size
    draw_text @ctx, @position, @text

  draw_pressed: ->
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
  ctx.clearRect \
    pos_x - size_x - 1, pos_y - size_y - 1, 
    size_x * 2 + 2, size_y * 2 + 2

draw_curved_rect = (ctx, [pos_x, pos_y], [size_x, size_y], filled) ->
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

  
note_offset = 0

transpose = (scale) ->
  note_offset += scale
  
play_note = (note) ->
  MIDI.noteOn(0, note + note_offset, 127, 0)

suspend_note = (note) ->
  MIDI.noteOff(0, note + note_offset, 0)
  
window.draw_keys = draw_keys
