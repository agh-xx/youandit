define main (self)
{
  variable
   retval,
   str = "Test key:";
 
  srv->send_msg ("Testing keys function, carriage return to exit", 0);
  srv->write_prompt (str, strlen (str) + 1; prompt_char = "");
  retval = (@getch);

  while (retval != '\r')
    {
    if (any (keys->cmap.changelang == retval))
      {
      self.call ("change_getch");
      sleep (1);
 
      srv->send_msg(sprintf("int: %d hex: 0x%x octal: 0%o bin: %.8B char: %c",
        retval, retval, retval, retval, retval == 10 ? 32 : retval), 0);

      retval = (@getch);
      continue;
      }
 
    if (retval > (256 * 256))
      srv->send_msg(sprintf("  ESC_%c int: %d hex: 0x%x octal: 0%o bin: %.8B",
        retval - (256 * 256) + 1, retval, retval, retval, retval), 0);
    else
      srv->send_msg(sprintf("int: %d hex: 0x%x octal: 0%o bin: %.8B char: %c",
        retval, retval, retval, retval, retval == 10 ? 32 : retval), 0);

    srv->write_prompt (str, strlen (str) + 1; prompt_char = "");
    retval = (@getch);
    }

  srv->send_msg(sprintf("Integer: %d hex: 0x%x Octal: 0%o Binary: %.8B char: %c",
       retval, retval, retval, retval, retval == 10 ? 32 : retval), 0);

  throw GotoPrompt;
}

