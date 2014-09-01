// Generated by CoffeeScript 1.7.1
(function() {
  var Key, clear_rect, draw_curved_rect, draw_keys, draw_text, key_action_funcs, key_action_pool, key_event_codes, key_positions, key_sizes, key_texts, keyboard_press_handlers, keyboard_release_handlers, music_key_down, music_key_up, note_key_action, note_offset, play_note, suspend_note, transpose, tune_key_action,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  keyboard_press_handlers = {};

  keyboard_release_handlers = {};

  $(document).keydown(function(event) {
    var _name;
    return typeof keyboard_press_handlers[_name = event.which] === "function" ? keyboard_press_handlers[_name]() : void 0;
  });

  $(document).keyup(function(event) {
    var _name;
    return typeof keyboard_release_handlers[_name = event.which] === "function" ? keyboard_release_handlers[_name]() : void 0;
  });

  draw_keys = function() {
    var canvas, ctx, i, k, keys, pos, _i, _len, _results;
    canvas = document.getElementById('keys');
    ctx = canvas.getContext('2d');
    keys = (function() {
      var _i, _len, _results;
      _results = [];
      for (i = _i = 0, _len = key_positions.length; _i < _len; i = ++_i) {
        pos = key_positions[i];
        _results.push(new Key(i, ctx, pos, key_sizes[i], key_texts[i], key_event_codes[i]));
      }
      return _results;
    })();
    _results = [];
    for (_i = 0, _len = keys.length; _i < _len; _i++) {
      k = keys[_i];
      _results.push(k.draw());
    }
    return _results;
  };

  key_positions = [[100, 100], [180, 100], [260, 100], [340, 100], [100, 180], [180, 180], [260, 180], [340, 220], [100, 260], [180, 260], [260, 260], [100, 340], [180, 340], [260, 340], [340, 380], [140, 420], [260, 420]];

  key_sizes = [[35, 35], [35, 35], [35, 35], [35, 35], [35, 35], [35, 35], [35, 35], [35, 75], [35, 35], [35, 35], [35, 35], [35, 35], [35, 35], [35, 35], [35, 75], [75, 35], [35, 35]];

  key_texts = ['', '3', '4', '5', '7', '1', '2', '+', '4', '5', '6', '1', '2', '3', '-', '#', 'b'];

  key_event_codes = [[], [48, 111], [189, 106], [187, 109], [55, 103], [56, 104], [57, 105], [83, 107], [52, 100], [53, 101], [54, 102], [49, 97], [50, 98], [51, 99], [88, 13], [65, 96], [90, 110]];

  Key = (function() {
    function Key(id, ctx, position, size, text, event_code) {
      var c, _i, _j, _len, _len1, _ref, _ref1;
      this.id = id;
      this.ctx = ctx;
      this.position = position;
      this.size = size;
      this.text = text;
      this.event_code = event_code;
      this.release = __bind(this.release, this);
      this.press = __bind(this.press, this);
      _ref = this.event_code;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        c = _ref[_i];
        keyboard_press_handlers[c] = this.press;
      }
      _ref1 = this.event_code;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        c = _ref1[_j];
        keyboard_release_handlers[c] = this.release;
      }
      this.is_pressed = false;
    }

    Key.prototype.press = function() {
      if (this.is_pressed) {
        return;
      }
      this.is_pressed = true;
      this.draw_pressed();
      return music_key_down(this.id);
    };

    Key.prototype.release = function() {
      if (!this.is_pressed) {
        return;
      }
      this.is_pressed = false;
      this.draw();
      return music_key_up(this.id);
    };

    Key.prototype.draw = function() {
      clear_rect(this.ctx, this.position, this.size);
      draw_curved_rect(this.ctx, this.position, this.size);
      return draw_text(this.ctx, this.position, this.text);
    };

    Key.prototype.draw_pressed = function() {
      clear_rect(this.ctx, this.position, this.size);
      draw_curved_rect(this.ctx, this.position, this.size, true);
      return draw_text(this.ctx, this.position, this.text, true);
    };

    return Key;

  })();

  draw_text = function(ctx, _arg, text, inverse) {
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

  draw_curved_rect = function(ctx, _arg, _arg1, filled) {
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

  note_offset = 0;

  transpose = function(scale) {
    return note_offset += scale;
  };

  play_note = function(note) {
    return MIDI.noteOn(0, note, 127, 0);
  };

  suspend_note = function(note) {
    return MIDI.noteOff(0, note, 0);
  };

  note_key_action = function(note) {
    return function() {
      var freezed_note;
      freezed_note = note + note_offset;
      play_note(freezed_note);
      return (function(freezed_note) {
        return function() {
          return suspend_note(freezed_note);
        };
      })(freezed_note);
    };
  };

  tune_key_action = function(scale) {
    return function() {
      transpose(scale);
      return function() {
        return transpose(-scale);
      };
    };
  };

  key_action_funcs = [(function() {}), note_key_action(76), note_key_action(77), note_key_action(79), note_key_action(71), note_key_action(72), note_key_action(74), tune_key_action(12), note_key_action(65), note_key_action(67), note_key_action(69), note_key_action(60), note_key_action(62), note_key_action(64), tune_key_action(-12), tune_key_action(1), tune_key_action(-1)];

  key_action_pool = {};

  music_key_down = function(id) {
    return key_action_pool[id] = key_action_funcs[id]();
  };

  music_key_up = function(id) {
    if (typeof key_action_pool[id] === "function") {
      key_action_pool[id]();
    }
    return delete key_action_pool[id];
  };

  window.draw_keys = draw_keys;

}).call(this);
