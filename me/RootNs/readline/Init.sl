
% [Started testing]
% loading dynamically functions who share the same name,
% with (perhaps) different arglist
% but with the same returned (if any) value
% the idea is to optimize functions
%
% load () syntax:
% load (load_from_dir, function_name, create_namescpace;specific_qualifiers)

if (load ("file", "append_dir_indicator", 0) == -1)
  {
  variable err = ();
  root->exit_me (1, strjoin (err, "\n"));
  }

if (load ("hl", "form_ar", 1;barpointer = 1) == -1)
  {
  variable err = ();
  root->exit_me (1, strjoin (err, "\n"));
  }

if (load ("hl", "hl_item", 1) == -1)
  {
  variable err = ();
  root->exit_me (1, strjoin (err, "\n"));
  }

private define parse_args (self)
{
  variable
    i,
    found = NULL;

  (self.cur.line, self.cur.index) = "", NULL;

  _for i (0, length (self.cur.argv) - 1)
    ifnot (NULL == self.cur.argv[i])
      ifnot (strlen (self.cur.argv[i]))
        if (i)
          if (NULL == found)
            found = 1;
          else
            {
            found = NULL;
            self.cur.argv[i] = NULL;
            self.cur.col --;
            }

  self.cur.argv = self.cur.argv[wherenot (_isnull (self.cur.argv))];
 
  _for i (0, length (self.cur.argv) - 1)
    {
    self.cur.line = sprintf ("%s%s%s", self.cur.line, strlen (self.cur.line) ? " " : "", self.cur.argv[i]);
 
    if (NULL == self.cur.index)
      if (self.cur.col <= strlen (self.cur.line))
        self.cur.index = i - (self.cur.col == strlen (self.cur.line) - strlen (self.cur.argv[i]));
    }
 
  ifnot (strlen (self.cur.line))
    (self.cur.argv, self.cur.index) = [""], 0;

  if (NULL == self.cur.index)
    self.cur.index = length (self.cur.argv) - 1;
 
  if (self.cur.col == strlen (self.cur.line) && 2 == length (self.cur.argv) - self.cur.index)
    self.cur.argv = self.cur.argv[[:-2]];

  if (self.cur.col > strlen (self.cur.line) + 1)
    self.cur.col = strlen (self.cur.line) + 1;
}

private define my_prompt (self)
{
  variable
    i,
    row,
    col,
    orig_col = qualifier ("col", self.cur.col),
    prompt_char = qualifier ("prompt_char", ":"),
    str = sprintf ("%s%s", prompt_char, qualifier ("line", self.cur.line)),
    len = strlen (str),
    state = (len / COLUMNS) + 1,
    rows = Integer_Type[state],
    ar = String_Type[state];

  _for i (0, state - 1)
    (ar[i], rows[i]) = substr (str, int (sum (strlen (ar))) + 1, COLUMNS),
      PROMPTROW - (state - i - 1);

  i = 0;
  while ((i + 1) * COLUMNS <= orig_col)
    i++;

  row = rows[i];
  col = orig_col - (COLUMNS * i);
 
  if (state < self.cur.state)
    if (2 < self.cur.state)
      CW.drawframe (CW.frames - 1);
    else
      CW.writeinfolines ();

  self.cur.state = state;

  srv->multi_rline_prompt (rows, ar, COLOR.prompt, row, col);
}

private define readline (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers ());
}

private define startroutine (self, keys)
{
  return self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    keys;;__qualifiers ());
}

private define precommandroutine (self, command, retval, init)
{
  return self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    command, retval, init;;__qualifiers ());
}

private define commandroutine (self, command, retval)
{
  return self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    command, retval;;__qualifiers ());
}

private define nolength_routine (self, commands)
{
  return self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    commands;;__qualifiers ());
}

private define shell_routine (self, commands)
{
  return self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    commands;;__qualifiers ());
}

private define arg_routine (self, retval, command)
{
  return self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    retval, command;;__qualifiers ());
}

private define endroutine (self)
{
  return self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers ());
}

private define routine (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers ());
}

private define delete_at (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers ());
}

private define insert_at (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers ());
}

private define listdirectory (self, retval, dir, pat, pos)
{

  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    retval, dir, pat, pos ;;__qualifiers ());
}

private define filenamecompletion (self, start)
{
  return self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    start;;__qualifiers ());
}

private define getpattern (self, pat)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    pat;;__qualifiers ());
}

private define filenamecompletiontoprow (self, start)
{
  return self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    start;;__qualifiers ());
}

private define appendslash (self, file)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    file;;__qualifiers);
}

private define firstindices (self, str, ar, pat)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    str, ar, pat;;__qualifiers);
}

private define historycompletion (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers);
}

private define commandcompletion (self, commands)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    commands;;__qualifiers);
}

private define getargv (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers);
}

private define executeargv (self, argv)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    argv;;__qualifiers);
}

private define argcompletion (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers ());
}

private define lastcomponentcompletion (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers);
}

private define getsingleline (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers);
  return self.cur.line;
}

private define funccompletion (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers);
}

define main (self)
{
  throw Return, " ", struct
    {
    cur = struct
      {
      col,
      chr,
      line,
      argv,
      index,
      state = 1,
      mode,
      },
    lastcur,
    commands,
    arg_last_component = {},
    exec = self.exec,
    getargv = &getargv,
    routine = &routine,
    readline = &readline,
    my_prompt = &my_prompt,
    delete_at = &delete_at,
    insert_at = &insert_at,
    endroutine = &endroutine,
    parse_args = &parse_args,
    getpattern = &getpattern,
    executeargv = &executeargv,
    appendslash = &appendslash,
    arg_routine = &arg_routine,
    startroutine = &startroutine,
    firstindices = &firstindices,
    getsingleline = &getsingleline,
    argcompletion = &argcompletion,
    listdirectory = &listdirectory,
    shell_routine = &shell_routine,
    funccompletion = &funccompletion,
    commandroutine = &commandroutine,
    nolength_routine = &nolength_routine,
    precommandroutine = &precommandroutine,
    historycompletion = &historycompletion,
    commandcompletion = &commandcompletion,
    filenamecompletion = &filenamecompletion,
    lastcomponentcompletion = &lastcomponentcompletion,
    filenamecompletiontoprow = &filenamecompletiontoprow,
    };
}
