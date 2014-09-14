# document

keyboard_press_handlers = {}
keyboard_release_handlers = {}

$(document).keydown (event) ->
  # stop autoplay when user hits a key
  # these extra lines of code are signs of code corruption
  unless event.is_autoplay
    window.autoplay.stop_playing()
  keyboard_press_handlers[event.which]?()

$(document).keyup (event) ->
  keyboard_release_handlers[event.which]?()

# entry
  
keys = ->
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
  keyboard_press_handlers[32] = ->
    window.autoplay.stop_playing()
    window.autoplay.start_playing()

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
    util.clear_rect @ctx, @position, @size
    util.curved_rect @ctx, @position, @size
    util.print_text @ctx, @position, @text

  draw_pressed: ->
    util.clear_rect @ctx, @position, @size
    util.curved_rect @ctx, @position, @size, true
    util.print_text @ctx, @position, @text, true
    
# play note

note_offset = 0

transpose = (scale) ->
  note_offset += scale

note_activators_count = []

play_note = (note) ->
  if note_activators_count[note]?
    note_activators_count[note]++
  else
    note_activators_count[note] = 1

  window.piano.press_note note if note_activators_count[note] == 1

suspend_note = (note) ->
  note_activators_count[note]--
  window.piano.release_note note if note_activators_count[note] == 0

note_key_action = (note) ->
  -> 
    freezed_note = note + note_offset
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


window.keys = keys
