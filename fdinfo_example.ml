(* A simple example to show how it works. *)


open Fdinfo;;

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
  
  begin
    try
      let info_list = Fdinfo.get_fds p in
      Printf.printf "Length: %d\n" (List.length info_list);
      Pervasives.flush Pervasives.stdout;
      
      List.iter (fun (fd', fullpath) ->
	let infos = Fdinfo.get_infos p fd' in
	Printf.printf "File descriptor number: %d\n" (int_of_fd fd') ;
	Printf.printf "Name: %s\n" fullpath ;
	Printf.printf "Current offset: %s\n" (Int64.to_string infos.offset) ;
	Printf.printf "Flags: %s\n\n"  infos.flags ;
      )
	info_list
    with
      | Unix.Unix_error (e,_,_) ->
	prerr_endline (Unix.error_message e) ;
	
      | Fdinfo_parse_error ->
	prerr_endline "An error occurred while parsing data from /proc"
  end ;
  
  flush stdout  
;;
