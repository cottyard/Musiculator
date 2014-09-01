# document

keyboard_press_handlers = {}
keyboard_release_handlers = {}

$(document).keydown (event) ->
  keyboard_press_handlers[event.which]?()
  
$(document).keyup (event) ->
  keyboard_release_handlers[event.which]?()

# entry
  
draw_keys = ->
  canvas = document.getElementById 'keys'
  ctx = canvas.getContext '2d'
  
  keys = for pos, i in key_positions
    new Key(
      i,
      ctx, 
      pos,
      key_sizes[i], 
      key_texts[i], 
      key_event_codes[i],
    )

  k.draw() for k in keys

# key

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

class Key
  constructor: (@id, @ctx, @position, @size, @text, @event_code) ->
    keyboard_press_handlers[c] = @press for c in @event_code
    keyboard_release_handlers[c] = @release for c in @event_code
    @is_pressed = false

  press: =>
    return if @is_pressed
    @is_pressed = true
    @draw_pressed()
    music_key_down @id

  release: =>
    return unless @is_pressed
    @is_pressed = false
    @draw()
    music_key_up @id

  draw: ->
    clear_rect @ctx, @position, @size
    draw_curved_rect @ctx, @position, @size
    draw_text @ctx, @position, @text

  draw_pressed: ->
    clear_rect @ctx, @position, @size
    draw_curved_rect @ctx, @position, @size, true
    draw_text @ctx, @position, @text, true
    
# draw on canvas

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

# play note

note_offset = 0

transpose = (scale) ->
  note_offset += scale

play_note = (note) ->
  MIDI.noteOn(0, note, 127, 0)

suspend_note = (note) ->
  MIDI.noteOff(0, note, 0)

note_key_action = (note) ->
  -> 
    freezed_note = note + note_offset # "note += note_offset" here creates an interesting sticky tune effect
    play_note freezed_note
    do (freezed_note) ->
      -> suspend_note freezed_note

tune_key_action = (scale) ->
  -> 
    transpose scale
    -> transpose -scale


key_action_funcs = [
                 (->), note_key_action(76), note_key_action(77), note_key_action(79),
  note_key_action(71), note_key_action(72), note_key_action(74), tune_key_action(12),
  note_key_action(65), note_key_action(67), note_key_action(69),
  note_key_action(60), note_key_action(62), note_key_action(64), tune_key_action(-12),
  tune_key_action(1),                       tune_key_action(-1),
]

key_action_pool = {}

music_key_down = (id) ->
  key_action_pool[id] = key_action_funcs[id]()

music_key_up = (id) ->
  key_action_pool[id]?()
  delete key_action_pool[id]


window.draw_keys = draw_keys
