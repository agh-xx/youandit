ineed ("sync");

define main ()
{
  if (-1 == access (__argv[1], W_OK))
    {
    (@print_err) (sprintf ("%s: Is not writable", __argv[1]);dont_write_to_stdout);
    return 1;
    }

  variable
    exit_code,
    cur = sprintf ("%s/../sources", ROOTDIR),
    tree = path_concat (__argv[1], strftime ("%H:%M_%d_%m_%Y")),
    sync = sync_new ();
  
  if (are_same_files (cur, tree))
    {
    (@print_err) ("you are trying to backup on me, doesn't make sense";dont_write_to_stdout);
    return 1;
    }
 
  if (-1 == mkdir (tree))
    {
    (@print_err) ("This shouldn't be happen";dont_write_to_stdout);
    (@print_err) (sprintf ("%s: ERRNO: %s", tree, errno_string (errno));dont_write_to_stdout);
    return 1;
    }

  tree += "/sources";

  () = mkdir (tree);
  
  exit_code = sync.run (cur, tree);

  ifnot (exit_code)
    {
    () = chdir (tree + "/..");
    () = symlink ("sources/me/I_Ns/you.sl", "you.sl");
    }

  ifnot (exit_code)
    (@print_norm) ("backup completed without any error");
  else
    (@print_err) (sprintf ("backup failed, EXIT_CODE: ", exit_code);dont_write_to_stdout);

  (@print_norm) (repeat ("_", COLUMNS));

  return exit_code;
}
