(* A simple test to show some functions *)


open Fdinfo

let _ =
  let p = pid_of_int 3634 in
  
  let l =
    try
      get_fds p
    with Unix.Unix_error (e,_,_) ->
      prerr_endline (Unix.error_message e) ;
      assert false
  in
  
  let fd = List.find (fun fd -> fd.num = 27) l in
  
  Printf.printf "File %s. Offset: %d\n" fd.name (Int64.to_int (get_offset p fd));
  Pervasives.flush Pervasives.stdout
;;
