define main (self, row, col, buf, frame, frame_size, len)
{
  self.type = qualifier ("type", "forward");
  self.pattern = qualifier ("pattern", "");
  self.retval = 0;
  self.ar = readfile (qualifier ("file", buf.fname));
  self.len = len;
  self.start = @col;
  self.end = NULL;
  self.col = @col;

  variable
    histindex = length (self.history),
    index = buf.indices[wherefirst_eq (buf.rows, @row)],
    start = @col,
    linenr,
    prompt_char = "forward" == self.type ? "/" : "?",
    chr;

  self.index = index;
  linenr = index;

  if (start == strlen ((@CW.getbufline) (CW, buf, qualifier ("file", buf.fname),
    index)))
    {
    if (self.type == "backwards")
      linenr = index == 0 ? self.len : index - 1;
    else
      linenr = self.len == index ? 0 : index + 1;

    self.col = 0;
    }
 
  if (qualifier_exists ("dothesearch"))
    self.routine (buf, &linenr, prompt_char;;__qualifiers ());
    %if (1 == self.retval)
    %  {
    %  CW.pcount = linenr + 1;
    %  (@CW.pfuncs["go_to_line"]) (CW, row, &self.start, buf, frame,
    %    frame_size, len;go_anyway);
    %  @col = self.start;
    %  srv->write_prompt (NULL, 0; prompt_char = "");
    %  }
    %
    %throw Break;
  else
    {
    srv->send_msg (sprintf (
      "incremental %s search, press escape to exit, CTRL to accept any match", self.type), 0);
    srv->write_prompt (NULL, 1; prompt_char = prompt_char);
    }

  chr = (@getch);

  while (033 != chr)
    {
    if ('\r' == chr)
      if (1 == self.retval)
        {
        list_append (self.history, self.pattern);
        CW.pcount = linenr + 1;
        (@CW.pfuncs["go_to_line"]) (CW, row, &self.start, buf, frame,
          frame_size, len;;struct {@__qualifiers, go_anyway});
        @col = self.start;
        srv->write_prompt (NULL, 0; prompt_char = "");
        throw Break;
        }
      else
        throw Break;

  if (any (keys->cmap.changelang == chr))
    {
    root.func.call ("change_getch");
    srv->write_prompt (self.pattern, strlen (self.pattern) + 1; prompt_char = prompt_char);
    chr = (@getch);
    continue;
    }

  if (any (keys->cmap.histup == chr))
    {
    histindex--;
    if (0 > histindex)
      {
      chr = (@getch);
      continue;
      }

    self.pattern = self.history[histindex];
    srv->write_prompt (self.pattern, strlen (self.pattern) + 1; prompt_char = prompt_char);
    self.routine (buf, &linenr, prompt_char;;__qualifiers ());
    chr = (@getch);

    continue;
    }

  if (any (keys->cmap.backspace == chr))
    {
    self.pattern = substr (self.pattern, 1, strlen (self.pattern) - 1);

    self.routine (buf, &linenr, prompt_char;;__qualifiers ());

    chr = (@getch);
    continue;
    }

  if (any (keys->search.next == chr))
    {
    if (self.retval)
      if ("forward" == self.type)
        linenr = linenr == self.len ? 0 : linenr + 1;
      else
        linenr = linenr == 0 ? self.len : linenr - 1;
    else
      {
      chr = (@getch);
      continue;
      }
    }
  else
    if ((' ' <= chr < 64505) &&
        0 == any (chr == [keys->cmap.backspace, keys->cmap.delete,
        [keys->UP:keys->RIGHT], [keys->F1:keys->F12]]))
    self.pattern += char (chr);

  self.routine (buf, &linenr, prompt_char;;__qualifiers ());

  chr = (@getch);
  }

  throw Break;
}
