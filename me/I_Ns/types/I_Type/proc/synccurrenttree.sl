ineed ("sync");

define main ()
{
  variable
    exit_code,
    cur = sprintf ("%s/../sources", ROOTDIR),
    tree = path_concat (__argv[1], "sources"),
    sync = sync_new ();
  
  if (are_same_files (cur, tree))
    {
    (@print_err) ("you are trying to sync with me";dont_write_to_stdout);
    return 1;
    }

  tree = strtrim_end (tree, "/");

  exit_code = sync.run (tree, cur);

  ifnot (exit_code)
    (@print_norm) ("sync completed without any error");
  else
    (@print_err) (sprintf ("sync failed, EXIT_CODE: ", exit_code);dont_write_to_stdout);
  
  (@print_norm) (repeat ("_", COLUMNS));
  return exit_code;
}
