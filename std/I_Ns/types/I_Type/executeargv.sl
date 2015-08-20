define main (self, argv)
{
  variable
    retval,
    gotopager = 0,
    routine = 1,
    buf = self.buffers[0];

  try
    {
    switch (argv[0])

      {
      case "checknet":
      retval = proc->get ("isconnected", "isconnected";type = 1);
      ifnot (retval)
        srv->send_msg ("Not connected", -1);
      else
        srv->send_msg ("Is connected", 0);

      throw Break;
      }
 
      {
      case "trytofixbrokenwindow":
        if (1 == length (argv))
          {
          srv->send_msg ("trytofixbrokenwindow: needs an argument (window name)", -1);
          throw Break;
          }

        variable
          name = wherefirst (list_to_array (root.windnames) == argv[1]);

        if (NULL == name)
          {
          srv->send_msg (sprintf ("%s: No such window", argv[1]), -1);
          throw Break;
          }
 
        name = root.windnames[name];
        variable
          wind = root.windows[name],
          buffer = wind.buffers[wind.cur.frame],
          buffname = buffer.fname,
          windbuf = readfile (buffname);

        if (NULL == windbuf || 0 == length (windbuf))
          writefile (["Re initialize"], buffname);
        else
          {
          variable st = stat_file (buffname);
          () = utime (buffname, st.st_atime, _time ());
          }

        throw Break;
      }

      {
      case "bytecompile":
        self.bytecompile (buf.fname, &gotopager);
      }
 
      {
      case "debugconsole":
        self.ag ();
      }

      {
      case "sync_this_tree":
        if (1 == length (argv))
          {
          srv->send_msg ("sync_this_tree: needs an argument (directory)", -1);
          throw Break;
          }

        retval = proc->call (["synccurrenttree", "--nocl",
          argv[1],
          sprintf ("--execdir=%s/proc", path_dirname (__FILE__)),
          sprintf ("--msgfname=%s", buf.fname),
          sprintf ("--mainfname=%s", buf.fname)]);
 
        ifnot (retval)
          self.bytecompile (buf.fname, &gotopager);
      }

      {
      case "sync_another_tree":
        if (1 == length (argv))
          {
          srv->send_msg ("sync_another_tree: needs an argument (directory)", -1);
          throw Break;
          }

      retval = proc->call (["syncanothertree", "--nocl",
           argv[1],
           sprintf ("--execdir=%s/proc", path_dirname (__FILE__)),
           sprintf ("--msgfname=%s", buf.fname),
           sprintf ("--mainfname=%s", buf.fname)]);
      }

      {
      case "backuptree":
        if (1 == length (argv))
          {
          srv->send_msg ("backuptree: needs an argument (directory)", -1);
          throw Break;
          }

      retval = proc->call (["backupcurrenttree", "--nocl",
           argv[1],
           sprintf ("--execdir=%s/proc", path_dirname (__FILE__)),
           sprintf ("--msgfname=%s", buf.fname),
           sprintf ("--mainfname=%s", buf.fname)]);
      }

      {
      case "clear":
        root.func.call ("clear";dont_ask);
      }

      {
      case "q!":
        root.func.call ("q!");
      }
    }
  catch Break:
    routine = NULL;
  catch AnyError:
    root.lib.printtostdout (exception_to_array ());
  finally:
    {
    ifnot (NULL == routine)
      {
      %self.drawframe (0;reread_buf);
      %self.setinfoline (buf, 0, length (buf.ar_len));
      %self.writeinfolines ();
      ifnot (gotopager)
        ved (buf.fname;drawonly, func='G');
      else
        ved (buf.fname;func='G');
      }

    self.gotoprompt ();
    }
}
