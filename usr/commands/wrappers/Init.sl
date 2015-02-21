define main (self)
{
  variable
    keys = Assoc_Type[List_Type],
    mydir = path_dirname (__FILE__);

  keys["mount"] = {sprintf ("%s/mount", mydir), NULL, "mount filesystem (without args prints the mounted filesystems)",
    ["--mountpoint= directory MountPoint",
     "--device= filename Device"], NULL};

  keys["file"] = {sprintf ("%s/file", mydir), NULL, "print information about files (file wrapper)",
    NULL, NULL};

  keys["dfh"] = {sprintf ("%s/dfh", mydir), NULL, "print imformation about filesystems",
    NULL, NULL};

  keys["duskh"] = {sprintf ("%s/duskh", mydir), NULL, "print file size",
    NULL, NULL};

  keys["umount"] = {sprintf ("%s/umount", mydir), NULL, "umount filesystem",
    ["--mountpoint= directory MountPoint"], NULL};

  throw Return, " ", struct
    {
    exec = root.exec,
    call = root.call,
    keys = keys
    };
}
