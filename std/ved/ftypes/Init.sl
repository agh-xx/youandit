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
  _linlen,
  _avlins,
  _findex,
  _index,
  _undolevel,
  undo,
  undoset,
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
  _shiftwidth,
  ved,
  draw,
  quit,
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
  com,
  cmp_lnrs,
  } Rline_Type;

variable
  cf_,
  rl_,
  rlf_,
  count = 0,
  IMG,
  REG = Assoc_Type[String_Type],
  clinef = Assoc_Type[Ref_Type],
  clinec,
  pagerf = Assoc_Type[Ref_Type],
  pagerc,
  is_wrapped_line = 0;

private define quit (t)
{
  () = evalfile (sprintf ("%s/share/%s", path_dirname (__FILE__), _function_name ()), t);

  return __get_reference (sprintf ("%s->%s", t, _function_name ()));
}

private define ved (t)
{
  () = evalfile (sprintf ("%s/%s/%s", path_dirname (__FILE__), t, _function_name ()), t);

  return __get_reference (sprintf ("%s->%s", t, _function_name ()));
}

private define draw (t)
{
  () = evalfile (sprintf ("%s/%s/%s", path_dirname (__FILE__), t, _function_name ()), t);

  return __get_reference (sprintf ("%s->%s", t, _function_name ()));
}

define init_ftype (ftype)
{
  % TO DO the checks
  variable type = @Ftype_Type;
 
  type._type = ftype;
  type._shiftwidth = 4;
  type.ved = ved (ftype);
  type.draw = draw (ftype);
  type.quit = quit (ftype);

  return type;
}
