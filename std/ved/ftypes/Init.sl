public variable
  cw_;

typedef struct
  {
  _i,
  _ii,
  _len,
  _chr,
  _type,
  _fname,
  _maxlen,
  _indent,
  _avlins,
  ptr,
  rows,
  cols,
  clrs,
  lins,
  lnrs,
  vlins,
  state,
  lines,
  } Frame_Type;

typedef struct
  {
  _type,
  ved,
  draw,
  getlines,
  parsearray,
  } Ftype_Type;

private define getlines (s)
{
  variable indent = repeat (" ", cw_._indent);

  return array_map (String_Type, &sprintf, "%s%s", indent, readfile (cw_._fname));
}

private define ved (t)
{
  () = evalfile (sprintf ("%s/%s", path_dirname (__FILE__), _function_name ()), t);

  return __get_reference (sprintf ("%s->%s", t, _function_name ()));
}

private define draw (t)
{
  () = evalfile (sprintf ("%s/%s/%s", path_dirname (__FILE__), t, _function_name ()), t);

  return __get_reference (sprintf ("%s->%s", t, _function_name ()));
}

define init (ftype)
{
  % TO DO the checks
  variable type = @Ftype_Type;
  
  type._type = ftype;
  type.getlines = &getlines;
  type.ved = ved (ftype);
  type.draw = draw (ftype);
  return type;
}
