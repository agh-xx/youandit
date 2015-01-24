private define newlinesinpat (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()));
}

private define routine (self, buf, linenr, prompt_char)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
      buf, linenr, prompt_char;;__qualifiers ());
}

private define buffersearch (self, row, col, buf, frame, frame_size, len)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
       row, col, buf, frame, frame_size, len;;__qualifiers());
}

private define searchexec (self, str, start, end)
{
  return self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
      str, start, end;;__qualifiers ());
}

private define origstr (self)
{
  return self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()));
}

private define forward (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()));
}

private define backward (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()));
}

private define dothesearch (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ());;__qualifiers());
}

define main (self)
{
  throw Return, " ", struct
    {
    exec = self.exec,
    newlinesinpat = &newlinesinpat,
    searchexec = &searchexec,
    dothesearch = &dothesearch,
    origstr = &origstr,
    forward = &forward,
    backward = &backward,
    buffer = &buffersearch,
    routine = &routine,
    type,
    pattern,
    ar,
    len,
    col,
    index,
    retval,
    linenr,
    start,
    end,
    wrap,
    newlines,
    history = {},
    orig_index,
    };
}
