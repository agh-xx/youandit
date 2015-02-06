private define pager ()
{
  CW.exec (sprintf ("%s/%s", FTYPES["abt"].dir, _function_name ())
    ;;__qualifiers ());
}

FTYPES["abt"] = @Ftype_Type;

FTYPES["abt"].dir = sprintf ("%s/types/abt", path_dirname (__FILE__));
FTYPES["abt"].pager = &pager;

