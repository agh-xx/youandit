define main (self, argv)
{
  variable
    i,
    ia,
    ar,
    arb,
    msg,
    len,
    retval,
    tracker,
    routine = 1,
    buf = self.buffers[0];

  ifnot (any (["trackset", "closeshell", "inittracker", "rmtrackfromdb"]
     == argv[0]))
    if (NULL == self.cur.tracker)
      {
      srv->send_msg ("Use the 'trackset' command to set a tracker first", -1);
      self.gotoprompt ();
      }

  ifnot ("closeshell" == argv[0])
    self.cur.command = argv[0];

  try
    {
    switch (argv[0])
 
      {
      case "inittracker":
        if (1 == length (argv))
          {
          srv->send_msg ("it needs a tracker name", -1);
          throw Break;
         }
        
        ifnot (NULL == self.trackers)
          if (any (argv[1] == self.trackers))
            {
            srv->send_msg (sprintf ("%s: already exists in the db", argv[1]), -1);
            throw Break;
            }

        tracker = sprintf ("%s/%s", self.datadir, argv[1]);

        if (-1 == access (tracker, F_OK))
          {
          if (-1 == mkdir (tracker))
            {
            srv->send_msg (sprintf ("%s: cannot create dir ERRNO: %s", tracker, errno_string (errno)), -1);
            throw Break;
            }

          if (-1 == mkdir (strreplace (tracker, ROOTDIR, SOURCEDIR)))
            {
            srv->send_msg (sprintf ("%s: cannot create dir ERRNO: %s", tracker, errno_string (errno)), -1);
            throw Break;
            }
          }
      
      if (NULL == self.trackers)
        self.trackers = [argv[1]];
      else
        self.trackers = [self.trackers, argv[1]];

      writefile (argv[1], self.trackersfile;mode = "a");
      writefile (argv[1], strreplace (self.trackersfile, ROOTDIR, SOURCEDIR); mode = "a+");
      writefile (self.trackers, buf.fname;mode = "a");
      }

      {
      case "closeshell":
        self.framedelete (1;dont_goto_prompt);
        self.cur.frame = 0;
        self.dim[0].infolinecolor = COLOR.activeframe;
        self.writeinfolines ();
        throw Break;
      }

    }
  catch Break:
    routine = NULL;
  catch AnyError:
    root.lib.printtostdout (exception_to_array);
  finally:
    {
    ifnot (NULL == routine)
      {
      self.drawframe (0;reread_buf);
      self.setinfoline (NULL, 0, NULL);
      self.writeinfolines ();
      }

    self.gotoprompt ();
    }
}
