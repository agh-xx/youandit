define main (self, keys)
{
  variable
    i,
    k,
    v,
    chr,
    winds,
    retval,
    command,
    indices,
    values = String_Type[0];
 
  if (any (keys->cmap.lastcur == self.cur.chr))
    {
    self.cur.chr = 0;
    self.lastcur = @self.cur;

    self.cur.line = "";
    self.cur.col = 1;
    self.cur.argv = [""];
    self.cur.index = 0;
    self.cur.state = 1;

    self.parse_args ();

    root.topline ();
    self.my_prompt ();
    throw Return, " ", 0;
    }

  if (any (keys->cmap.windnext == self.cur.chr))
    root.func.call ("windownext");

  if (any (keys->cmap.windprev == self.cur.chr))
    root.func.call ("windowprev");
 
  ifnot (NULL == keys->cmap.battery)
    if (any (keys->cmap.battery == self.cur.chr))
      {
      retval = root.func.call ("battery";dont_goto_prompt);
      srv->send_msg_and_refresh (retval[0], atoi (retval[1]));
      self.my_prompt ();
      }
 
  if (any (keys->cmap.windgoto == self.cur.chr))
    {
    self.cur.line = "";
    self.cur.col = 1;
    self.my_prompt ();

    retval = self.commandcompletion ((winds = list_to_array (root.windnames),
      winds[wherenot (winds == CW.name)]);header = "go to window:", accept_one_len);

    ifnot (retval)
      if (strlen (self.cur.argv[0]) && any (self.cur.argv[0] == winds[wherenot (winds == CW.name)]))
        root.func.call ("windowgoto", self.cur.argv[0]);

    self.cur.chr = (@getch);
    throw Return, " ", 1;
    }

  if (' ' == self.cur.chr && " " == self.cur.line)
    {
    self.cur.line = "";
    self.cur.col = 1;

    self.my_prompt ();
    }

  self.cur.chr = (@getch);

  if (1 == self.cur.col)
    srv->send_msg ("", 0);

  throw Return, " ", 0;
}
