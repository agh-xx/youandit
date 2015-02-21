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
    cur = SOURCEDIR,
    disttree,
    tree = path_concat (__argv[1], strftime ("%H_%M_%d_%m_%Y")),
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

  disttree = sprintf ("%s/dist", tree);

  () = mkdir (disttree);
 
  exit_code = sync.run (cur, disttree);

  ifnot (exit_code)
    {
    () = chdir (tree);
    () = symlink ("dist/you.sl", "you.sl");
    }

  ifnot (exit_code)
    (@print_out) (sprintf ("%s: backup completed without any error", cur));
  else
    (@print_err) (sprintf ("backup failed, EXIT_CODE: ", exit_code);dont_write_to_stdout);

  (@print_out) (repeat ("_", COLUMNS));

  return exit_code;
}
