define main (self, argv)
{
  variable
    index,
    type,
    frame,
    bufa = self.buffers[0];
 
  try
    {
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
 
    if ("refresh" == argv[0])
      {
      forever
        {
        self.pid = proc->call (self.argv);
        root.topline ();
        self.drawframe (0;reread_buf);
        srv->write_prompt (NULL, 0;prompt_char = "");
        srv->refresh ();
        variable chr = input->getch_until (10);
        ifnot (NULL == chr)
          if ('q' == chr)
            break;
        }
      }
    }
  catch Break: {}
  catch AnyError:
    root.lib.printtostdout (exception_to_array);
  finally:
  {
  self.drawframe (0;reread_buf);
  self.gotoprompt ();
  }
}
