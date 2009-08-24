{application, beep,
 [{description, "beep"},
  {vsn, "0.01"},
  {modules, [
    beep,
    beep_app,
    beep_sup,
    beep_web,
    beep_deps
  ]},
  {registered, []},
  {mod, {beep_app, []}},
  {env, []},
  {applications, [kernel, stdlib, crypto]}]}.
