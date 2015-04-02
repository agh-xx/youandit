define main (self, argv)
{
  variable
    buf,
    user = NULL != root.user,
    retval,
    list = {};

  if (user)
    user = struct_field_exists (root.user, "keys");

  try
    {
    if (assoc_key_exists (root.func.keys, argv[0]))
      {
      array_map (Void_Type, &list_append, list, argv[[1:]]);
 
      if (length (list))
        if (any ("--help" == list_to_array (list)))
          if (NULL == root.func.keys[argv[0]][4])
            {
            srv->send_msg (sprintf ("%s help: %s", argv[0], root.func.keys[argv[0]][2]), 0);
            throw GotoPrompt;
            }

      root.func.call (argv[0], __push_list (list));
      }
    else if (assoc_key_exists (root.wrappers.keys, argv[0]))
      {
      array_map (Void_Type, &list_append, list, argv[[1:]]);

      if (length (list))
        if (any ("--help" == list_to_array (list)))
          if (NULL == root.wrappers.keys[argv[0]][4])
            {
            srv->send_msg (sprintf ("%s help: %s", argv[0], root.wrappers.keys[argv[0]][2]), 0);
            throw GotoPrompt;
            }

      root.wrappers.call (argv[0], __push_list (list));
      }
    else if (user && assoc_key_exists (root.user.keys, argv[0]))
      {
      array_map (Void_Type, &list_append, list, argv[[1:]]);

      if (length (list))
        if (any ("--help" == list_to_array (list)))
          if (NULL == root.user.keys[argv[0]][4])
            {
            srv->send_msg (sprintf ("%s help: %s", argv[0], root.user.keys[argv[0]][2]), 0);
            throw GotoPrompt;
            }

      root.user.call (argv[0], __push_list (list));
      }
    else if (NULL != wherefirst (argv[0] == CORECOMS) ||
             NULL != wherefirst (argv[0] == USRCOMS) ||
             NULL != wherefirst (argv[0] == PERSCOMS))
      {
      variable
        isbg = 0,
        mainfname = NULL == CW.cur.mainbuf ? "/dev/null" : CW.cur.mainbuf,
        whatdir = NULL != wherefirst (argv[0] == CORECOMS)
          ? COREDIR
          : NULL != wherefirst (argv[0] == USRCOMS)
            ? USRCOMMANDSDIR
            : PERSCOMMANDSDIR;

      if (NULL == wherenot (strncmp (argv, "--execdir=", strlen ("--execdir="))))
        argv = [argv, sprintf ("--execdir=%s", whatdir)];

      if ("man" == argv[0])
        {
        mainfname = SCRATCHBUF;
        argv = [argv, "--fg", "--nocl", "--clear"];
        }

      if ("search" == argv[0])
        {
        mainfname  = sprintf ("%s/_list/list.list", TEMPDIR);
        argv = [argv, "--fg", "--clear", "--nocl"];
        }

      argv = [argv, "--mainfname=" + mainfname];
      argv = [argv, "--msgfname=" + CW.msgbuf];

      retval = proc->call (argv);

      if (NULL == retval)
        throw GotoPrompt;

      if ("man" == argv[0])
        {
        if (1 == retval)
          {
          sleep (1);
          CW.drawwind ();
          root.topline ();
          throw GotoPrompt;
          }
 
        ved (mainfname);

        throw GotoPrompt;
        }

      if ("search" == argv[0] && 0 == any ("--help" == argv)
          && 0 == any ("--info" == argv))
        {
        if (1 == retval)
          throw GotoPrompt;

        if (2 == retval)
          {
          srv->send_msg ("Nothing found to match pattern", 0);
          throw GotoPrompt;
          }

        ved (mainfname;ftype = "list");
        CW.drawwind ();
        root.topline ();

        throw GotoPrompt;
        }

      ifnot (NULL == CW.cur.mainbufframe)
        {
        buf = CW.buffers[CW.cur.mainbufframe];

        CW.dim[CW.cur.frame].infolinecolor = COLOR.info;
        CW.cur.frame = CW.cur.mainbufframe;
        CW.dim[CW.cur.mainbufframe].infolinecolor = COLOR.activeframe;
        CW.writeinfolines ();
        CW.drawwind ();
        }
      else
        CW.drawwind ();

      throw GotoPrompt;
      }
    else
      throw GotoPrompt;
    }
  catch GotoPrompt:
    throw GotoPrompt;
  catch Break:
    throw Break;
  catch AnyError:
    {
    root.lib.printtostdout (exception_to_array);
    throw GotoPrompt;
    }
}
