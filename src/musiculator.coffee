keys = ->
  canvas = document.getElementById 'musiculator'
  ctx = canvas.getContext '2d'
  
  keys = for pos, i in key_positions
    new Key(
      i,
      ctx, 
      pos,
      key_sizes[i], 
      key_texts[i], 
      key_binds[i],
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

key_binds = [
  [            ], ['0', 'NUM_/'], ['-', 'NUM_*'], ['=', 'NUM_-'],
  ['7', 'NUM_7'], ['8', 'NUM_8'], ['9', 'NUM_9'], ['S', 'NUM_+'],
  ['4', 'NUM_4'], ['5', 'NUM_5'], ['6', 'NUM_6'],
  ['1', 'NUM_1'], ['2', 'NUM_2'], ['3', 'NUM_3'], ['X', 'NUM_return'],
  ['A', 'NUM_0'],                 ['Z', 'NUM_.'],
]

class Key
  constructor: (@id, @ctx, @position, @size, @text, @binds) ->
    window.keyboard.add_press_action key_bind, @press for key_bind in @binds
    window.keyboard.add_release_action key_bind, @release for key_bind in @binds
    @is_pressed = no

  press: =>
    return if @is_pressed
    @is_pressed = yes
    @draw_pressed()
    music_key_down @id

  release: =>
    return unless @is_pressed
    @is_pressed = no
    @draw()
    music_key_up @id

  draw: ->
    util.clear_rect @ctx, @position, @size
    util.curved_rect @ctx, @position, @size
    util.print_text @ctx, @position, @text

  draw_pressed: ->
    util.clear_rect @ctx, @position, @size
    util.curved_rect @ctx, @position, @size, yes
    util.print_text @ctx, @position, @text, yes
    
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


window.musiculator = {
  keys
}