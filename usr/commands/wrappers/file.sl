define main ()
{
  variable
    file,
    index,
    argv,
    gotopager = 0,
    file_exec = which ("file"),
    args = __pop_list (_NARGS - 1);

  if (NULL == file_exec)
    {
    srv->send_msg ("file executable couldn't be found in PATH", -1);
    throw GotoPrompt;
    }

  ifnot (length (args))
    {
    srv->send_msg ("A filename is required", -1);
    throw GotoPrompt;
    }

  args = list_to_array (args);

  index = proc->is_arg ("--pager", args);
  ifnot (NULL == index)
    {
    gotopager = 1;
    args[index] = NULL;
    args = args[wherenot (_isnull (args))];
    }

  argv = [file_exec, args];

  variable p = @i->init_proc (0, 1, 1, argv);

  p.stdout.file = SCRATCHBUF;
  p.stdout.wr_flags = ">|";

  p.stderr.file = CW.msgbuf;
  p.stderr.wr_flags = ">>";

  if (-1 == i->sysproc (p))
    throw GotoPrompt;

  file = p.status.exit_status ? CW.msgbuf : SCRATCHBUF;

  ifnot (gotopager)
    (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, send_break});
  else
    (@CW.gotopager) (CW;;struct {@__qualifiers (), iamreal, file = file, send_break_at_exit});

  throw GotoPrompt;
}
