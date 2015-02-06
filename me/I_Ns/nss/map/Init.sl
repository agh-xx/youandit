private define getmap (s, map)
{
  variable
    maps = Assoc_Type[Array_Type, Integer_Type[0]];

  maps["el"] =  [['α':'ω'], ['Α':'Ω'], 'ά','έ','ή','ί','ό','ύ','ώ','Ά',
      'Έ','Ό','Ί','Ώ','Ύ','Ή'];

  return maps[map];
}

static define ar_integer_type ()
{
  return struct
    {
    getmap = &getmap
    };
}
