define printout (ar, col, len)
{
  ifnot (length (ar))
    {
    @len = 0;
    return @Array_Type[0];
    }

  variable
    i,
    l,
    lar,
    hlreg = qualifier ("hl_region"),
    lines = qualifier ("lines", LINES),
    origlen = @len,
    rows = [1:lines-3],
    nar = @len < lines - 3 ? @ar : ar[[:lines - 4]],
    header = qualifier ("header", repeat ("_", COLUMNS));

  _for i (0, length (nar) - 1)
    {
    l = strlen (nar[i]);
    if (l < COLUMNS)
      nar[i] = nar[i] + repeat (" ", COLUMNS - l);
    }

  if (@len < lines - 3)
    {
    lar = String_Type[lines-@len-3];
    lar[*] = repeat (" ", COLUMNS);
    nar = [nar, lar];
    }

  srv->write_str_at (sprintf ("%s%s", header,
     repeat (" ", COLUMNS - strlen (header))), qualifier ("head_clr", 3), 0, 0);

  srv->write_ar_at (nar, 11, rows, 0);

  ifnot (NULL == hlreg)
    srv->set_color_in_region (hlreg[0], hlreg[1], hlreg[2], hlreg[3], hlreg[4]);

  srv->gotorc (qualifier ("row", PROMPTROW), col < COLUMNS ? col : col - COLUMNS);
  srv->refresh;

  @len = @len >= lines - 2;

  return ar[[origlen >= lines ? lines - 4 : origlen:]];
}

define printtostdout (msg)
{
  variable
    chr,
    orig = msg,
    len = length (msg),
    str_len = strlen (strjoin (__argv, " ")) + 1,
    lines = LINES - (str_len / COLUMNS),
    col = str_len mod COLUMNS + 1,
    row = PROMPTROW;

  msg = printout (msg, col, &len;;struct {@__qualifiers, row = row, lines = lines});

  if (len)
    {
    srv->send_msg_and_refresh ("Press any key except tab to exit, press tab to scroll", 2);

    chr = (@getch);

    while (9 == chr)
      {
      len = length (msg);
 
      msg = printout (msg, col, &len;;struct {@__qualifiers, row = row, lines = lines});

      ifnot (len)
        msg = orig;
 
      chr = (@getch);
      }
    }
  else
    {
    if (qualifier_exists ("just_print"))
      return;

    srv->send_msg_and_refresh ("Press any key to exit", 0);
    () = (@getch);
    }

  srv->send_msg (NULL, 0);
}
