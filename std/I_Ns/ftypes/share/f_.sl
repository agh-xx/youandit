f_ = struct
  {
  getyn,
  getarchr,
  writeline,
  };

private define write_line (s, line, clr, dim, pos)
{
  srv->write_nstring_dr (line, COLUMNS, clr, [dim, pos]);
}

f_.writeline = &write_line;

private define getyn (s, msg)
{
  s.writeline (msg, 0, [LINES - 1, 0], [LINES - 1, strlen (msg) + 1]);
  send_ans (RLINE_GETYN);
  return get_ans ();
}

f_.getyn = &getyn;

private define get_char_from_array (s, ar, msg, dim, pos)
{
  s.writeline (msg, 0, dim, pos);
  send_ans (RLINE_GETFROMARRAY);
  get_ans ();
  send_ans (ar);
  return get_ans ();
}

f_.getarchr = &get_char_from_array;

