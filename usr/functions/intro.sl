define main ()
{
  variable retval = proc->edVi (sprintf ("%s/about_me/me.abt", DATASHAREDIR));
  CW.drawwind ();
  throw GotoPrompt;
}
