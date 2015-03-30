define main (self, quest, ar)
{
  variable
    i,
    retval,
    hl = qualifier ("hl"),
    prompt = qualifier ("prompt", "Answer: "),
    promptlen = strlen (prompt) + 1;
 
  root.lib.printtostdout (quest;just_print,
    last_row = PROMPTROW - (strlen (CW.readline.cur.line) / COLUMNS),
    header = qualifier ("header", "QUESTION"));

  srv->write_prompt (prompt, promptlen;prompt_char = "");
 
  ifnot (NULL == hl)
    _for i (0, length (hl) - 1)
      srv->set_color_in_region (hl[i].color, hl[i].row, hl[i].col, hl[i].dr, hl[i].dc);

  if (qualifier_exists ("get_ascii_input"))
    {
    variable
      chr,
      len;

    retval = "";

    chr = (@getch);

    while ('\r' != chr)
      {
      if  (' ' <= chr <= 126)
        retval += char (chr);

      if (any (keys->cmap.backspace == chr))
        retval = retval[[:-2]];
 
      len = strlen (retval) + promptlen;

      srv->write_prompt (sprintf ("%s %s", prompt, retval), len;prompt_char = "");

      chr = (@getch);
      }
    }
  else
    {
    retval = (@getch);

    while (NULL == wherefirst_eq (ar, retval) && 033 != retval)
      {
      srv->write_prompt (prompt, promptlen;prompt_char = "");
      retval = (@getch);
      }
    }

  CW.drawwind ();
  root.topline ();
  throw Return, "", retval;
}
