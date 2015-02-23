define main (self)
{
  variable name, cw, retval;

  ifnot (qualifier_exists ("force"))
    {
    retval = root.lib.ask (["do you want to quit?", "[y/n/escape to abort]"],
      ['y', 'n'];header = "QUESTION FROM QUIT FUNCTION");

    if ('n' == retval || 033 == retval)
      {
      srv->send_msg ("Aborting ...", 0);
      throw GotoPrompt;
      }
    }

  _for name (0, length (root.windnames) - 1)
    {
    cw = root.windows[root.windnames[name]];
    cw.history.write ();
    }

  root->exit_me (0, NULL);
}
