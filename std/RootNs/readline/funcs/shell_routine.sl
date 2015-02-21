define main (self, commands)
{
  variable
    type = Char_Type[0],
    i;

    _for i (1, CW.frames - 1)
      type = [type, "shell_type" == CW.buffers[i].type];

    ifnot (any (type))
      {
      CW.addframe (;type="shell_type");
      CW.cur.mainbufframe = CW.frames - 1;
      }

    CW.cur.mode = "shell";
    self.cur.mode = "shell";

    if (1 == self.commandcompletion (commands))
      throw Return, " ", -1;

    self.cur.col = 1 + strlen (self.cur.argv[0]);
    self.parse_args ();
    self.my_prompt ();
    throw Return, " ", 1;
}
