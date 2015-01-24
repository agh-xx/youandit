private define call ()
{
  variable
    argv = _NARGS > 2 ? __pop_list (_NARGS - 2) : {},
    func = (),
    self = (),
    file = self.keys[func][0],
    qualifiers = struct {@self.keys[func][1], @__qualifiers};

  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), file),
     __push_list (argv);;qualifiers);
}

define main (self)
{
  variable
    i,
    ed,
    keys = Assoc_Type[];

  keys["reboot"] = {"reboot", NULL, "Reboot the Machine but ask first"};
  keys["halt"] = {"halt", NULL, "Halt the Machine but ask first"};
  keys["q"] = {"quit", NULL, "Quit Program"};
  keys["q!"] = {"quit", struct {force}, "Quit Program without asking"};
  keys["testkey"] = {"testkey", NULL, "Test Keys"};
  keys["change_getch"] = {"change_getch", NULL, "Change Language (from eng to greek and vice versa)"};
  keys["pwd"] = {"pwd", NULL, "See the current directory"};
  keys["cd"] = {"cd", NULL, "Change directory, args = [dir]"};
  keys["windowdelete"] = {"windowdelete", NULL, "Delete Window, args = existing window name"};
  keys["windownext"] = {"windownext", NULL, "Go to the next Window"};
  keys["windowprev"] = {"windowprev", NULL, "Go to the previus Window"};
  keys["windownew"] = {"windownew", NULL, "Create a new Window, args = Type, name"};
  keys["windownewdontfocus"] = {"windownewdontfocus", NULL, "Create a new Window but dont take focus, args = Type, name"};
  keys["windowgoto"] = {"windowgoto", NULL, "Go to Window, args = existing window name"};
  keys["framedelete"] = {"framedelete", NULL, "Delete frame numbered from zero, args = frame number"};
  keys["framenew"] = {"framenew", NULL, "Add a new frame"};
  keys["framenext"] = {"framenext", NULL, "Go to the next frame"};
  keys["frameprev"] = {"frameprev", NULL, "Go to the prev frame"};
  keys["write"] = {"write", NULL, "Write buffer to a filename, args = filename"};
  keys["append"] = {"append", NULL, "Append buffer to a filename, args = filename"};
  keys["messages"] = {"messages", NULL, "Show Error messages if any"};
  keys["rehash"] = {"rehash", NULL, "Rebuilt the hash table"};
  keys["sh"] = {"shell", NULL, "Open a shell (default zsh), args = shell name"};
  keys["slsh"] = {"slsh", NULL, "Open a slang shell (slsh)"};
  keys["clear"] = {"clear", NULL, "Clear the screen"};
  keys["clearmsgs"] = {"clear", struct {"messages"}, "Clear the messages"};
  keys["bglist"] = {"bglist", NULL, "List background jobs"};
  keys["bgkillpid"] = {"bgkillpid", NULL, "kill background job arg = pid"};
  keys["writeunamed"] = {"writeunamed", NULL, "write unamed buffer to the screen"};

 EDITOR = which (EDITOR);
 ifnot (NULL == EDITOR)
   keys["edthisfile"] = {"edthisfile", NULL, "Edit buffer with " + path_basename (EDITOR)};

  if (NULL != listdir ("/proc/acpi/battery/") ||
      NULL != listdir ("/sys/class/power_supply"))
    keys["battery"] = {"battery", NULL, "Show Battery Status"};

  throw Return, " ", struct
    {
    exec = self.exec,
    call = &call,
    keys = keys,
    };
}
