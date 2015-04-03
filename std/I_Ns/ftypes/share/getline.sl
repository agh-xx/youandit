private define getline (s, line, prev_l, next_l)
{
  srv->write_nstring_dr ("-- INSERT -- ", COLUMNS, 0, [0, 0, w_.ptr[0], w_.ptr[1]]);
  s.c_ = @Rline_Type;
  s.c_._col = w_.ptr[1];
  s.c_._row = w_.ptr[0];

  forever
    {
    send_ans (RLINE_GETCH);
    s.c_._chr = get_ans ();

    if (033 == s.c_._chr)
      {
      if (0 < w_.ptr[1] - s_._indent)
        w_.ptr[1]--;

      srv->write_nstring_dr (" ", COLUMNS, 0, [0, 0, w_.ptr[0], w_.ptr[1]]);
      return;
      }
 
    if (any (keys->rmap.left == s.c_._chr))
      {
      if (0 < w_.ptr[1] - s_._indent)
        {
        s.c_._col--;
        w_.ptr[1]--;
        srv->gotorc_draw (w_.ptr[0], w_.ptr[1]);
        }

      continue;
      }
 
    if (any (keys->CTRL_y == s.c_._chr))
      {
      if (w_.ptr[1] < strlen (prev_l))
        {
        @line = substr (@line, 1, s.c_._col) + substr (prev_l, w_.ptr[1] + 1, 1)
          + substr (@line, s.c_._col + 1, - 1);
        s.c_._col++;
        w_.ptr[1]++;
        srv->write_nstring_dr (@line, COLUMNS, 0, [w_.ptr[0], 0, w_.ptr[0], w_.ptr[1]]);
        }

      continue;
      }

    if (any (keys->CTRL_e == s.c_._chr))
      {
      if (w_.ptr[1] < strlen (next_l))
        {
        @line = substr (@line, 1, s.c_._col) + substr (next_l, w_.ptr[1] + 1, 1) +
          substr (@line, s.c_._col + 1, - 1);
        s.c_._col++;
        w_.ptr[1]++;
        srv->write_nstring_dr (@line, COLUMNS, 0, [w_.ptr[0], 0, w_.ptr[0], w_.ptr[1]]);
        }

      continue;
      }

    if (any (keys->rmap.right == s.c_._chr))
      {
      if (s.c_._col < strlen (@line))
        {
        s.c_._col++;
        w_.ptr[1]++;
        srv->gotorc_draw (w_.ptr[0], w_.ptr[1]);
        }

      continue;
      }

    if (any (keys->rmap.home == s.c_._chr))
      {
      s.c_._col = s_._indent;
      w_.ptr[1] = s_._indent;
      srv->gotorc_draw (w_.ptr[0], w_.ptr[1]);

      continue;
      }

    if (any (keys->rmap.end == s.c_._chr))
      {
      s.c_._col = strlen (@line);
      w_.ptr[1] = strlen (@line);
      srv->gotorc_draw (w_.ptr[0], w_.ptr[1]);;

      continue;
      }

    if (any (keys->rmap.backspace == s.c_._chr))
      {
      if (0 < w_.ptr[1] - s_._indent)
        {
        @line = substr (@line, 1, s.c_._col - 1) + substr (@line, s.c_._col + 1, - 1);
        w_.ptr[1]--;
        s.c_._col--;
        }

      srv->write_nstring_dr (@line, COLUMNS, 0, [w_.ptr[0], 0, w_.ptr[0], w_.ptr[1]]);
 
      continue;
      }

    if (any (keys->rmap.delete == s.c_._chr))
      {
      @line = substr (@line, 1, s.c_._col) + substr (@line, s.c_._col + 2, - 1);

      srv->write_nstring_dr (@line, COLUMNS, 0, [w_.ptr[0], 0, w_.ptr[0], w_.ptr[1]]);
 
      continue;
      }

    if (' ' <= s.c_._chr <= 126 || 902 <= s.c_._chr <= 974)
      {
      @line = substr (@line, 1, s.c_._col) + char (s.c_._chr) +  substr (@line, s.c_._col + 1, - 1);
      s.c_._col++;
      w_.ptr[1]++;
      srv->write_nstring_dr (@line, COLUMNS, 0, [w_.ptr[0], 0, w_.ptr[0], w_.ptr[1]]);
      continue;
      }
    }
}

rl_.getline = &getline;
