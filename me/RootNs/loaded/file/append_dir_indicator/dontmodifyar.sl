define append_dir_indicator (base, files)
{
  variable ar = @files;
  ar[where (array_map (Char_Type, &isdirectory,
    array_map (String_Type, &path_concat, base, files)))] += "/";

  return ar;
}
