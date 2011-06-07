(* A simple example to show how it works.
 * You need to know the pid to use this library.
 *)


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
      let info_list = Fdinfo.get p in
      List.iter (fun info ->
	Printf.printf "File descriptor number: %d\nName: %s\nCurrent offset: %Ld\nFlags: %Ld\n\n"
	info.num info.name info.offset info.flags
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