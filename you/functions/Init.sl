define main (self)
{
  variable
    keys = Assoc_Type[List_Type],
    mydir = path_dirname (__FILE__);

  % index 1: support for qualifiers, index 4:  if 1 allow --help from application
  keys["moonphase"] = {sprintf ("%s/moon_phase", mydir), NULL,
    "Print the Phase of The Moon, args: [tf]",
    ["--tf=  string time format in ss:mm:hh:dd:mm:yy",
     "--for= int    repeat action 'for' times"], NULL};
 
  keys["shutdown_at"] = {sprintf ("%s/shutdown_at", mydir), NULL,
    "schedule shutdown",
    ["--minutes=       int  halt machine after minutes",
     "--killlastaction void kill last scheduled action (if any)",
     "--when           void show the scheduled halt time (if any)"], NULL};

  keys["remove_spaces_from_fnames"] = {
    sprintf ("%s/remove_spaces_from_fnames", mydir), NULL,
    "replace the spaces from filenames with an underscore by default",
    ["--recursive void   make changes recursivelly",
     "--sub=      string string to replace",
     "--info      void   show information",
     "--help      void   show help"
    ], 1};
 
  keys["iso2utf8"] = {sprintf ("%s/iso2utf8", mydir), NULL,
   "change iso encoding to UTF8",
   ["--recursive  void   make changes recursivelly",
    "--force      void   force convertion",
    "--iso=       string ISO encoding, default is ISO88597",
    "--backup=    string backup with the given extension, if `no' make no backup",
    "--info       void   show information",
    "--help       void   show help"
   ], 1};

  keys["settime"] = {sprintf ("%s/settime", mydir), NULL,
    "change system time and adjust hardware clock",
    ["--tf= string time format in, ss:mm:hh:dd:mm:yy"], NULL};
 
  keys["digraphs"] = {sprintf ("%s/digraphs", mydir), NULL,
   "Print the digraphs", NULL, NULL};
 
  keys["calculator"] = {sprintf ("%s/calculator", mydir), NULL, "simple calculator (NEEDS SOME CARE)",
    NULL, NULL};

  % if a key "intro" in pers/functions/Init.sl exists, this will be overriden
  keys["intro"] = {sprintf ("%s/intro", mydir), NULL,
    "Show intro, (currently the introduction to this program)", NULL, NULL};

  keys["weather"] = {sprintf ("%s/weather", mydir), NULL, "Weather application",
   ["--help void show help",
    "--search= string Search for a place to find the Latitude, Longitude values",
    "--dont-retrieve void Do not retrieve data from internet, instead use a local db",
    "--days= int Get for num days instead of five (default)",
    "--uselocation=  string Use this location instead of the default"], 1};

  throw Return, " ", struct
    {
    exec = self.exec,
    call = root.call,
    keys = keys,
    };
}
