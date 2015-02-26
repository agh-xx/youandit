variable FTYPES = Assoc_Type[Struct_Type];

private define init (self)
{
  () = evalfile (sprintf ("%s/%s/%s", path_dirname (__FILE__),
    self._type, _function_name), self._type);

  return (@__get_reference (sprintf ("%s->%s", self._type, _function_name)))
    (self;;__qualifiers ());
}

private define edVi (self)
{
  () = evalfile (sprintf ("%s/%s/%s", path_dirname (__FILE__),
    self._type, _function_name), self._type);

  return (@__get_reference (sprintf ("%s->%s", self._type, _function_name)))
    (self;;__qualifiers ());
}

variable Ftype_Type = struct
  {
  _type,
  _fname,
  _fnfp,
  _jsfn,
  _jsfp,
  _gown,
  _uown,
  _access,
  _maxlen,
  _indent = 0,
  _states = 0,
  _state = 0,
  _flags = 0,
  err = {},
  jslinlen = {},
  ptr = Integer_Type[2],
  st_,
  p_ = struct
    {
    lnrs,
    lins,
    cols,
    clrs,
    },
  parseline,
  parsearray,
  parsefile,
  getgrgid,
  getpwuid,
  decode,
  encode,
  getjs,
  edVi = &edVi,
  init = &init,
  };

private define add (ftype)
{
  % TO DO the checks
  variable type = @Ftype_Type;
  type._type = ftype;
  return type;
}

FTYPES["txt"] = add ("txt");
FTYPES["abt"] = add ("abt");
