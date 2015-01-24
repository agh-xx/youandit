define f_print_norm (str)
{
  () = fprintf (STDOUTFP, "%s\n", strtrim_end (str));
}

define f_print_err (str)
{
  () = fprintf (STDERRFP, "%s\n", strtrim_end (str));
}

define f_print_warn (str)
{
  () = fprintf (STDERRFP, "%s\n", strtrim_end (str));
}

define f_highlight (color, row, col, dr, dc)
{
  srv->set_color_in_region (color, row, col, dr, dc);
}

highlight = &f_highlight;
print_norm = &f_print_norm;
print_warn = &f_print_warn;
print_err = &f_print_err;
