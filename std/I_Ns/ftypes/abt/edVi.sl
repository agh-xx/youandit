variable
  _i_,
  _chr_,
  _len_,
  _lines_,
  _prev_i_,
  _linenrs_,
  _avlines_ = LINES - 4,
  _vlines_ = [2:LINES - 4];

define draw ();

ineed ("edViFuncs");

define draw ()
{
  if (-1 == _len_)
    {
    srv->write_ar_dr ([repeat (" ", COLUMNS), tail ()], [0, 0], [2, LINES - 1], [0],
      [s_.ptr[0], s_.ptr[1]]);

    return;
    }

  variable
    row,
    line,
    i = 2,
    ar = String_Type[0],
    lnrs = LLong_Type[0],
    cols = LLong_Type[0],
    clrs = LLong_Type[0],
    rows = Integer_Type[0];

  _linenrs_ = LLong_Type[0];
  _lines_ = String_Type[0];

  _prev_i_ = _i_;
  
  if (typeof (s_.p_.lins[_i_]) == List_Type)
    while (_i_ <= _len_ && i <= _avlines_)
      {
      line = s_.p_.lins[_i_];
      row = Integer_Type[length (line)];
      row[*] = i;
      rows = [rows, row];
      ar = [ar, list_to_array (line)];
      _lines_ = [_lines_, strjoin (list_to_array (line))];
      _linenrs_ = [_linenrs_, list_to_array (s_.p_.lnrs[_i_])];
      cols = [cols, list_to_array (s_.p_.cols[_i_])];
      clrs = [clrs, list_to_array (s_.p_.clrs[_i_])];
      _i_++;
      i++;
      }
  else
    while (_i_ <= _len_ && i <= _avlines_)
      {
      line = s_.p_.lins[_i_];
      row = Integer_Type[length (line)];
      row[*] = i;
      rows = [rows, row];
      ar = [ar, line];
      _lines_ = [_lines_, strjoin (line)];
      _linenrs_ = [_linenrs_, s_.p_.lnrs[_i_]];
      cols = [cols, s_.p_.cols[_i_]];
      clrs = [clrs, s_.p_.clrs[_i_]];
      _i_++;
      i++;
      }
 
  _vlines_ = [2:rows[-1]];

  _i_ = _i_ - (i) + 2;

  if (-1 == _i_)
    _i_ = 0;

  if (s_.ptr[0] >= i)
    s_.ptr[0] = i - 1;
  
  ar = array_map (String_Type, &substr, ar, 1, s_._maxlen);

  srv->draw_wind ([ar, tail ()], [clrs, 0],
    [rows, LINES - 1], [cols, 0], [s_.ptr[0], s_.ptr[1]]);
}

define edVi (self)
{
  _len_ = length (s_.p_.lins) - 1;

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
     
    send_ans (RLINE_GETCH);
    _chr_ = get_ans ();
    }

  return;
}
