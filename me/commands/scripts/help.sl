import ("pcre");
() = evalfile ("strtoint");

variable
  intrinsic = NULL,
  myself = 0,
  functionkeys = 0,
  intrinsicdocfile = sprintf ("%s/slangfun.txt", _slang_doc_dir),
  buildintrinsiccache = 0,
  cacheintrinsicfile = sprintf ("%s/../data/help/intrinsic_cache.txt", path_dirname (__FILE__));

define myselffunc ()
{
  variable ar = [
    "NOT MUCH YET",
    "MYHELP"
    ];
  array_map (Void_Type, print_norm, ["INNER HELP", ar]);
}

define functionkeysfunc ()
{
  variable ar = [
    "NOT MUCH YET",
    "F1 : Main window functions",
    "F2 : Create new window applications, e.g., git, mplayer",
    "F5 : Change language, from english to Greek and vice versa",
    "F9 : Show battery status",
    "F11: Compile distribution",
    "F12: User specific functions"];

  array_map (Void_Type, print_norm, ["FUNCTION KEYS",ar]);
}

define buildcacheintrinsicfunc ()
{
  variable
    i,
    fp,
    ar = _apropos ("Global", "", 1);

  ar = ar[array_sort (ar)];
  fp = fopen (cacheintrinsicfile, "w");

  _for i (0,length (ar) - 1)
    ifnot (NULL == get_doc_string_from_file (intrinsicdocfile, ar[i]))
      () = fprintf (fp, "%s\n", ar[i]);

  ()=fclose (fp);
}

define intrinsicfunc ()
{
  variable
    i,
    pat,
    retval,
    ar,
    topic = String_Type[0];

  if (-1 == access (intrinsicdocfile, F_OK))
    {
    (@print_err) (sprintf ("%s: hasn't been found in the standard location",
         intrinsicdocfile);print_in_msg_line);
     return 1;
    }

    if (-1 == access (cacheintrinsicfile, F_OK))
      buildcacheintrinsicfunc ();
 
    pat = pcre_compile (intrinsic, 0);

    ar = readfile (cacheintrinsicfile);

    _for i (0, length (ar) - 1)
      if (pcre_exec (pat, ar[i], 0))
        topic = [topic, ar[i]];
 
    ifnot (length (topic))
      {
      (@print_warn) (sprintf ("Intrinsic help, No topic found that match: %s", intrinsic);print_in_msg_line);
      return 1;
      }

    if (1 == length (topic))
      {
      ar = strchop (get_doc_string_from_file (intrinsicdocfile, topic[0]), '\n', 0);
      array_map (Void_Type, print_norm, ["INTRINSIC HELP", ar]);
      return 0;
      }

    retval = (@ask) ([
      sprintf ("There %d topics that match", length (topic)),
      " ",
      array_map (String_Type, &sprintf, "%d: %s", [1:length (topic)], topic),
      "escape, quit question and abort the operation"
      ], NULL;get_ascii_input);

    if (NULL == retval || 0 == strlen (retval))
      {
      (@print_err) ("Intrinsic help, Aborting ..."; print_in_msg_line);
      return 1;
      }

    retval = strtoint (retval);
    if (NULL == retval)
      {
      (@print_err) ("Intrinsic help, Selection is not an integer, Aborting ..."; print_in_msg_line);
      return 1;
      }

    retval --;

    topic = topic[retval];

    ar = strchop (get_doc_string_from_file (intrinsicdocfile, topic), '\n', 0);
    array_map (Void_Type, print_norm, ["INTRINSIC HELP", ar]);
    return 0;
}

define pcresyntax ()
{
  array_map (Void_Type, print_norm,
    readfile(sprintf ("%s/../data/help/pcresyntax.txt", path_dirname (__FILE__))));
  exit_me ();
}

define main ()
{
  variable
    i,
    retval,
    c = cmdopt_new (&_usage);

  c.add ("myself", &myself);
  c.add ("functionkeys", &functionkeys);
  c.add ("intrinsic", &intrinsic;type="string");
  c.add ("buildintrinsiccache", &buildintrinsiccache);
  c.add ("pcresyntax", &pcresyntax);
  c.add ("help", &_usage);
  c.add ("info", &info);
 
  i = c.process (__argv, 1);
 
  if (buildintrinsiccache)
    {
    buildcacheintrinsicfunc (cacheintrinsicfile, intrinsicdocfile);
    if (NULL == intrinsic || 0 == myself || 0 == functionkeys )
      {
      (@print_warn) ("No help option was given, aborting ...";print_in_msg_line);
      return 1;
      }
    }
 
  if (functionkeys)
    {
    functionkeysfunc ();
    if (NULL != intrinsic || myself)
      (@print_norm) (repeat ("-", COLUMNS));
    else
      return 0;
    }

  ifnot (NULL == intrinsic)
    {
    retval = intrinsicfunc ();
    if (retval)
      if (0 == myself == functionkeys)
        return 1;

    if (myself)
      (@print_norm) (repeat ("-", COLUMNS));
    else
      return 0;
    }
 
  if (myself)
    {
    myselffunc ();
    return 0;
    }

  (@print_err) ("No help option was given, aborting ...";print_in_msg_line);
  return 1;
}
