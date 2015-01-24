variable
  EDITOR = "vim";

ifnot (access (sprintf ("%s/conf/etc/env.slc", USRNS), F_OK|R_OK))
  () = evalfile (sprintf ("%s/conf/etc/env", USRNS));
