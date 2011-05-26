open Unix ;;

exception Fdinfo_parse_error ;;

type fdinfo = {
  num : int ;
  name : string ;
  offset : int64 ;
  flags : int64 ;
} ;;

type pid = int ;;

let pid_of_int i = i ;;
let int_of_pid i = i ;;


let get_infos pid fdnum =
  
  let pos = ref None in
  let flags = ref None in

  let r = Str.regexp "[0-9]+" in
  let file = Printf.sprintf "/proc/%d/fdinfo/%s" pid fdnum in
  Unix.access file [R_OK ; F_OK] ;
  let ic = Unix.open_process_in ("more "^file) in

  let get_value delim =
    match delim with
      | Str.Delim value -> value
      | _ -> assert false
  in

  begin
    try
      while true do
	let line = input_line ic in
	
	match Str.full_split r line with
	  | text::[delim] ->
	    begin match text with
	      | Str.Text "pos:\t" -> pos := Some (get_value delim)
	      | Str.Text "flags:\t" -> flags := Some (get_value delim)
	      | _ -> raise Fdinfo_parse_error
	    end
	  | _ -> raise Fdinfo_parse_error
	    
      done ;
    with End_of_file -> ignore (close_process_in ic)
  end ;

  let strip_option var =
    match var with
      | None -> raise Fdinfo_parse_error
      | Some value -> value
  in

  ((strip_option !pos), (strip_option !flags))

;;




let get pid =

  let ipid = int_of_pid pid in

  let file = Printf.sprintf "/proc/%d/fd" ipid in
  
  Unix.access file [R_OK ; X_OK ; F_OK] ;
  
  let cmd = Printf.sprintf "ls -goQ %s | grep -v total" file in
  let ic = Unix.open_process_in cmd in
  let r = Str.regexp "\"[^\"]+\"" in
  
  let fd_l = ref [] in
  
  let clean_delim s =
    String.sub s 1 ((String.length s) - 2)
  in
  
  begin
    try
      while true do
	let line = input_line ic in
	
	ignore (Str.search_forward r line 0);
	
	let fd_num_dirty = Str.matched_string line in
	let fd_num = clean_delim fd_num_dirty in
	
	ignore (Str.search_backward r line (String.length line));
	let fd_name_dirty = Str.matched_string line in
	let fd_name = clean_delim fd_name_dirty in

	let (offset, flags) = get_infos ipid fd_num in
	
	fd_l := {
	  num = (int_of_string fd_num) ;
	  name = fd_name ;
	  offset = Int64.of_string offset ;
	  flags = Int64.of_string flags
	} :: (!fd_l)
      done;
      
    with End_of_file -> ignore (close_process_in ic)
  end;
  
  !fd_l

;;

