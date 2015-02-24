variable
  _i_,
  _chr_,
  _len_,
  _lines_,
  _linenrs_,
  _avlines_ = LINES - 4,
  _vlines_ = [2:LINES - 4];

define draw ();

ineed ("edViFuncs");

private variable
  js_,
  __i__,
  _prev_i_,
  _ar_,
  _buf_,
  _rows_,
  _cols_,
  _colors_,
  _line_,
  _row_;

define draw ()
{
  if (-1 == _len_)
    {
    srv->write_ar_dr ([repeat (" ", COLUMNS), tail ()], [0, 0], [2, LINES - 1], [0], [s_.ptr[0], s_.ptr[1]]);
    return;
    }

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

  if (s_.ptr[0] >= __i__)
    s_.ptr[0] = __i__ - 1;
  
  _ar_ = [array_map (String_Type, &substr, _lines_, 1, s_._maxlen), tail ()];
  _cols_ = Integer_Type[length (_ar_)] + 1;
  _colors_ = Integer_Type[length (_ar_)] + 1;
  _cols_[*] = 0;
  _colors_[*]  = 0;

  srv->draw_wind (_ar_, _colors_, [_vlines_, LINES - 1], _cols_, [s_.ptr[0], s_.ptr[1]]);
}

define delete ()
{
  send_ans (0);
  _chr_ = get_ans ();

  if (any (['d', 'w' == _chr_]))
    if ('d' == _chr_)
      {
      variable
        i = _linenrs_[s_.ptr[0] - 2],
        line_ = getvirtline ('.');

      s_.js_._lines = list_concat (s_.js_._lines[[0:i - 1]], s_.js_._lines[[i + 1:]]);

      _for i (i, length (s_.js_._lines) - 1)
        s_.js_._lines[i][0][0]--;
      
      ifnot (length (s_.js_._lines))
        {
        s_.ptr = [2, s_._indent],
        s_.js_._lines = {{[0], [repeat (" ", s_._indent)], [0], [0]}};
        _lines_ = [repeat (" ", s_._indent)];
        _len_ = -1;
        s_.st_.st_size = 0;
        }
      else
        {
        _len_--;
        s_.st_.st_size -= strbytelen (line_) - s_._indent + 1;
        }

      variable enc = struct
        {
        st_ = @s_.st_,
        jslinlen = s_.jslinlen, 
        ptr = s_.ptr,
        _modified = 1,
        _states = s_._states + 1,
        _state = s_._state,
        _fname = s_._fname,
        _access = s_._access,
        _gown = s_._gown,
        _uown = s_._uown,
        _indent = s_._indent,
        @s_.js_
        };

      try
        {
        variable
          buf = json_encode (enc),
          len = strlen (buf) + (length (s_.jslinlen) ? 1 : 0);
        
        () = fseek (s_._jsfp, 0, SEEK_END);

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
        EXIT_CODE = 1;
        exit_me ();
        }
      }

  _i_ = _prev_i_;

  if (_i_ > _len_)
    _i_ = _len_;

  draw ();
}

_funcs_[string ('d')] = &delete;

define edVi (self)
{
  _len_ = length (s_.js_._lines) - 1;

  s_.ptr[0] = 2;
  s_.ptr[1] = s_._indent;

  _i_ = 0;

  draw ();
  draw_head ();

  _chr_ = get_ans ();

  srv->write_ar_dr ([repeat (" ", COLUMNS), repeat (" ", COLUMNS)], [0, 0], [0, 1],
    [0, 0], [s_.ptr[0], s_.ptr[1]]);

  while (_chr_ != 'q')
    {
    if (any (_keys_ == _chr_))
      (@_funcs_[string (_chr_)]);
     
    send_ans (0);
    _chr_ = get_ans ();
    }

  return;
}
