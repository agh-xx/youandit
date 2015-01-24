ifnot (is_defined ("DEVCOMS"))
  variable DEVCOMS;

% this should be constant
ifnot (is_defined ("DEVNS"))
  variable DEVNS = sprintf ("%s/dev", ROOTDIR);

% make it possible to turn on through the application
DEV = 1;
