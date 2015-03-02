typedef struct
  {
  _row,
  _col,
  _chr,
  _lin,
  _ind,
  lnrs,
  argv,
  } Rline_Type;

rl_ = struct
  {
  c_,
  getcom,
  readline,
  clear,
  com = ["write", "quit", "quit!"],
  };

private define clear (s, pos)
{
  variable
    ar = String_Type[length (s.c_.lnrs)],
    clrs = Integer_Type[length (s.c_.lnrs)],
    cols = Integer_Type[length (s.c_.lnrs)],
    i;

  ar[*] = repeat (" ", COLUMNS);
  clrs[*] = 0;
  cols[*] = 0;

  srv->write_ar_dr (ar, clrs, s.c_.lnrs, cols, pos);
}

rl_.clear = &clear;

private define get_command (s)
{
  s.c_ = @Rline_Type;
  s.c_._col = 1;
  s.c_._lin = ":";
  s.c_._row = LINES - 2;
  s.c_._ind = 0;
  s.c_.lnrs = [s.c_._row];
  s.c_.argv = String_Type[0];

  f_.writeline (s.c_._lin, 0, [s.c_._row, 0], [s.c_._row, s.c_._col]);

  send_ans (RLINE_GETCH);

  forever
    {
    s.c_._chr = get_ans ();

    if (033 == s.c_._chr)
      {
      s.clear (w_.ptr);
      break;
      }

    if (any (['a':'z'] == s.c_._chr))
      {
      s.c_._col++;
      s.c_._lin += char (s.c_._chr);
      }

    f_.writeline (s.c_._lin, 0, [s.c_._row, 0], [s.c_._row, s.c_._col]);
    send_ans (RLINE_GETCH);
    }
};

rl_.getcom = &get_command;
