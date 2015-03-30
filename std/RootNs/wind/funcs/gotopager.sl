define main ()
{
  variable
    qualifiers = @__qualifiers (),
    args = __pop_list (_NARGS - 1);
  
  if (CW.type == "Shell_Type")
    qualifiers = struct {@qualifiers, func='G'};

  if (length (args))
    ved (__push_list (args);;qualifiers);
  else
    ved (;;qualifiers);
  
  ifnot (qualifier_exists ("drawonly"))
    CW.drawframe (CW.cur.frame);

  throw GotoPrompt;
}
