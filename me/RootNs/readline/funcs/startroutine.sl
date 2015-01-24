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

  if (any (keys->cmap.winddel == self.cur.chr))
    root.func.call ("windowdelete");

  if (any (keys->cmap.windprev == self.cur.chr))
    root.func.call ("windowprev");

  if (any (keys->cmap.root == self.cur.chr))
    root.func.call ("windowgoto", mytypename);

  ifnot (NULL == keys->cmap.battery)
    if (any (keys->cmap.battery == self.cur.chr))
      {
      retval = root.func.call ("battery";dont_goto_prompt);
      srv->send_msg_and_refresh (retval[0], atoi (retval[1]));
      self.my_prompt ();
      }
 
  if (any (keys->cmap.windgoto == self.cur.chr))
    {
    winds = list_to_array (root.windnames);
    winds = winds[wherenot ((winds == CW.name) or (winds == mytypename))];

    ifnot (length (winds))
      {
      srv->send_msg ("There is only one window", 1);
      self.my_prompt ();
      self.cur.chr = (@getch);
      throw Return, " ", 0;
      }

    self.cur.line = "";
    self.cur.col = 1;
    self.my_prompt ();

    retval = self.commandcompletion (winds;header = "go to window:", accept_one_len);

    ifnot (retval)
      if (strlen (self.cur.argv[0])
          && any (self.cur.argv[0] == winds[wherenot (winds == CW.name)]))
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

  if (any (keys->cmap.changelang == self.cur.chr))
    {
    root.func.call ("change_getch");
    self.my_prompt ();
    throw Return, " ", 1;
    }

  if (1 == self.cur.col)
    srv->send_msg ("", 0);

  if (any (keys->cmap.wrappers == self.cur.chr))
    {
    if (NULL == root.wrappers)
      throw Return, " ", 1;

    (command, @keys, values) = NULL, String_Type[0], String_Type[0];

    ifnot (NULL == self.cur.argv[0])
      command = self.cur.argv[0];

    foreach k,v (root.wrappers.keys) using ("keys", "values")
      {
      ifnot (NULL == command)
        ifnot (strncmp (k, command, strlen (k)))
          {
          self.cur.mode = "wrappers";
          throw Return, " ", -1;
          }

      @keys = [@keys, k];
      values = [values, v[2]];
      }

    indices = array_sort (@keys);
    @keys = (@keys)[indices];
    values = values[indices];

    if (1 == self.commandcompletion (@keys;help = values, header = "wrapper function:"))
      {
      self.cur.mode = "wrappers";
      throw Return, " ", -1;
      }
 
    self.cur.mode = "wrappers";
    self.my_prompt ();
    throw Return, " ", 1;
    }

  if (any (keys->cmap.pers == self.cur.chr))
    {
    if (NULL == root.user)
      throw Return, " ", 1;

    (command, @keys, values) = NULL, String_Type[0], String_Type[0];

    ifnot (NULL == self.cur.argv[0])
      command = self.cur.argv[0];

    foreach k,v (root.user.keys) using ("keys", "values")
      {
      ifnot (NULL == command)
        ifnot (strncmp (k, command, strlen (k)))
          {
          self.cur.mode = "user";
          throw Return, " ", -1;
          }

      @keys = [@keys, k];
      values = [values, v[2]];
      }

    indices = array_sort (@keys);
    @keys = (@keys)[indices];
    values = values[indices];

    if (1 == self.commandcompletion (@keys;help = values, header = "user function:"))
      {
      self.cur.mode = "user";
      throw Return, " ", -1;
      }
 
    self.cur.mode = "user";
    self.my_prompt ();
    throw Return, " ", 1;
    }

  if (any (keys->cmap.sys == self.cur.chr))
    {
    (command, @keys, values) = NULL, String_Type[0], String_Type[0];

    ifnot (NULL == self.cur.argv[0])
      command = self.cur.argv[0];

    foreach k,v (root.func.keys) using ("keys", "values")
      {
      ifnot (NULL == command)
        ifnot (strncmp (k, command, strlen (k)))
          {
          self.cur.mode = "func";
          throw Return, " ", -1;
          }

      @keys = [@keys, k];
      values = [values, v[2]];
      }

    indices = array_sort (@keys);
    @keys = (@keys)[indices];
    values = values[indices];

    if (1 == self.commandcompletion (@keys;help = values, header = "system function:"))
      {
      self.cur.mode = "func";
      throw Return, " ", -1;
      }

    if (strlen (self.cur.line) && " " != self.cur.line)
      if (any (["battery", "change_getch", "halt", "halt!", "reboot",
          "reboot!", "pwd", "q!", "quit", "testkey", "windownext"] ==
          self.cur.argv[0]))
        {
        self.cur.mode = "func";
        throw Return, " ", -1;
        }

    self.cur.mode = "func";
    self.my_prompt ();
    throw Return, " ", 1;
    }

  if (any (keys->cmap.app == self.cur.chr))
    {
    retval = self.commandcompletion (root.app.name;
      help = root.app.help, header = "application:", return_on_esc);
 
    if (033 == retval || 0 == strlen (self.cur.line))
      {
      CW.drawwind (;dont_reread);
      root.topline ();

      self.cur.argv = NULL;
      throw Return, " ", -1;
      }
 
    ifnot (any (root.app.name == (self.cur.argv[0])))
      {
      self.my_prompt ();
      throw Return, " ", 1;
      }

    root.func.call ("windownew", root.app.type[
        wherefirst (self.cur.argv[0] == root.app.name)], self.cur.argv[0];
        typedir = root.app.dir[wherefirst (self.cur.argv[0] == root.app.name)]);
    }

  throw Return, " ", 0;
}
