define f_ask (quest, ar)
{
  variable
    prompt = qualifier ("prompt", "Answer: "),
    promptlen = strlen (prompt),
    header = qualifier ("header", sprintf ("QUESTION from %s", __argv[0])),
    i,
    hl = qualifier ("hl"),
    retval;

  printtostdout (quest;just_print, header = header);
 
  ifnot (NULL == hl)
    _for i (0, length (hl) - 1)
      (@highlight) (hl[i].color, hl[i].row, hl[i].col, hl[i].dr, hl[i].dc);

  srv->write_prompt (prompt, promptlen;prompt_char = "");

  if (qualifier_exists ("get_ascii_input"))
    {
    variable
      chr,
      len;

    retval = "";

    chr = (@getch);

    while ('\r' != chr)
      {
      if (033 == chr)
        return NULL;

      if  (' ' <= chr <= 126)
        retval += char (chr);

      if (any (keys->cmap.backspace == chr))
        if (strlen (retval))
          retval = retval[[:-2]];
 
      len = strlen (retval) + promptlen;

      srv->write_prompt (sprintf ("%s%s", prompt, retval), len;prompt_char = "");

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

  srv->write_prompt (NULL, 0;prompt_char = "");
  return retval;
}
