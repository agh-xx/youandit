public variable
  cw_,
  rl_,
  rlf_,
  count = 0,
  IMG,
  clinef = Assoc_Type[Ref_Type],
  clinec,
  pagerf = Assoc_Type[Ref_Type],
  pagerc;

typedef struct
  {
  _i,
  _ii,
  _len,
  _chr,
  _type,
  _fname,
  _flags,
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
  lines,
  st_,
  } Frame_Type;

typedef struct
  {
  _type,
  ved,
  draw,
  getlines,
  parsearray,
  } Ftype_Type;

typedef struct
  {
  _row,
  _col,
  _chr,
  _lin,
  _ind,
  lnrs,
  argv,
  cmp_lnrs,
  com,
  } Rline_Type;

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
