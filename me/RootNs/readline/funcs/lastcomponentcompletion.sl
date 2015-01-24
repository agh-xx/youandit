define main (self)
{
  ifnot (length (self.arg_last_component))
    throw Return, " ", 0;

  variable
    chr,
    line,
    i = 0,
    lcmp = strtrim (self.arg_last_component[i]),
    len = strlen (lcmp),
    col = self.cur.col;

  forever
    {
    line = sprintf ("%s%s%s", strjoin (self.cur.argv[[0:self.cur.index]], " "),
      lcmp, self.cur.index == length (self.cur.argv) ? "" :
      " " + strjoin (self.cur.argv[[self.cur.index+1:]], " "));
    self.my_prompt (;line = line, col = col + len);

    chr = input->en_getch;

    if (any ([' ', '\r'] == chr))
      {
      if (0 == strlen (self.cur.argv[self.cur.index])
        || " " == self.cur.argv[self.cur.index])
        self.cur.argv[self.cur.index] = lcmp;
      else
        self.cur.argv[self.cur.index] += lcmp;

      self.parse_args ();

      self.cur.col += strlen (lcmp);

      throw Return, " ", '\r' == chr;
      }

    if (any (keys->cmap.lastcmp == chr))
      {
      i = (i + 1) == length (self.arg_last_component) ? 0 : i + 1;
      lcmp = strtrim (self.arg_last_component[i]);
      len = strlen (lcmp);
      }
    }
}
