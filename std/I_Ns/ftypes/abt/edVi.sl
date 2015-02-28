variable
  w_ = s_.w_,
  _chr_;

w_._avlins = LINES - 4;

define draw ();

ineed ("edViFuncs");

define draw ()
{
  if (-1 == w_._len)
    {
    srv->write_ar_dr ([repeat (" ", COLUMNS), tail ()], [0, 0], [2, LINES - 1], [0],
      [w_.ptr[0], w_.ptr[1]]);
    return;
    }

  w_.lnrs = LLong_Type[0];
  w_.lins = String_Type[0];

  w_._ii = w_._i;

  variable
    row,
    line,
    i = 2,
    ar = String_Type[0],
    lnrs = LLong_Type[0],
    cols = LLong_Type[0],
    clrs = LLong_Type[0],
    rows = Integer_Type[0];

  if (typeof (s_.p_.lins[w_._i]) == List_Type)
    while (w_._i <= w_._len && i <= w_._avlins)
      {
      line = s_.p_.lins[w_._i];
      row = Integer_Type[length (line)];
      row[*] = i;
      rows = [rows, row];
      ar = [ar, list_to_array (line)];
      w_.lins = [w_.lins, strjoin (list_to_array (line))];
      w_.lnrs = [w_.lnrs, list_to_array (s_.p_.lnrs[w_._i])];
      cols = [cols, list_to_array (s_.p_.cols[w_._i])];
      clrs = [clrs, list_to_array (s_.p_.clrs[w_._i])];
      w_._i++;
      i++;
      }
  else
    while (w_._i <= w_._len && i <= w_._avlins)
      {
      line = s_.p_.lins[w_._i];
      row = Integer_Type[length (line)];
      row[*] = i;
      rows = [rows, row];
      ar = [ar, line];
      w_.lins = [w_.lins, strjoin (line)];
      w_.lnrs = [w_.lnrs, s_.p_.lnrs[w_._i]];
      cols = [cols, s_.p_.cols[w_._i]];
      clrs = [clrs, s_.p_.clrs[w_._i]];
      w_._i++;
      i++;
      }
 
  w_.vlins = [2:rows[-1]];

  w_._i = w_._i - (i) + 2;

  if (-1 == w_._i)
    w_._i = 0;

  if (w_.ptr[0] >= i)
    w_.ptr[0] = i - 1;
  
  ar = array_map (String_Type, &substr, ar, 1, s_._maxlen);

  srv->draw_wind ([ar, tail ()], [clrs, 0],
    [rows, LINES - 1], [cols, 0], [w_.ptr[0], w_.ptr[1]]);
}

define edVi (self)
{
  w_._len = length (s_.p_.lins) - 1;

  w_.ptr[0] = 2;
  w_.ptr[1] = s_._indent;

  w_._i = 0;

  draw ();
  draw_head ();

  _chr_ = get_ans ();

  srv->write_ar_dr ([repeat (" ", COLUMNS), repeat (" ", COLUMNS)], [0, 0], [0, 1],
    [0, 0], [w_.ptr[0], w_.ptr[1]]);

  while (_chr_ != 'q')
    {
    if (any (_keys_ == _chr_))
      (@_funcs_[string (_chr_)]);
     
    send_ans (RLINE_GETCH);
    _chr_ = get_ans ();
    }

  return;
}
