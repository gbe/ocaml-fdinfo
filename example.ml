(* A simple test to show how it works *)

open Fdinfo;;

let _ =
  
  (* you need to know the pid to use this library *)
  let p = pid_of_int (int_of_string (Sys.argv.(1))) in
  
  begin
    try
      let info_list = Fdinfo.get p in
      List.iter (fun info ->
	Printf.printf "File descriptor number: %d\nName: %s\nCurrent offset: %Ld\nFlags: %Ld\n\n" info.num info.name info.offset info.flags)
	info_list
    with
      | Unix.Unix_error (e,_,_) ->
	prerr_endline (Unix.error_message e) ;
	
      | Fdinfo_parse_error ->
	prerr_endline "An error occurred while parsing data from /proc"
  end ;

  flush stdout
        
;;
