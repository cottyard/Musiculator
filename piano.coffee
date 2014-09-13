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

key_count = key_positions_x.length
halfkey_count = halfkey_positions_x.length

key_status = ('up' for [1..key_count])
halfkey_status = ('up' for [1..halfkey_count])

ctx = null
canvas = null

piano = ->
  canvas = document.getElementById 'piano'
  ctx = canvas.getContext '2d'
  draw_piano()

# draw piano

draw_piano = ->
  for s, n in key_status
    switch s
      when 'up' then draw_key_released n
      when 'down' then draw_key_pressed n

  for s, n in halfkey_status
    switch s
      when 'up' then draw_halfkey_released n
      when 'down' then draw_halfkey_pressed n

with_transparent_blue_decorat = (func) ->
  ->
    fs = ctx.fillStyle
    ctx.fillStyle = 'rgba(0, 0, 255, 0.5)'
    func.apply @, arguments
    ctx.fillStyle = fs

draw_key_released = (num) ->
  draw_key num

draw_key_pressed = (num) ->
  draw_key num
  (with_transparent_blue_decorat draw_key) num, true

draw_halfkey_released = (num) ->
  draw_halfkey num

draw_halfkey_pressed = (num) ->
  draw_halfkey num
  (with_transparent_blue_decorat draw_halfkey) num

draw_key = (num, fill) ->
  util.round_rect(
    ctx,
    key_positions_x[num], key_position_y, 
    key_width, key_height, 
    key_radius, fill)

draw_halfkey = (num) ->
  unless num % 7 in [2, 6]
    util.round_rect(
      ctx,
      halfkey_positions_x[num], halfkey_position_y, 
      halfkey_width, halfkey_height, 
      key_radius, true)

# local operation

redraw_piano_decorat = (func) ->
  ->
    func.apply @, arguments
    util.clear_canvas ctx, canvas
    draw_piano()

press_key = redraw_piano_decorat (num) ->
  key_status[num] = 'down'

release_key = redraw_piano_decorat (num) ->
  key_status[num] = 'up'

press_halfkey = redraw_piano_decorat (num) ->
  halfkey_status[num] = 'down'

release_halfkey = redraw_piano_decorat (num) ->
  halfkey_status[num] = 'up'

# translate note input to local operation

translate_white =
  0: 0
  2: 1
  4: 2
  5: 3
  7: 4
  9: 5
  11: 6

translate_black =
  1: 0
  3: 1
  6: 3
  8: 4
  10: 5

translate =
  white: translate_white
  black: translate_black

note_to_piano_key = (note) ->
  alphabet = (note - 48) % 12
  type = if alphabet of translate_black then 'black' else 'white'
  num = (note - 48) // 12 * 7 + translate[type][alphabet]
  [type, num]

select_action =
  press:
    white: press_key
    black: press_halfkey
  release:
    white: release_key
    black: release_halfkey

handle_note_action = (action_type, note) ->
  [key_type, key_num] = note_to_piano_key note
  select_action[action_type][key_type](key_num)

# api

press_note = (note) ->
  handle_note_action 'press', note
  
release_note = (note) ->
  handle_note_action 'release', note

window.piano = {
  piano,
  press_note,
  release_note
}