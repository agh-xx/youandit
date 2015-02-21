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
 
    if ("closeshell" == argv[0])
      {
      type = Char_Type[0];
      _for index (1, CW.frames - 1)
        type = [type, "shell_type" == self.buffers[index].type];
 
      index = wherefirst (type);
      if (NULL == index)
       throw Break;

      self.framedelete (index+1;dont_goto_prompt, reread_buf);

      self.writeinfolines ();
      throw Break;
      }
    }
  catch Break: {}
  catch AnyError:
    root.lib.printtostdout (exception_to_array);
  finally:
    self.gotoprompt ();
}
