open Core_compat

let command =
  Core.Command.basic
    ~summary:"generate or serve file"
    [%map_open.Core.Command
     let mode = anon ("mode" %: string) in
         fun () ->
         match mode with
         | "server" -> Sssg.Server.launch_server ()
         | "gen" -> Sssg.Generator.populate_site ()
         | _ -> Stdio.print_endline ("Unknown mode: " ^ mode)
    ]

let () = Command_unix.run command ~version:"0.0.1" ~build_info:"beta"
