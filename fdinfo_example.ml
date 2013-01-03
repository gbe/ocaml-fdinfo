(* A simple example to show how it works. *)


open Fdinfo;;

let print_fds info_list pid =
  List.iter (fun (fd', fullpath) ->
    try
      let infos = Fdinfo.get_infos pid fd' in
      Printf.printf "File descriptor number: %d\n" (int_of_fd fd') ;
      Printf.printf "Name: %s\n" fullpath ;
      Printf.printf "Current offset: %s\n" (Int64.to_string infos.offset) ;
      Printf.printf "Flags: %s\n\n"  infos.flags
    with
      | Fdinfo_parse_error ->
	prerr_endline "An error occurred while parsing data from /proc"

      | Fdinfo_sys_error errmsg ->
	prerr_endline ("Sys error: "^errmsg)
  )
    info_list
;;


let _ =
  
  let usage = "usage: fdinfo_example pid" in

  if (Array.length Sys.argv) <> 2 then
    begin
      print_endline usage ;
      exit 1
    end ;
  
  let ipid =
    try
      int_of_string (Sys.argv.(1))
    with Failure "int_of_string" ->
      print_endline usage ;
      exit 2
  in
  
  let p = pid_of_int ipid in
  
  let info_list =
    try	
      Fdinfo.get_fds p
    with
      | Fdinfo_unix_error (error, funct, fdsret) ->
	prerr_endline ((Unix.error_message error)^" in funct: "^funct);
	match fdsret with
	  | Ppid _ -> assert false
	  | Ffd fds -> fds
  in
  Printf.printf "Length: %d\n" (List.length info_list);
  print_fds info_list p;
  
  flush stdout  
;;
