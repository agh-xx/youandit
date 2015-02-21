define main ()
{
  CORECOMS = array_map (String_Type, &path_sans_extname, (listdir (COREDIR)));

  if ( NULL == which ("groff")
    || NULL == which ("gzip")
    || NULL == which ("col"))
    {
    CORECOMS[wherefirst ("man" == CORECOMS)] = NULL;
    CORECOMS = CORECOMS[wherenot (_isnull (CORECOMS))];
    }
 
  CORECOMS = CORECOMS[array_sort (CORECOMS)];
 
  USRCOMS =  listdir (USRCOMMANDSDIR);
  ifnot (NULL == USRCOMS)
    {
    USRCOMS = array_map (String_Type, &path_sans_extname, USRCOMS);
    USRCOMS = USRCOMS[array_sort (USRCOMS)];
    }
  else
    USRCOMS = String_Type[0];
 
  PERSCOMS = listdir (PERSCOMMANDSDIR);
  ifnot (NULL == PERSCOMS)
    {
    PERSCOMS = array_map (String_Type, &path_sans_extname, PERSCOMS);
    PERSCOMS = PERSCOMS[array_sort (PERSCOMS)];
    }
  else
    PERSCOMS = String_Type[0];
 
  COMMANDS = [CORECOMS, USRCOMS, PERSCOMS];
 
  root.user = root.exec (sprintf ("%s/functions/Init", USRNS));

  ifnot (access (sprintf ("%s/functions/Init.slc", PERSNS), F_OK))
    root.exec (sprintf ("%s/functions/Init", PERSNS), root.user.keys);
 
  ifnot (access (sprintf ("%s/commands/wrappers/Init.slc", USRNS), F_OK))
    root.wrappers = root.exec (sprintf ("%s/commands/wrappers/Init", USRNS));

  variable cw, i;
  _for i (0, length (root.windnames) - 1)
    {
    cw = root.windows[root.windnames[i]];
    if ("Shell_Type" == cw.type || "Root_Type" == cw.type)
      cw.readline.commands[0] = COMMANDS;
    else
      if (2 == length (cw.readline.commands))
        cw.readline.commands[1] = COMMANDS;
      else
        cw.readline.commands[0] = COMMANDS;
    }

  root.app = root.exec (sprintf ("%s/Init", STDTYPESDIR));

  ifnot (access (sprintf ("%s/Init.slc", USRTYPESDIR), F_OK))
    root.app = root.exec (sprintf ("%s/Init", USRTYPESDIR), root.app);

  ifnot (access (sprintf ("%s/Init.slc", PERSTYPESDIR), F_OK))
    root.app = root.exec (sprintf ("%s/Init", PERSTYPESDIR), root.app);
 
  if (DEV)
    {
    ifnot (is_defined ("DEVCOMS"))
      variable DEVCOMS;

    ifnot (is_defined ("DEVNS"))
      variable DEVNS = sprintf ("%s/it", BINDIR);
    else
      DEVNS = sprintf ("%s/it", BINDIR);

    DEVCOMS = listdir (sprintf ("%s/commands", DEVNS));
    ifnot (NULL == DEVCOMS)
      {
      DEVCOMS = array_map (String_Type, &path_sans_extname, DEVCOMS);
      DEVCOMS = DEVCOMS[array_sort (DEVCOMS)];
      }
    else
      DEVCOMS = String_Type[0];

    COMMANDS = [COMMANDS, DEVCOMS];

    ifnot (access (sprintf ("%s/functions/Init.slc", DEVNS), F_OK))
      root.exec (sprintf ("%s/functions/Init", DEVNS), root.user.keys);

    ifnot (access (sprintf ("%s/types/Init.slc", DEVNS), F_OK))
      root.app = root.exec (sprintf ("%s/types/Init", DEVNS), root.app);
    }

  variable sorted = array_sort (root.app.name);
  root.app.name = root.app.name[sorted];
  root.app.type = root.app.type[sorted];
  root.app.help = root.app.help[sorted];
  root.app.dir = root.app.dir[sorted];

  if (qualifier_exists ("dont_goto_prompt"))
    throw Break;

  throw GotoPrompt;
}
