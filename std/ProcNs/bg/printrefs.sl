define f_print_out (str)
{
  () = fprintf (STDOUTFP, "%s\n", strtrim_end (str));
}

define f_print_err (str)
{
  () = fprintf (STDERRFP, "%s\n", strtrim_end (str));
}

define f_highlight (color, row, col, dr, dc)
{
  srv->set_color_in_region (color, row, col, dr, dc);
}

highlight = &f_highlight;
print_out = &f_print_out;
print_err = &f_print_err;
