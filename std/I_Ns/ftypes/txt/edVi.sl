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

  _linenrs_ = LLong_Type[0];
  _lines_ = String_Type[0];

  variable
    i = 2,
    ar = String_Type[0];
  
  _prev_i_ = _i_;

  while (_i_ <= _len_ && i <= _avlines_)
    {
    _linenrs_ = [_linenrs_, s_.p_.lnrs[_i_]];
    _lines_ = [_lines_, s_.p_.lins[_i_]];
    _i_++;
    i++;
    }
  
  _vlines_ = [2:length (_lines_) - 1 + 2];

  _i_ = _i_ - (i) + 2;

  if (-1 == _i_)
    _i_ = 0;

  if (s_.ptr[0] >= i)
    s_.ptr[0] = i - 1;
  
  ar = [array_map (String_Type, &substr, _lines_, 1, s_._maxlen), tail ()];

  variable
    cols = Integer_Type[length (ar)] + 1,
    clrs = Integer_Type[length (ar)] + 1;

  cols[*] = 0;
  clrs[*] = 0;

  srv->draw_wind (ar, clrs, [_vlines_, LINES - 1], cols, [s_.ptr[0], s_.ptr[1]]);
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
}
