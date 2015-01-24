private define go_start_of_line (self, row, col, buf, frame, frame_size, len)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    row, col, buf, frame, frame_size, len;;__qualifiers ());
}

private define go_end_of_file (self, row, col, buf, frame, frame_size, len)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    row, col, buf, frame, frame_size, len;;__qualifiers ());
}

private define go_end_of_line (self, row, col, buf, frame, frame_size, len)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    row, col, buf, frame, frame_size, len;;__qualifiers ());
}

private define go_right (self, row, col, buf, frame, frame_size, len)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    row, col, buf, frame, frame_size, len;;__qualifiers ());
}

private define go_left (self, row, col, buf, frame, frame_size, len)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    row, col, buf, frame, frame_size, len;;__qualifiers ());
}

private define go_start_of_file (self, row, col, buf, frame, frame_size, len)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    row, col, buf, frame, frame_size, len;;__qualifiers ());
}

private define go_end_of_wrapped_line (self, row, col, buf, frame, frame_size, len)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    row, col, buf, frame, frame_size, len;;__qualifiers ());
}

private define go_up (self, row, col, buf, frame, frame_size, len)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    row, col, buf, frame, frame_size, len;;__qualifiers ());
}

private define go_to_line (self, row, col, buf, frame, frame_size, len)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    row, col, buf, frame, frame_size, len;;__qualifiers ());
}

private define go_down (self, row, col, buf, frame, frame_size, len)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    row, col, buf, frame, frame_size, len;;__qualifiers ());
}

private define go_to_percentage (self, row, col, buf, frame, frame_size, len)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    row, col, buf, frame, frame_size, len;;__qualifiers ());
}

private define go_start_of_wrapped_line (self, row, col, buf, frame, frame_size, len)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    row, col, buf, frame, frame_size, len;;__qualifiers ());
}

private define go_one_page_down (self, row, col, buf, frame, frame_size, len)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    row, col, buf, frame, frame_size, len;;__qualifiers ());
}

private define go_one_page_up (self, row, col, buf, frame, frame_size, len)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    row, col, buf, frame, frame_size, len;;__qualifiers ());
}

private define routine (self, buf, frame, len)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ()),
    buf, frame, len
      ;;__qualifiers ());
}

private define pager (self)
{
  self.exec (sprintf ("%s/funcs/%s", path_dirname (__FILE__), _function_name ())
    ;;__qualifiers ());
}

define main (self)
{
  variable assoc = Assoc_Type[Ref_Type];

  array_map (Void_Type, &assoc_add_key, assoc,
  ["pager", "routine", "g", "^", "$", "G", "l", "h", "k", "-", "j", "go_to_line", "0", "%",
   "go_right", "go_left", "go_up", "go_down", "pgdown", "pgup", " ", "HOME", "END"
   ],
  [&pager, &routine, &go_start_of_file, &go_start_of_line, &go_end_of_line,
   &go_end_of_file, &go_right, &go_left, &go_up, &go_end_of_wrapped_line,
   &go_down, &go_to_line, &go_start_of_wrapped_line, &go_to_percentage,
   &go_right, &go_left, &go_up, &go_down,
   &go_one_page_down, &go_one_page_up, &go_one_page_down,
   &go_start_of_file, &go_end_of_file]);

  throw Return, " ", assoc;
}
