define main (self)
{
  ifnot (qualifier_exists ("dont_init"))
    {
    self.cur.line = "";
    self.cur.col = 1;
    self.cur.chr = 0;
    self.cur.argv = [""];
    self.cur.index = 0;
    }

  variable
    init,
    start,
    retval,
    routretv,
    command = NULL,
    keys = String_Type[0];

  forever
    {
    routretv = self.startroutine (&keys);
 
    if (1 == routretv)
      continue;

    if (-1 == routretv)
      throw Break;

    ifnot (strlen (self.cur.line))
      {
      routretv = self.nolength_routine (self.commands[1]);
 
      if (1 == routretv)
        continue;
      if (-1 == routretv)
        throw Break;
      }

    if ('\t' == self.cur.chr)
      {
      command = NULL;

      ifnot (NULL == self.cur.argv[0])
        command = self.cur.argv[0];

      (init, retval) = 0, 0;
      routretv = self.precommandroutine (command, &retval, &init);
 
      if (init)
        if (1 == retval)
          throw Break;
        else
          {
          self.parse_args ();
          self.my_prompt ();
          continue;
          }

      if (NULL != command && '-' != self.cur.argv[self.cur.index][0]
          && any (command == self.commands[0])
          && "repoadd" != command && "initializerepo" != command
          && "applypatch" != command)
        {
        routretv = self.mycompletion (&retval, command);
        if (1 == routretv)
          continue;
        }
      else if ((self.cur.index)
          && ((length (self.cur.argv) && ' ' == self.cur.line[-1])
          || (length (self.cur.argv) > 1 && self.cur.argv[self.cur.index][0] != '-')))
        {
        start = 0 == strlen (self.cur.argv[self.cur.index]) ? " " : self.cur.argv[self.cur.index];
        retval = self.filenamecompletion (start);
        }
      else if (0 == self.cur.index)
        retval = self.commandcompletion (self.commands[0];help=self.help);
      else if (length (self.cur.argv) && '-' == self.cur.argv[-1][0])
        {
        routretv = self.arg_routine (&retval, command);
        if (1 == routretv)
          continue;
        }
      else
        continue;

      if (1 == retval)
        throw Break;

      if (" " == self.cur.line)
        {
        self.cur.argv[0] = "";
        self.cur.col = 1;
        continue;
        }

      if (strlen (self.cur.line))
        if (any (["closeshell", "commit", "diff", "log", "lastlog",
            "logpatch", "status"] == self.cur.argv[0]))
          throw Break;

      if ('!' == self.cur.line[0])
        {
        self.cur.argv[0] = "";
        self.cur.col = 1;

        if (-1 == self.shell_routine (self.commands[1]))
          throw Break;
        }

      self.my_prompt ();
      continue;
      }

    if (-1 == self.endroutine ())
      throw Break;
    }
}
