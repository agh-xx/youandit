define main (self, argv)
{
  variable
    index,
    type,
    frame,
    bufa = self.buffers[0];

  try
    {
    if ("n" == argv[0])
      self.jumptoitem ("+");

    if ("p" == argv[0])
        self.jumptoitem ("-");
    }
  catch Break: {}
  catch AnyError:
    root.lib.printtostdout (exception_to_array);
  finally:
    self.gotoprompt ();
}
