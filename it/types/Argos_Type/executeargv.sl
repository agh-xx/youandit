define main (self, argv)
{
  variable
    routine = 1,
    i,
    bufa = self.buffers[0],
    bufb = self.buffers[1],
    ar,
    arb,
    msg,
    retval;

  ifnot ("closeshell" == argv[0])
    self.cur.command = argv[0];

  try
    {
    switch (argv[0])
 
      {
      case "test":
        variable verbose = 0;
        retval = proc->call(["argos", "--nocl", "--func=extract",
          sprintf ("--file=%s", bufa.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", self.libdir),
          sprintf ("--mainfname=%s", bufa.fname),
          sprintf ("--msgfname=%s", self.msgbuf),
          verbose]);
        srv->send_msg_and_refresh (sprintf ("retval = %d", retval), 1);
      }

      {
      case "initpackages":
        self.tmpsyspacks ();
        throw Break;
      }

      {
      case "toogleverbose":
        ifnot (self.debug)
          {
          self.debug = 1;
          srv->send_msg_and_refresh ("debug = 1", 0);
          }
        else
          {
          self.debug = 0;
          srv->send_msg_and_refresh ("debug = 0", 0);
          }

        throw Break;
      }

      {
      case "parsebook":
        self.parsebook ();
 
        if (self.debug)
          {
          variable k, v;
          bufb.ar = ["    ENTITIES", repeat ("_", COLUMNS)];
 
          foreach k, v (self.entities) using ("keys", "values")
            bufb.ar = [bufb.ar, sprintf ("%s: %s", k, v)];
 
          bufb.ar = bufb.ar[array_sort (bufb.ar)];
 
          bufb.ar = [bufb.ar, "", "    INFO", repeat ("_", COLUMNS)];

          foreach k, v (self.info) using ("keys", "values")
            bufb.ar = [bufb.ar, sprintf ("%s: %s", k, v)];
 
          variable keys = assoc_get_keys (self.patches);
          keys = keys[array_sort (keys)];
 
          bufb.ar = [bufb.ar, "", "    PATCHES", repeat ("_", COLUMNS)];

          _for i (0, length (keys) - 1)
            bufb.ar = [bufb.ar, "ent: " + self.patches[keys[i]][3],
            "url : " + self.patches[keys[i]][0],
            "md5 : " + self.patches[keys[i]][1],
            "size: " + self.patches[keys[i]][2],
            "name: " + keys[i],  ""];

          bufb.ar = [bufb.ar, "", "    CHAPTER05", repeat ("_", COLUMNS),
            self.chapter05, "",
          "    CHAPTER06", repeat ("_", COLUMNS), self.chapter06];

          writefile (bufb.ar, bufb.fname);
          self.drawframe (1);
          }
        throw Break;
      }

      {
      case "closeshell":
        self.framedelete (2;dont_goto_prompt);
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
