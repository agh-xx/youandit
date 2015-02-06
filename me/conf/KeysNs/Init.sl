variable
  UP = 0x101,
  DOWN = 0x102,
  LEFT = 0x103,
  RIGHT = 0x104,
  PPAGE = 0x105,
  NPAGE = 0x106,
  HOME = 0x107,
  END = 0x108,
  REDO = 0x10E,
  UNDO = 0x10F,
  BACKSPACE = 0x110,
  IC = 0x112,
  DELETE = 0x113,
  F1 = 0x201,
  F2 = 0x202,
  F3 = 0x203,
  F4 = 0x204,
  F5 = 0x205,
  F6 = 0x206,
  F7 = 0x207,
  F8 = 0x208,
  F9 = 0x209,
  F10 = 0x20a,
  F11 = 0x20b,
  F12 = 0x20c,
  CTRL_a = 0x1,
  CTRL_b = 0x2,
  CTRL_d = 0x4,
  CTRL_e = 0x5,
  CTRL_f = 0x6,
  CTRL_h = 0x8,
  CTRL_j = 0xa,
  CTRL_k = 0xb,
  CTRL_l = 0xc,
  CTRL_n = 0xe,
  CTRL_o = 0xf,
  CTRL_p = 0x10,
  CTRL_r = 0x12,
  CTRL_t = 0x14,
  CTRL_u = 0x15,
  CTRL_v = 0x16,
  CTRL_w = 0x17,
  CTRL_x = 0x18,
  CTRL_y = 0x19,
  CTRL_z = 0x1a,
  CTRL_BSLASH = 0x1c,
  CTRL_BRACKETRIGHT = 0x1d,
  ESC_q = 0x10070;

ifnot (strncmp ("st-", getenv ("TERM"), 3))
  {
  END = 0x10c;
  NPAGE = 0x10d;
  PPAGE = 0x10a;
  HOME = 0x109;
  }

% command line map Array_Type
variable cmap = struct
  {
  sys = [F1], % system|application functions
  app = [F2], % Window_Types
  wrappers = [F3], % system commands that there is no slang library
  pers = [F4], % personal commands
  root = [F5],   % root window
  battery = [F9],
  changelang = [F10],
  % navigation
  home = [HOME, CTRL_a],
  end = [END, CTRL_e],
  left = [LEFT, CTRL_b],
  right = [RIGHT, CTRL_f],
  backspace = [BACKSPACE, CTRL_h],
  delete = [DELETE],
  delword = [CTRL_w],
  deltoend = [CTRL_u],
  % special keys
  % last components in previous commands
  lastcmp = [0xae, 0x1f], %ALT + . (not supported from all terms), CTRL + _
  % keep the command line, execute another and re-enter the keep'ed command
  lastcur = [ESC_q],
  windgoto = [CTRL_o],
  windnext = [CTRL_n],
  windprev = [CTRL_p],
  winddel = [CTRL_d],
  histup = [CTRL_r, UP],
  histdown = [DOWN],
  % used by functions
  fname = [CTRL_f],
  wind = struct
    {
    mode = [CTRL_w], % the mode key sequense
    split = ['s', 'v'], % split the window
    frnext = ['j', DOWN, 'w'], % next frame
    frprev = ['k', UP], % previous frame
    frdel = ['c', 'd'] % delete the current frame
    },
  };
 
variable search = struct
    {
    next = [CTRL_n],
    };

ifnot (access (sprintf ("%s/conf/KeysNs/Init.slc", USRNS), F_OK|R_OK))
  () = evalfile (sprintf ("%s/conf/KeysNs/Init", USRNS), "keys");
