define main (self, commands)
{
  if ('@' == self.cur.chr && NULL == struct_field_exists (self, "disable_pager"))
   CW.gotopager ();
 
  if ('!' == self.cur.chr && NULL == struct_field_exists (self, "disable_shell"))
    throw Return, " ", self.shell_routine (commands);

  if (any (keys->cmap.wind.mode == self.cur.chr))
    {
    variable chr = (@getch);
 
    if (any (keys->cmap.wind.split == chr)
        && NULL == struct_field_exists (self, "disable_addframe"))
      CW.addframe (;goto_prompt);
 
    if (any (keys->cmap.wind.frnext == chr))
      root.func.call ("framenext");
 
    if (any (keys->cmap.wind.frprev == chr))
      root.func.call ("frameprev");

    if (any (keys->cmap.wind.frdel == chr))
      CW.framedelete (CW.cur.frame);

    if ('0' == chr)
      ifnot (CW.name == root.windnames[0])
        root.func.call ("windowgoto", root.windnames[0]);
 
    if ('1' == chr)
      ifnot (CW.name == root.windnames[1])
        root.func.call ("windowgoto", root.windnames[1]);

    if ('2' == chr)
      if (length (root.windnames) > 2)
        ifnot (CW.name == root.windnames[2])
          root.func.call ("windowgoto", root.windnames[2]);

    if ('3' == chr)
      if (length (root.windnames) > 3)
        ifnot (CW.name == root.windnames[3])
          root.func.call ("windowgoto", root.windnames[3]);

    if ('4' == chr)
      if (length (root.windnames) > 4)
        ifnot (CW.name == root.windnames[4])
          root.func.call ("windowgoto", root.windnames[4]);

    if ('5' == chr)
      if (length (root.windnames) > 5)
        ifnot (CW.name == root.windnames[5])
          root.func.call ("windowgoto", root.windnames[5]);

    if ('6' == chr)
      if (length (root.windnames) > 6)
        ifnot (CW.name == root.windnames[6])
          root.func.call ("windowgoto", root.windnames[6]);

    if ('7' == chr)
      if (length (root.windnames) > 7)
        ifnot (CW.name == root.windnames[7])
          root.func.call ("windowgoto", root.windnames[7]);

    if ('8' == chr)
      if (length (root.windnames) > 8)
        ifnot (CW.name == root.windnames[8])
          root.func.call ("windowgoto", root.windnames[8]);

    if ('9' == chr)
      if (length (root.windnames) > 9)
        ifnot (CW.name == root.windnames[9])
          root.func.call ("windowgoto", root.windnames[9]);
    }


  throw Return, " ", 0;
}
