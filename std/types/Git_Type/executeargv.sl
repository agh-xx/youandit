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
    routine = 1,
    buf = self.buffers[0];

  ifnot (any (["reposet", "closeshell", "initrepo", "rmrepofromdb", "repoadd"]
        == argv[0]))
    if (NULL == self.cur.repo)
      {
      srv->send_msg ("Use the 'reposet' command to set a repository first", -1);
      self.gotoprompt ();
      }

  ifnot ("closeshell" == argv[0])
    self.cur.command = argv[0];

  try
    {
    switch (argv[0])
 
      {
      case "bisectinit":

        if (NULL == self.cur.nrbrances || 0 == self.cur.nrbrances)
          {
          srv->send_msg ("No branches yet", -1);
          throw Break;
          }

        if (1 == length (argv))
          {
          srv->send_msg ("it needs a full revision hash", -1);
          throw Break;
          }

        retval = proc->call (["git_proc", "--nocl", "--func=bisect_init",
          sprintf ("--revision=%s", argv[1]),
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--branch=%s", self.cur.branch),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);
      }

      {
      case "bisectgood":

        if (NULL == self.cur.nrbrances || 0 == self.cur.nrbrances)
          {
          srv->send_msg ("No branches yet", -1);
          throw Break;
          }

        retval = proc->call (["git_proc", "--nocl", "--func=bisect_good",
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--branch=%s", self.cur.branch),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);
      }

      {
      case "bisectbad":

        if (NULL == self.cur.nrbrances || 0 == self.cur.nrbrances)
          {
          srv->send_msg ("No branches yet", -1);
          throw Break;
          }

        retval = proc->call (["git_proc", "--nocl", "--func=bisect_bad",
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--branch=%s", self.cur.branch),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);
      }

      {
      case "bisectreset":

        if (NULL == self.cur.nrbrances || 0 == self.cur.nrbrances)
          {
          srv->send_msg ("No branches yet", -1);
          throw Break;
          }

        retval = proc->call (["git_proc", "--nocl", "--func=bisect_reset",
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--branch=%s", self.cur.branch),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);
      }

      {
      case "diffrevision":

        if (NULL == self.cur.nrbrances || 0 == self.cur.nrbrances)
          {
          srv->send_msg ("No branches yet", -1);
          throw Break;
          }

        if (1 == length (argv))
          {
          srv->send_msg ("it needs a revision", -1);
          throw Break;
          }

        retval = proc->call (["git_proc", "--nocl", "--func=showdiffrevision",
          sprintf ("--revision=%s", argv[1]),
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--branch=%s", self.cur.branch),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);
      }

      {
      case "applypatch":

        if (NULL == self.cur.nrbrances || 0 == self.cur.nrbrances)
          {
          srv->send_msg ("No branches yet", -1);
          throw Break;
          }

        if (1 == length (argv))
          {
          srv->send_msg ("it needs a patch filename", -1);
          throw Break;
          }

        if (-1 == access (argv[1], F_OK|W_OK))
          {
          srv->send_msg (sprintf ("%s: ERRNO: %s", argv[1], errno_string (errno)), -1);
          throw Break;
          }

        if (isdirectory (argv[1]))
          {
          srv->send_msg (sprintf ("%s: Is a directory", argv[1]), -1);
          throw Break;
          }

        retval = proc->call (["git_proc", "--nocl", "--func=applypatch",
          sprintf ("--patch=%s", argv[1]),
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);
      }

      {
      case "branches":

        if (NULL == self.cur.nrbrances || 0 == self.cur.nrbrances)
          {
          srv->send_msg ("No branches yet", -1);
          throw Break;
          }

        retval = proc->call (["git_proc", "--nocl", "--func=branch", "--mode=none",
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);
      }

      {
      case "rmrepofromdb":

        if (NULL == self.repos)
          {
          srv->send_msg ("repositories db is empty", -1);
          throw Break;
          }

        if (1 == length (argv))
          {
          srv->send_msg ("it needs a repo name", -1);
          throw Break;
          }
 
        ar = NULL == self.repos ? readfile (self.reposfile) : self.repos;
 
        i = wherefirst (array_map (Char_Type, &are_same_files, argv[1], ar));
 
        if (NULL == i)
          {
          srv->send_msg (sprintf ("%s: No such repo in the db", argv[1]), -1);
          throw Break;
          }

        ar[i] = NULL;
        ar = ar[wherenot (_isnull (ar))];
        ar = ar[where (strlen (ar))];
        writefile (ar, self.reposfile);
        writefile (ar, strreplace (self.reposfile, BINDIR, SOURCEDIR));
        writefile (["Available Repositories", repeat ("_", COLUMNS),
              ar], buf.fname);
        srv->send_msg (sprintf ("%s: Removed from db", argv[1]), 0);
        routine = 0;
        self.repos = ar;
      }

      {
      case "initrepo":
        if (1 == length (argv))
          {
          srv->send_msg ("it needs a directory name", -1);
          throw Break;
          }

        if (-1 == access (argv[1], F_OK|W_OK))
          {
          srv->send_msg (sprintf ("%s: ERRNO: %s", argv[1], errno_string (errno)), -1);
          throw Break;
          }

        ifnot (isdirectory (argv[1]))
          {
          srv->send_msg (sprintf ("%s: Is not a directory", argv[1]), -1);
          throw Break;
          }

        ifnot (path_is_absolute (argv[1]))
          {
          srv->send_msg (sprintf ("%s: Is not a absolute path", argv[1]), -1);
          throw Break;
          }

        ifnot (NULL == self.repos)
          if (any (array_map (Char_Type, &are_same_files, argv[1], self.repos)))
            {
            srv->send_msg (sprintf ("%s: Is already in the database", argv[1]), -1);
            throw Break;
            }

        retval = proc->call (["git_proc", "--nocl", "--func=init",
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", argv[1]),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);

        ifnot (retval)
          {
          ar = [argv[1], readfile (self.reposfile)];
          ar = ar[where (strlen (ar))];
          writefile (ar, self.reposfile);
          writefile (ar, strreplace (self.reposfile, BINDIR, SOURCEDIR));
          writefile (ar, buf.fname;mode = "a");
          }
        else
          {
          self.drawframe (0;reread_buf);
          self.setinfoline (NULL, 0, NULL);
          self.writeinfolines ();
          throw Break;
          }

        self.repos = ar;

        if (NULL == self.cur.repo)
          {
          () = chdir (argv[1]);
          self.dir = argv[1];
          self.cur.repo = argv[1];
          }
      }

      {
      case "lastlog":

        if (NULL == self.cur.nrbrances || 0 == self.cur.nrbrances)
          {
          srv->send_msg ("No branches yet", -1);
          throw Break;
          }

        retval = proc->call (["git_proc", "--nocl", "--func=lastlog",
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);
      }

      {
      case "merge":

        if (NULL == self.cur.nrbrances || 0 == self.cur.nrbrances)
          {
          srv->send_msg ("No branches yet", -1);
          throw Break;
          }

        if (1 == length (argv))
          {
          srv->send_msg ("it needs a branch name", -1);
          throw Break;
          }

        ifnot (any (argv[1] == self.cur.branches))
          {
          srv->send_msg (sprintf ("%s: branch doesn't exist", argv[1]), -1);
          throw Break;
          }

        if (argv[1] == self.cur.branch)
          {
          srv->send_msg ("This is the current branch", -1);
          throw Break;
          }

        retval = proc->call (["git_proc", "--nocl", "--func=merge",
          sprintf ("--branch=%s", argv[1]),
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);
      }

      {
      case "branchdelete":

        if (NULL == self.cur.nrbrances || 0 == self.cur.nrbrances)
          {
          srv->send_msg ("No branches yet", -1);
          throw Break;
          }

        if (1 == length (argv))
          {
          srv->send_msg ("it needs a branch name", -1);
          throw Break;
          }

        ifnot (any (argv[1] == self.cur.branches))
          {
          srv->send_msg (sprintf ("%s: branch doesn't exist", argv[1]), -1);
          throw Break;
          }

        if ("master" == argv[1])
          {
          srv->send_msg ("You can't delete the \"master\" branch", -1);
          throw Break;
          }

        retval = proc->call (["git_proc", "--nocl", "--func=branchdelete",
          sprintf ("--branch=%s", argv[1]),
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);

        arb = readfile (buf.fname);

        ifnot (retval)
          {
          retval = proc->call (["git_proc", "--nocl", "--func=branch", "--mode=none",
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);

          ar = readfile (buf.fname);

          self.cur.nrbrances = atoi (strtok (ar[0])[3]);
          self.cur.branches = ar[[2:1+self.cur.nrbrances]];
          self.cur.branch = substr (ar[-1], 17, -1);

          writefile ([arb, repeat ("-", COLUMNS), ar], buf.fname);
          }
      }

      {
      case "branchnew":

        if (1 == length (argv))
          {
          srv->send_msg ("it needs a branch name", -1);
          throw Break;
          }

        if (any (argv[1] == self.cur.branches))
          {
          srv->send_msg (sprintf ("%s: branch already exists", argv[1]), -1);
          throw Break;
          }

        retval = proc->call (["git_proc", "--nocl", "--func=branchnew",
          sprintf ("--file=%s", buf.fname),
          sprintf ("--branch=%s", argv[1]),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);

        arb = readfile (buf.fname);

        ifnot (retval)
          {
          retval = proc->call (["git_proc", "--nocl", "--func=branch", "--mode=none",
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);

          ar = readfile (buf.fname);

          self.cur.nrbrances = atoi (strtok (ar[0])[3]);
          self.cur.branches = ar[[2:1+self.cur.nrbrances]];
          self.cur.branch = substr (ar[-1], 17, -1);

          writefile ([
              sprintf ("%s: added branch", argv[1]),
              repeat ("-", COLUMNS), length (arb) ? arb : " ", ar], buf.fname);
          }
        else
         if (length (arb))
            writefile (arb, buf.fname);
      }

      {
      case "branchchange":

        if (NULL == self.cur.nrbrances || 0 == self.cur.nrbrances)
          {
          srv->send_msg ("No branches yet", -1);
          throw Break;
          }

        if (1 == self.cur.nrbrances)
          {
          srv->send_msg ("There is only one branch", -1);
          throw Break;
          }

        if (1 == length (argv))
          {
          srv->send_msg ("it needs a branch name", -1);
          throw Break;
          }

        ifnot (any (argv[1] == self.cur.branches))
          {
          srv->send_msg (sprintf ("%s: branch doesn't exist", argv[1]), -1);
          throw Break;
          }

        retval = proc->call (["git_proc", "--nocl", "--func=branchchange",
          sprintf ("--file=%s", buf.fname),
          sprintf ("--branch=%s", argv[1]),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);

        ifnot (retval)
          self.cur.branch = argv[1];
      }

      {
      case "logpatch":

        if (NULL == self.cur.nrbrances || 0 == self.cur.nrbrances)
          {
          srv->send_msg ("No branches yet", -1);
          throw Break;
          }

        retval = proc->call (["git_proc", "--nocl", "--func=logpatch",
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);
      }

      {
      case "pull":
        retval = proc->call (["git_proc", "--nocl", "--func=pull",
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);
      }

      {
      case "pushupstream":
        retval = proc->call (["git_proc", "--nocl", "--func=get_upstream_url", "--mode=none",
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);
 
        if (retval)
          {
          self.drawframe (0;reread_buf);
          self.setinfoline (NULL, 0, NULL);
          self.writeinfolines ();
          throw Break;
          }

        variable url = readfile (buf.fname)[0];
        ifnot ("https" == url[[:4]])
          {
          writefile ("Is not over a https repo, I don't know if it works", buf.fname);
          self.drawframe (0;reread_buf);
          self.setinfoline (NULL, 0, NULL);
          self.writeinfolines ();
         throw Break;
         }

        srv->send_msg_and_refresh ("Please enter your username", 0);

        variable username = (@self.readline.getsingleline) (self.readline);
        ifnot (strlen (username))
          {
          srv->send_msg ("username is an empty string. Aborting ...", -1);
          throw Break;
          }

        variable passwd = root.lib.getpasswd ();

        ifnot (strlen (passwd))
          {
          srv->send_msg ("Password is an empty string. Aborting ...", -1);
          throw Break;
          }
 
        url = sprintf ("https://%s:%s@%s", username, passwd, substr (url, 9, -1));
        retval = proc->call (["git_proc", "--nocl", "--func=push_upstream",
          sprintf ("--url=%s", url),
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);

      }

      {
      case "commitall":
        srv->send_msg ("Please add your message to commit", 0);
        root.topline ();
        srv->write_prompt (" ", 1);

        msg = (@self.readline.getsingleline) (self.readline);
 
        ifnot (strlen (msg))
          {
          srv->send_msg ("aborted due to empty message", 1);
          throw Break;
          }

        retval = proc->call (["git_proc", "--nocl", "--func=commitall",
          sprintf ("--msg=%s", msg),
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);
      }

      {
      case "commit":
        srv->send_msg ("Please add your message to commit", 0);
        root.topline ();
        srv->write_prompt (" ", 1);

        msg = (@self.readline.getsingleline) (self.readline);
 
        ifnot (strlen (msg))
          {
          srv->send_msg ("aborted due to empty message", 1);
          throw Break;
          }

        retval = proc->call (["git_proc", "--nocl", "--func=commit",
          sprintf ("--msg=%s", msg),
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);
      }

      {
      case "add":
        if (1 == length (argv))
          {
          srv->send_msg ("a filename or a directory is needed", -1);
          throw Break;
          }

        if (-1 == access (argv[1], F_OK))
          {
          srv->send_msg (sprintf ("fname: %s No such a filename", argv[1]), -1);
          throw Break;
          }

        retval = proc->call (["git_proc", "--nocl", "--func=add",
          sprintf ("--newfile=%s", argv[1]),
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);
      }

      {
      case "status":

        if (NULL == self.repos)
          {
          srv->send_msg ("repositories db is empty", -1);
          throw Break;
          }

        retval = proc->call (["git_proc", "--nocl", "--func=status",
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);

        ar = readfile (buf.fname);
        ifnot (length (ar))
          writefile ("repository is clean", buf.fname);
      }

      {
      case "fulllog":

        if (NULL == self.cur.nrbrances || 0 == self.cur.nrbrances)
          {
          srv->send_msg ("No branches yet", -1);
          throw Break;
          }

        retval = proc->call (["git_proc", "--nocl", "--func=fulllog",
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);

        ar = readfile (buf.fname);
        ia = -1;
        _for i (0, length (ar) - 1)
          if (7 < strlen (ar[i]))
            if ("commit: " == ar[i][[0:7]])
              (ia++, ar[i] = sprintf ("%s  [~%d]", ar[i], ia));
 
        writefile (ar, buf.fname);
      }

      {
      case "log":

        if (NULL == self.cur.nrbrances || 0 == self.cur.nrbrances)
          {
          srv->send_msg ("No branches yet", -1);
          throw Break;
          }

        retval = proc->call (["git_proc", "--nocl", "--func=log",
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);

        ar = readfile (buf.fname);
        ia = -1;
        _for i (0, length (ar) - 1)
          if (7 < strlen (ar[i]))
            if ("commit: " == ar[i][[0:7]])
              (ia++, ar[i] = sprintf ("%s  [~%d]", ar[i], ia));
 
        ifnot (length (ar))
          writefile ("No Log Available", buf.fname);
        else
          writefile (ar, buf.fname);
      }

      {
      case "closeshell":
        self.framedelete (1;dont_goto_prompt);
        self.cur.frame = 0;
        self.dim[0].infolinecolor = COLOR.activeframe;
        self.writeinfolines ();
        throw Break;
      }

      {
      case "repoadd":
        if (1 == length (argv))
          {
          srv->send_msg ("You need to specify a directory with a git tree", -1);
          throw Break;
          }

        if (-1 == access (sprintf ("%s/.git", argv[1]), F_OK|W_OK))
          {
          srv->send_msg (sprintf ("%s: ERRNO: %s", argv[1], errno_string (errno)), -1);
          throw Break;
          }

        ifnot (isdirectory (argv[1]))
          {
          srv->send_msg (sprintf ("%s: Is not a directory", argv[1]), -1);
          throw Break;
          }

        ifnot (path_is_absolute (argv[1]))
          {
          srv->send_msg (sprintf ("%s: Is not a absolute path", argv[1]), -1);
          throw Break;
          }
 
        ifnot (NULL == self.repos)
          if (any (array_map (Char_Type, &are_same_files, argv[1], self.repos)))
            {
            srv->send_msg (sprintf ("%s: Is already in the database", argv[1]), -1);
            throw Break;
            }

        ar = [argv[1], readfile (self.reposfile)];
        ar = ar[where (strlen (ar))];
        writefile (ar, self.reposfile);
        writefile (ar, strreplace (self.reposfile, BINDIR, SOURCEDIR));
        writefile (ar, buf.fname);
        self.repos = ar;
      }

      {
      case "reposet":

        if (1 == length (argv))
          {
          srv->send_msg ("You need to specify a git tree which exists in db", -1);
          throw Break;
          }
 
        if (NULL == self.repos)
          {
          srv->send_msg ("repositories db is empty", -1);
          throw Break;
          }

        ifnot (path_is_absolute (argv[1]))
          {
          srv->send_msg (sprintf ("%s: Is not a absolute path", argv[1]), -1);
          throw Break;
          }

        if (-1 == access (sprintf ("%s/.git", argv[1]), F_OK))
          {
          srv->send_msg (sprintf ("%s: This is not a directory with a git tree",
            argv[1]), -1);
          throw Break;
          }
 
        ifnot (any (array_map (Char_Type, &are_same_files, argv[1], self.repos)))
          {
          srv->send_msg (sprintf ("%s: Doesn't exists in database", argv[1]), -1);
          throw Break;
          }

        self.cur.repo = argv[1];

        retval = proc->call (["git_proc", "--nocl", "--func=branch", "--mode=none",
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);

        () = chdir (argv[1]);
        self.dir = argv[1];

        ar = readfile (buf.fname);

        len = length (ar);
        if (0 == len || (1 == length (ar) && 0 == strlen (ar[0])))
          {
          self.cur.nrbrances = 0;
          self.cur.branches = "NONE YET";
          self.cur.branch = "NONE YET";
          }
        else
          {
          self.cur.nrbrances = atoi (strtok (ar[0])[3]);
          self.cur.branches = ar[[2:1+self.cur.nrbrances]];
          self.cur.branch = substr (ar[-1], 17, -1);
 
          writefile ([repeat ("_", COLUMNS), "STATUS"], buf.fname;mode="a");
          len += 2;

          retval = proc->call (["git_proc", "--nocl", "--func=status", "--mode=a",
            sprintf ("--file=%s", buf.fname),
            sprintf ("--repo=%s", self.cur.repo),
            sprintf ("--execdir=%s", path_dirname (__FILE__)),
            sprintf ("--mainfname=%s", buf.fname),
            sprintf ("--msgfname=%s", self.msgbuf)]);

          ar = readfile (buf.fname);

          if (len == length (ar))
            writefile ("repository is clean", buf.fname;mode="a");
          }
      }

      {
      case "diff":

        if (NULL == self.cur.nrbrances || 0 == self.cur.nrbrances)
          {
          srv->send_msg ("No branches yet", -1);
          throw Break;
          }

        retval = proc->call (["git_proc", "--nocl", "--func=diff",
          sprintf ("--file=%s", buf.fname),
          sprintf ("--repo=%s", self.cur.repo),
          sprintf ("--execdir=%s", path_dirname (__FILE__)),
          sprintf ("--mainfname=%s", buf.fname),
          sprintf ("--msgfname=%s", self.msgbuf)]);

        ar = readfile (buf.fname);
        ifnot (length (ar))
          writefile ("No Differences", buf.fname);
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
