static variable
  getfrom = Assoc_Type[Assoc_Type],
  askfor = Assoc_Type[Struct_Type];

public define __dt (data)
{
  return sprintf ("%S %S", typeof (data), _typeof (data));
}

() = evalfile (sprintf ("%s/map/Init", path_dirname (__FILE__)), "map");

getfrom["map"] = Assoc_Type[Struct_Type];
getfrom["map"][__dt ([1])] = map->ar_integer_type ();
