variable COLOR = struct
  {
  normal = "white",
  msgerror = "brightred",
  msgsuccess = "brightgreen",
  msgwarn = "brightmagenta",
  prompt = "yellow",
  border = "brightred",
  focus = "brightcyan",
  info = "blackonred",
  activeframe = "blackonyellow",
  hlchar = "blackonyellow",
  out = "yellow",
  hlregion = "white",
  hlhead = "brown",
  topline = "blackonbrown",
  };

ifnot (access (sprintf ("%s/conf/colors/Init.slc", USRNS), F_OK|R_OK))
  () = evalfile (sprintf ("%s/conf/colors/Init", USRNS));
