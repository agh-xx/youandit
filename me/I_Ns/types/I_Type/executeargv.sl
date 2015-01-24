define main (self, argv)
{
  variable
    retval,
    routine = 1,
    buf = self.buffers[0];

  try
    {
    switch (argv[0])
 
      {
      case "bytecompile":
      retval = proc->call (["bytecompile", __argv[0], "--nocl",
           sprintf ("--execdir=%s/proc", path_dirname (__FILE__)),
           sprintf ("--msgfname=%s", buf.fname),
           sprintf ("--mainfname=%s", buf.fname)]);
 
      if (retval)
        writefile (sprintf ("ERROR\nEXIT_CODE: %d", retval), buf.fname;mode = "a");
      else
        writefile (["bytecompile completed with no errors", repeat ("_", COLUMNS)], buf.fname;
          mode = "a");
      }
 
      {
      case "debugconsole":
        self.ag ();
      }

      {
      case "synctree":
        if (1 == length (argv))
          {
          srv->send_msg ("synctree: needs an argument (directory)", -1);
          throw Break;
          }

      retval = proc->call (["synccurrenttree", "--nocl",
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
    }
  catch Break:
    routine = NULL;
  catch AnyError:
    root.lib.printtostdout (exception_to_array ());
  finally:
    {
    ifnot (NULL == routine)
      {
      self.drawframe (0;reread_buf);
      self.setinfoline (buf, 0, length (buf.ar_len));
      self.writeinfolines ();
      self.gotopager(;func="G", frame = 0);
      }

    self.gotoprompt ();
    }
}
