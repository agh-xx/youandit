private variable
  _hcolors_ = [6, 6];

define v_linlen (r)
{
  r = (r == '.' ? w_.ptr[0] : r) - 2;
  return strlen (w_.lins[r]) - s_._indent;
}

define v_lin (r)
{
  r = (r == '.' ? w_.ptr[0] : r) - 2;
  return w_.lins[r];
}

define v_lnr (r)
{
  r = (r == '.' ? w_.ptr[0] : r) - 2;
  return w_.lnrs[r];
}

define tail ()
{
  % is a bug in slsmg?
  % last line is not cleared, even with slsmg_cls, or slsmg_erase_eos,
  % or slsmg_write_nstring
 
  variable t = sprintf ("(virt row %d) (col %d) (linenr %d) (length %d) (strlen %d) state %d, states %d",
    w_.ptr[0], w_.ptr[1] - s_._indent + 1, v_lnr ('.') + 1,
    w_._len + 1, v_linlen ('.'), s_._state + 1, s_._states);
 
  t += repeat (" ", COLUMNS - strlen (t));
  return t;
}

define draw_tail ()
{
  srv->write_nstring_dr (tail, COLUMNS, 0, [LINES - 1, 0, w_.ptr[0], w_.ptr[1]]);
}

define draw_head ()
{
  variable head = [s_._fname + ", owned by (" + s_._uown + "/" + s_._gown + ") and you are "
    + WHOAMI + ", access " + s_._access, "m " + ctime (s_.st_.st_mtime) +
    " - a " + ctime (s_.st_.st_atime) + " - c " + ctime (s_.st_.st_ctime) + " - size "
    + string (s_.st_.st_size)];

  srv->write_ar_dr (head, _hcolors_, [0, 1], [0, 0], [w_.ptr[0], w_.ptr[1]]);
}

define reparse ()
{
  s_.decode (;;__qualifiers ());

  w_._len = length (s_.p_.lins) - 1;

  w_._i = 0;

  draw ();
}

pf[string (keys->CTRL_r)] = &reparse;
