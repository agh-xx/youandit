define main ()
{
  root.topline ();
  srv->send_msg ("Enter a valid math expression, use escape or carriage return to quit", 0);
  srv->write_prompt (NULL, 1;prompt_char = ">");
 
  variable rline = CW.readline;

  rline.cur.line = "";
  rline.cur.col = 1;
  rline.cur.chr = 0;
  rline.cur.argv = [""];
  rline.cur.index = 0;

  variable
    chr,
    res,
    isopen = 0,
    symbols = ['+', '-', '*', '/', '^', '(', ')'],
    modt = 'm',
    nrs = [['0':'9'], '.'],
    ctrls =
      [
      '\r', 033, ' ', keys->CTRL_a, keys->CTRL_b, keys->CTRL_e,
      keys->BACKSPACE, keys->RIGHT, keys->LEFT,
      keys->UP, keys->DOWN, keys->HOME, keys->END
      ],
    ar = [symbols, modt, nrs, ctrls];

  forever
    {
    rline.cur.chr = (@getch);
 
    ifnot (any (rline.cur.chr == ar))
      continue;

    if (any (['\r', 033] == rline.cur.chr))
      {
      rline.cur.argv = NULL;
      root.topline ();
      CW.drawwind (;dont_reread);
      break;
      }

    if (any ([keys->BACKSPACE, keys->CTRL_h] == rline.cur.chr))
      {
      if (rline.cur.col > 1)
        {
        chr = rline.cur.line[rline.cur.col - 2];
        if (any ([')', '('] == chr))
          if (')' == chr)
            isopen++;
          else
            isopen--;

        rline.delete_at ();
        rline.parse_args ();
        rline.my_prompt (;prompt_char = ">");
        }
      }

    if (keys->DELETE == rline.cur.chr)
      {
      if (rline.cur.col > strlen (rline.cur.line))
        continue;
 
      chr = rline.cur.line[rline.cur.col - 1];
      if (any ([')', '('] == chr))
        if (')' == chr)
          isopen++;
        else
          isopen--;

      rline.delete_at (;is_delete);
      rline.parse_args ();
      rline.my_prompt (;prompt_char = ">");
      }

    if (any ([keys->LEFT, keys->CTRL_b] == rline.cur.chr))
      {
      if (rline.cur.col > 1)
        {
        rline.cur.col--;
        rline.my_prompt (;prompt_char = ">");
        }

      continue;
      }

    if (keys->RIGHT == rline.cur.chr)
      {
      if (rline.cur.col <= strlen (rline.cur.line))
        {
        rline.cur.col++;
        rline.my_prompt (;prompt_char = ">");
        }

      continue;
      }

    if (any ([keys->CTRL_a, keys->HOME] == rline.cur.chr))
      {
      rline.cur.col = 1;
      rline.my_prompt (;prompt_char = ">");
      continue;
      }

    if (any ([keys->CTRL_e, keys->END] == rline.cur.chr))
      {
      rline.cur.col = strlen (rline.cur.line) + 1;
      rline.my_prompt (;prompt_char = ">");
      continue;
      }

    if (' ' == rline.cur.chr)
      {
      ifnot (strlen (rline.cur.line))
        continue;
 
      if (' ' == srv->char_at ())
        if (' ' == rline.cur.line[rline.cur.col - 2])
          continue;
      }
 
    if ('m' == rline.cur.chr)
      {
      if (strlen (rline.cur.line))
        %if (any (nrs == rline.cur.line[rline.cur.col - 2]))
        {
        rline.insert_at (;chr = 'm');
        rline.insert_at (;chr = 'o');
        rline.insert_at (;chr = 'd');
        rline.cur.col +=3;
        rline.parse_args ();
        rline.my_prompt (;prompt_char = ">");
        }

      continue;
      }

    chr = rline.cur.line[rline.cur.col - 2];

    if ('(' == rline.cur.chr)
      if (any ([symbols, 'd'] == rline.cur.line[rline.cur.col - 2])
        || any ([symbols, 'd'] == rline.cur.line[rline.cur.col - 3]) %fix (put an if to catch ws
          || 0 == strlen (rline.cur.line))
        isopen++;
      else
        continue;

    if (')' == rline.cur.chr)
      if (isopen)
        if (any ([['1':'9'], ' '] == rline.cur.argv[rline.cur.index - 1][0]))
          isopen--;
        else
          continue;
      else
        continue;

    ifnot (any ([keys->BACKSPACE, keys->CTRL_h] == rline.cur.chr))
      rline.insert_at ();
 
    rline.parse_args ();

    if (any ([['1':'9'], ' ', ')', [keys->BACKSPACE, keys->CTRL_h]] == rline.cur.chr))
      if (0 == any ([symbols, 'd'] == rline.cur.line[rline.cur.col - 2])
        || 0 == any ([symbols, 'd'] == rline.cur.line[rline.cur.col - 3])) %fix (put an if to catch ws
      try
        {
        res = eval (rline.cur.line);
        if (res == int (res))
          res = int (res);

        srv->send_msg_and_refresh ("= " + string (res), 0);
        }
      catch AnyError:
        srv->send_msg_and_refresh ("Error in expression: " + __get_exception_info.message, -1);

    rline.my_prompt (;prompt_char = ">");
    }

  srv->send_msg ("", 0);
  throw GotoPrompt;
}
