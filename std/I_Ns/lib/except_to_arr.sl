define exception_to_array ()
{
  return strchop (sprintf ("Caught an exception:%s\n\
  Message:     %s\n\
  Object:      %S\n\
  Function:    %s\n\
  Line:        %d\n\
  File:        %s\n\
  Description: %s\n\
  Error:       %d\n",
    _push_struct_field_values (__get_exception_info ())), '\n', 0);
}
