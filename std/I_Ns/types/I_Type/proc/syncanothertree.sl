ineed ("sync");

define main ()
{
  variable
    exit_code,
    cur = SOURCEDIR,
    tree = path_concat (__argv[1], "dist"),
    sync = sync_new ();
 
  sync.interactive_extra = 1;

  if (are_same_files (cur, tree))
    {
    (@print_err) ("you are trying to sync with me";dont_write_to_stdout);
    return 1;
    }

  tree = strtrim_end (tree, "/");
 
  exit_code = sync.run (cur, tree);

  ifnot (exit_code)
    (@print_out) ("sync completed without any error");
  else
    (@print_err) (sprintf ("sync failed, EXIT_CODE: %d", exit_code);dont_write_to_stdout);
 
  (@print_out) (repeat ("_", COLUMNS));

  return exit_code;
}