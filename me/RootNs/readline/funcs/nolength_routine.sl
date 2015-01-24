define main (self, commands)
{
  if ('@' == self.cur.chr && NULL == struct_field_exists (self, "disable_pager"))
   CW.gotopager ();
  else if ('!' == self.cur.chr && NULL == struct_field_exists (self, "disable_shell"))
    throw Return, " ", self.shell_routine (commands);
  else if (any (keys->cmap.wind.mode == self.cur.chr))
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
    }

  throw Return, " ", 0;
}
