variable
  tag = Assoc_Type[Assoc_Type];

tag["type"] = Assoc_Type[Assoc_Type];

tag["type"]["HEADER"] = Assoc_Type[Struct_Type];

tag["type"]["HEADER"] ["fmt"] = struct
  {
  h= sprintf ("%%d", 15),
  i = sprintf ("%%d", 14),
  o = sprintf ("%%d", 12),
  l = sprintf ("%%%ds", 10)
  };
%       ^
% later |
variable fmt =
  tag["type"]["HEADER"]["fmt"].l;

() = fprintf (stdout, "%s %s\n", atoi (fmt) == 15 ? "passed" : "failed", fmt);
