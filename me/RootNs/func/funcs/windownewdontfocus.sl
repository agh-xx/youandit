define main ()
{
  variable
    retval,
    name,
    self,
    type;

  if (_NARGS != 3)
    {
    srv->send_msg ("A window type and a window name are required", -1);
    if (qualifier_exists ("dont_goto_prompt"))
      throw Break;
    throw GotoPrompt;
    }

  name = ();
  type = ();
  self = ();

  if (length (root.windnames))
    if (any (name == list_to_array (root.windnames)))
      {
      srv->send_msg (sprintf ("window %s: already exists", name), -1);

      if (qualifier_exists ("dont_goto_prompt"))
        throw Break;
      throw GotoPrompt;
      }

  try
    retval = root.addwind (name, type;dont_draw);
  catch AnyError:
    {
    root.lib.printtostdout (["initialization error during window creation",
        exception_to_array ()]);
    if (qualifier_exists ("dont_goto_prompt"))
      throw Break;
    throw GotoPrompt;
    }
 
  if (NULL == retval)
    srv->send_msg (sprintf ("failed to create new window, type = %s, name = %s",
      type, name), -1);

  if (qualifier_exists ("dont_goto_prompt"))
    throw Break;

  srv->send_msg (sprintf ("%s window named `%s' was created", type, name), 0);

  throw GotoPrompt;
}

