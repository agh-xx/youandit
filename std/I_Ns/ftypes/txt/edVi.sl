ineed ("json");

private variable
  s_,
  _i_,
  __i__,
  _prev_i_,
  js_,
  _ar_,
  _len_,
  _buf_,
  _head_ = String_Type[2],
  _hrows_ = [0, 1],
  _hcols_ = [0, 0],
  _hcolors_ = [6, 6],
  _rows_,
  _cols_,
  _colors_,
  _linenrs_,
  _lines_,
  _line_,
  _linlen_,
  _plinlen_,
  _chr_,
  _keys_ = [
    keys->DOWN, keys->UP, keys->NPAGE, keys->CTRL_f, keys->CTRL_b,
    keys->PPAGE, keys->END, 'G', 'g', keys->HOME, keys->RIGHT,
    keys->LEFT, keys->CTRL_r, '-', '$', '0', '^', '>', '<', 'u', keys->CTRL_u,
    'd'
    ],
  _avlines_ = LINES - 4,
  _vlines_ = [2:LINES - 4],
  _funcs_ = Assoc_Type[Ref_Type],
  _row_;

private define linlen (r)
{
  return strlen (_lines_[r - 2]) - s_._indent;
}

private define getvirtline (r)
{
  if ('.' == r)
    return _lines_[s_.ptr[0] - 2];

  return _lines_[r - 2];
}

private define tail ()
{
  return sprintf ("(virt row %d) (col %d) (linenr %d) (length %d) (strlen %d) state %d, states %d",
    s_.ptr[0], s_.ptr[1] - s_._indent + 1, _linenrs_[s_.ptr[0] - 2] + 1,
    _len_ + 1, linlen (s_.ptr[0]), s_._state + 1, s_._states);
}

private define draw_tail ()
{
  srv->write_nstring_dr (tail, COLUMNS, 0, [LINES - 1, 0, s_.ptr[0], s_.ptr[1]]);
}

private define draw_head ()
{
  _head_ = [s_._fname + ", owned by (" + s_._uown + "/" + s_._gown + ") and you are "
    + WHOAMI + ", access " + s_._access, "m " + ctime (s_.st_.st_mtime) +
    " - a " + ctime (s_.st_.st_atime) + " - c " + ctime (s_.st_.st_ctime) + " - size "
    + string (s_.st_.st_size)];
  srv->write_ar_dr (_head_, _hcolors_, [0, 1], _hcols_, [s_.ptr[0], s_.ptr[1]]);
}

private define draw ()
{
  _linenrs_ = LLong_Type[0];
  _ar_ = String_Type[0];
  _lines_ = String_Type[0];

  __i__ = 2;
  
  _prev_i_ = _i_;

  while (_i_ <= _len_ && __i__ <= _avlines_)
    {
    _line_ = s_.js_._lines[_i_];
    _linenrs_ = [_linenrs_, _line_[0][0]];
    _lines_ = [_lines_, _line_[1][0]];
    _i_++;
    __i__++;
    }
 
  _vlines_ = [2:length (_lines_) - 1 + 2];

  _i_ = _i_ - (__i__) + 2;

  if (-1 == _i_)
    _i_ = 0;

  _linenrs_ = array_map (Integer_Type, &int, _linenrs_);
  
  if (s_.ptr[0] > __i__)
    s_.ptr[0] = __i__;
  
  _ar_ = [array_map (String_Type, &substr, _lines_, 1, s_._maxlen), tail];
  _cols_ = Integer_Type[length (_ar_)] + 1;
  _colors_ = Integer_Type[length (_ar_)] + 1;
  _cols_[*] = 0;
  _colors_[*]  = 0;

  srv->draw_wind (_ar_, _colors_, [_vlines_, LINES - 1], _cols_, [s_.ptr[0], s_.ptr[1]]);
}

private define reparse ()
{
  s_.decode (;;__qualifiers ()); 

  _len_ = length (s_.js_._lines) - 1;
  _i_ = 0;

  draw ();
}

_funcs_[string (keys->CTRL_r)] = &reparse;

private define indent_out ()
{
  if (s_._indent > COLUMNS - 84)
    return;

  s_._indent += 4;
  s_.ptr[1] = s_._indent;

  reparse (;reparse);
}

_funcs_[string ('>')] = &indent_out;

private define indent_in ()
{
  if (s_._indent <= 0)
    return;

  s_._indent -= 4;
  s_.ptr[1] = s_._indent;

  reparse (;reparse);
}

_funcs_[string ('<')] = &indent_in;

private define down ()
{
  if (s_.ptr[0] < _vlines_[-1])
    {
    _plinlen_ = linlen (s_.ptr[0]);

    s_.ptr[0]++;
    
    _linlen_ = linlen (s_.ptr[0]);
   
    ifnot (_linlen_)
      s_.ptr[1] = s_._indent;
    else
      if ((0 != _plinlen_ && s_.ptr[1] - s_._indent == _plinlen_ - 1)
       || (s_.ptr[1] - s_._indent && s_.ptr[1] - s_._indent > _linlen_))
         s_.ptr[1] = _linlen_ - 1 + s_._indent;

    draw_tail ();

    return; 
    }

  if (_linenrs_[-1] == _len_)
    return;

  _i_++;
  
  draw ();
}

_funcs_[string (keys->DOWN)] = &down;

private define up ()
{
  if (s_.ptr[0] > _vlines_[0])
    {
    _plinlen_ = linlen (s_.ptr[0]);

    s_.ptr[0]--;
    
    _linlen_ = linlen (s_.ptr[0]);

    ifnot (_linlen_)
      s_.ptr[1] = s_._indent;
    else
      if ((0 != _plinlen_ && s_.ptr[1] - s_._indent == _plinlen_ - 1)
       || (s_.ptr[1] - s_._indent && s_.ptr[1] - s_._indent > _linlen_))
         s_.ptr[1] = _linlen_ - 1 + s_._indent;
    
    draw_tail ();
    
    return;
    }

  ifnot (_linenrs_[0])
    return;

  _i_--;

  draw ();
}

_funcs_[string (keys->UP)] = &up;

private define end_of_file ()
{
  _i_ = _len_ - _avlines_ + length (_head_);

  s_.ptr[0] = 2;
  s_.ptr[1] = s_._indent;

  draw ();
}

_funcs_[string (keys->END)] = &end_of_file;
_funcs_[string ('G')]= &end_of_file;

private define go_home ()
{
  _i_ = 0;
  
  s_.ptr[0] = 2;
  s_.ptr[1] = s_._indent;
  
  draw ();
}

_funcs_[string (keys->HOME)] = &go_home;
_funcs_[string ('g')]= &go_home;

private define page_down ()
{
  if (_i_ + _avlines_ > _len_)
    return;

  _i_ += (_avlines_ - 2);

  s_.ptr[1] = s_._indent;

  draw ();
}

_funcs_[string (keys->NPAGE)] = &page_down;
_funcs_[string (keys->CTRL_f)] = &page_down;

private define page_up ()
{
  ifnot (_linenrs_[0] - 1)
    return;
  
  if (_linenrs_[0] >= _avlines_)
    _i_ = _linenrs_[0] - _avlines_ + 2;
  else
    _i_ = 0;

  s_.ptr[1] = s_._indent;

  draw ();
}

_funcs_[string (keys->CTRL_b)] = &page_up;
_funcs_[string (keys->PPAGE)] = &page_up;

private define right ()
{
  _linlen_ = linlen (s_.ptr[0]);

  if (s_.ptr[1] - s_._indent < _linlen_ - 1 && s_.ptr[1] < s_._maxlen - 1)
    {
    s_.ptr[1]++;
    draw_tail ();
    }
  else if (_linlen_ > s_._maxlen && s_.ptr[1] + 1 == s_._maxlen)
    srv->write_wrapped_str_dr (substr (_lines_[s_.ptr[0] - 2], s_._indent + 1, -1),
     11, [s_.ptr[0], s_._indent],
     [_linlen_ / s_._maxlen + (_linlen_ mod s_._maxlen ? 1 : 0), s_._maxlen - s_._indent],
      1, [s_.ptr[0], s_.ptr[1]]);
}

_funcs_[string (keys->RIGHT)] = &right;

private define eos ()
{
  _linlen_ = linlen (s_.ptr[0]);

  if (_linlen_ > s_._maxlen)
    s_.ptr[1] = s_._maxlen - 1;
  else
    s_.ptr[1] = _linlen_ + s_._indent - 1;

  draw_tail ();
}

_funcs_[string ('-')] = &eos;

private define eol ()
{
  _linlen_ = linlen (s_.ptr[0]);

  if (_linlen_ < s_._maxlen)
    s_.ptr[1] = _linlen_ + s_._indent - 1;
  else
    srv->write_wrapped_str_dr (substr (_lines_[s_.ptr[0] - 2], s_._indent + 1, -1),
     11, [s_.ptr[0], s_._indent],
     [_linlen_ / s_._maxlen + (_linlen_ mod s_._maxlen ? 1 : 0), s_._maxlen - s_._indent],
      1, [s_.ptr[0], s_.ptr[1]]);
  
  draw_tail ();
}

_funcs_[string ('$')] = &eol;

private define left ()
{
  ifnot (s_.ptr[1] - s_._indent)
    return;

  s_.ptr[1]--;

  draw_tail ();
}

_funcs_[string (keys->LEFT)] = &left;

private define bol ()
{
  s_.ptr[1] = s_._indent;
  draw_tail ();
}

_funcs_[string ('0')] = &bol;

private define bolnblnk ()
{
  s_.ptr[1] = s_._indent;

  _linlen_ = linlen (s_.ptr[0]);

  loop (_linlen_)
    {
    ifnot (isblank (_lines_[s_.ptr[0] - 2][s_.ptr[1]]))
      break;

    s_.ptr[1]++;
    }

  draw_tail ();
}

_funcs_[string ('^')] = &bolnblnk;

private define undo ()
{
  if (s_._state + 1 >= s_._states || s_._states == 1)
    return;
  
  s_._state++;

  variable js_ = s_.getjs ();
  s_.js_._lines = js_._lines;
  s_.js_._links = js_._links;

  _len_ = length (s_.js_._lines) - 1;
  _i_ = 0;

  draw ();
}

_funcs_[string ('u')] = &undo;

private define undo_forw ()
{
  ifnot (s_._state)
    return;

  s_._state--;

  variable js_ = s_.getjs ();
  s_.js_._lines = js_._lines;
  s_.js_._links = js_._links;

  _len_ = length (s_.js_._lines) - 1;
  _i_ = 0;

  draw ();
}

_funcs_[string (keys->CTRL_u)] = &undo_forw;

private define delete ()
{
  _chr_ = get_ans ();

  if (any (['d', 'w' == _chr_]))
    if ('d' == _chr_)
      {
      variable
        i,
        line,
        line_ = getvirtline ('.');
      
      _for i (0, length (s_.js_._lines) - 1)
        {
        line = strjoin (list_to_array (s_.js_._lines[i][3]));
        if (line_ == line)
          {
          s_.js_._lines = list_concat (s_.js_._lines[[0:i - 1]], s_.js_._lines[[i + 1:]]);
          _len_--;
          s_.st_.st_size -= strbytelen (line_) - s_._indent + 1;
          break;
          }
        }
      
      variable enc = struct
        {
        st_ = @s_.st_,
        jslinlen = s_.jslinlen, 
        ptr = s_.ptr,
        _modified = 1,
        _states = s_._states + 1,
        _state = 0,
        _fname = s_._fname,
        _access = s_._access,
        _gown = s_._gown,
        _uown = s_._uown,
        _indent = s_._indent,
        @s_.js_
        };

      try
        {
        () = fseek (s_._jsfp, 0, SEEK_END);
        variable
          buf = json_encode (enc),
          len = strlen (buf) + (length (s_.jslinlen) ? 1 : 0);
        
        len += (length (s_.jslinlen) ? s_.jslinlen[0] : 0);
        len += strlen (string (len)) + 1;
        list_insert (s_.jslinlen, len);
        buf = json_encode (struct {@enc, jslinlen = s_.jslinlen}); 
        len = fprintf (s_._jsfp, "%s\n", buf);

        () = fflush (s_._jsfp);
        s_._states++;
        }
      catch Json_Parse_Error:
        {
        () = fprintf (stderr, "Error encoding edVi struct\n");
        %EXIT_CODE = 1;
        %exit_me ();
        }
      }
  _i_ = 0;
  draw ();

}

_funcs_[string ('d')] = &delete;

define edVi (self)
{
  s_ = self;

  _len_ = length (s_.js_._lines) - 1;

  s_.ptr[0] = 2;
  s_.ptr[1] = s_._indent;

  _i_ = 0;

  _head_ = [s_._fname + ", owned by (" + s_._uown + "/" + s_._gown + ") and you are "
    + WHOAMI + ", access " + s_._access, "m " + ctime (s_.st_.st_mtime) +
    " - a " + ctime (s_.st_.st_atime) + " - c " + ctime (s_.st_.st_ctime) + " - size "
    + string (s_.st_.st_size)];

  draw ();
  draw_head ();

  _chr_ = get_ans ();

  srv->write_ar_dr ([repeat (" ", COLUMNS), repeat (" ", COLUMNS)], [0, 0], [0, 1],
    _hcols_, [s_.ptr[0], s_.ptr[1]]);

  while (_chr_ != 'q')
    {
    if (any (_keys_ == _chr_))
      (@_funcs_[string (_chr_)]);
     
    send_ans (0);
    _chr_ = get_ans ();
    }

  return;
}
