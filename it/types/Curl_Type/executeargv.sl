define main (self, argv)
{
  variable
    i,
    type,
    frame,
    retval,
    urls,
    bufa = self.buffers[0];
 
  variable fp = fopen (self.lockfile, "w");
  () = fclose (fp);

  try
    {
    if ("addurl" == argv[0])
      {
      if (1 == length (argv))
        {
        srv->send_msg ("it needs an url", -1);
        throw Break;
        }
 
      urls = argv[[1:]];

      _for i (0, length (urls) - 1)
        {
        self.urls[urls[i]] = @self.Info_Type;
        }

      retval = proc->call (["curl_proc", "--nocl", "--bg",
        sprintf ("--lockfile=%s", self.lockfile),
        sprintf ("--row=%d", 1),
        sprintf ("--execdir=%s", path_dirname (__FILE__)),
        sprintf ("--msgfname=%s", CW.msgbuf),
        sprintf ("--mainfname=%s", bufa.fname),
        urls]);

        throw Break;
        }

    if ("filelist" == argv[0])
      {
      if (1 == length (argv))
        {
        srv->send_msg ("it needs a file name", -1);
        throw Break;
        }
 
      if (-1 == access (argv[1], F_OK|R_OK))
        {
        srv->send_msg (sprintf ("%s: doesn't exists or it can not be read", argv[1]), -1);
        throw Break;
        }
 
      urls = readfile (argv[0]);

      _for i (0, length (urls) - 1)
        self.urls[urls[i]] = @self.Info_Type;

      retval = proc->call (["curl_proc", "--nocl", "--bg",
        sprintf ("--lockfile=%s", self.lockfile),
        sprintf ("--row=%d", 1),
        sprintf ("--execdir=%s", path_dirname (__FILE__)),
        sprintf ("--msgfname=%s", CW.msgbuf),
        sprintf ("--mainfname=%s", bufa.fname),
        urls]);
      throw Break;
      }
    }
  catch Break: {}
  catch AnyError:
    root.lib.printtostdout (exception_to_array);
  finally:
  {
  () = remove (self.lockfile);
  self.gotoprompt ();
  }
}
