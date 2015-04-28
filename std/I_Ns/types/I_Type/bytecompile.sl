define main (self, fname, gotopager)
{
  variable
    argv = [SLSH_EXEC, sprintf ("%s/proc/bytecompile.slc", path_dirname (__FILE__))],
    env = [
    sprintf ("COLUMNS=%d", COLUMNS),
    sprintf ("PROMPTROW=%d", PROMPTROW),
    sprintf ("SRV_SOCKADDR=%s", SRV_SOCKADDR),
    sprintf ("SRV_FILENO=%d", _fileno (SRV_SOCKET)),
    sprintf ("LOAD_PATH=%s", get_slang_load_path ()),
    sprintf ("TERM=%s", getenv ("TERM")),
    sprintf ("IMPORT_PATH=%s", get_import_module_path ()),
    sprintf ("STDNS=%s", STDNS),
    sprintf ("PERSNS=%s", PERSNS),
    sprintf ("BINDIR=%s", BINDIR),
    sprintf ("SOURCEDIR=%s", SOURCEDIR)],
    p = proc->init (0, 1, 1);

  p.stdout.file = fname;
  p.stdout.wr_flags = ">>";

  p.stderr.file = fname;
  p.stderr.wr_flags = ">>";
  
  variable status = p.execve (argv, env, NULL);

  if (NULL == status)
    {
    status.exit_status = 1;
    writefile ("failed to create process", fname;mode = "a");
    }

  @gotopager = status.exit_status;
}
