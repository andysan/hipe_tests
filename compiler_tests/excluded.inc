excluded("stdlib") ->
    [erl_parse];  % COMPILATION TAKES LONG TIME
excluded("kernel") ->
    [erl_prim_loader, erlang, error_handler, group,
     init, otp_ring0, prim_file, prim_inet, hipe_sparc_loader];
excluded("ic") ->
    [icparse];  % COMPILATION TAKES LONG TIME
excluded("megaco") ->
    [megaco_text_parser]; % COMPILATION TAKES LONG TIME
excluded("cosNotification") ->
    [oe_CosEvent]; % no such file
excluded("etk") ->
    [tk, etk_menu, tkbutton, tkentry, tklistbox, tkmenu, tkscale, tkscrlbar,
     tktext, tkconsole, tkdialog, tkfocus, tkoptmenu, tktearoff
    ]; % bump in beam_disasm for some reason
excluded(_) ->
    [].

