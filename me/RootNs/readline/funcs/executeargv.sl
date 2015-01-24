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
        whatdir = NULL != wherefirst (argv[0] == CORECOMS) ?
          COREDIR : NULL != wherefirst (argv[0] == USRCOMS) ?
          USRCOMMANDSDIR : PERSCOMMANDSDIR;

      if (NULL == wherenot (strncmp (argv, "--execdir=", strlen ("--execdir="))))
        argv = [argv, sprintf ("--execdir=%s", whatdir)];

      if ("man" == argv[0])
        {
        mainfname = SCRATCHBUF;
        argv = [argv, "--fg", "--clear"];
        }

      if ("search" == argv[0])
        {
        mainfname  = sprintf ("%s/GrepList_%d", TMPDIR, _time);
        argv = [argv, "--fg", "--nocl"];
        }

      if ("help" == argv[0])
        {
        mainfname = sprintf ("%s/Help_Page_%d", TMPDIR, _time);
        argv = [argv, "--fg", "--nocl"];
        }

      argv = [argv, "--mainfname=" + mainfname];
      argv = [argv, "--msgfname=" + CW.msgbuf];

      retval = proc->call (argv);

      if (NULL == retval)
        throw GotoPrompt;

      if ("man" == argv[0] || "help" == argv[0])
        {
        if (1 == retval)
          {
          sleep (1);
          CW.drawwind ();
          root.topline ();
          throw GotoPrompt;
          }
 
        writefile (readfile (mainfname), SCRATCHBUF);
        CW.gotopager (;iamreal, file = SCRATCHBUF, send_break_at_exit);

        throw GotoPrompt;
        }

      if ("search" == argv[0]
          && 0 == any ("--help" == argv)
          && 0 == any ("--info" == argv))
        {
        variable ar = readfile (mainfname);
        ifnot (length (ar))
          {
          srv->send_msg ("no matches", 1);
          throw GotoPrompt;
          }

        ifnot (any ("list" == list_to_array (root.windnames)))
          {
          () = root.addwind ("list", "List_Type";
            reportlist = ar,
            dont_draw);

          root.func.call ("windowgoto", "list";reread_buf);
          }
        else
          {
          variable cw = root.windows["list"];
          cw.reportlist = ar;

          variable
            index,
            type = Char_Type[0];

          _for index (1, cw.frames - 1)
            type = [type, "list_type" == cw.buffers[index].type];

          index = wherefirst (type) + 1;
          buf = cw.buffers[index];
          writefile (ar, buf.fname);
          root.func.call ("windowgoto", "list"; reread_buf);
          }
      }

      ifnot (NULL == CW.cur.mainbufframe)
        {
        buf = CW.buffers[CW.cur.mainbufframe];

        CW.dim[CW.cur.frame].infolinecolor = COLOR.info;
        CW.cur.frame = CW.cur.mainbufframe;
        CW.dim[CW.cur.mainbufframe].infolinecolor = COLOR.activeframe;
        CW.writeinfolines ();
        CW.drawwind ();
        %CW.gotopager(;func="G", frame = CW.cur.mainbufframe);
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
