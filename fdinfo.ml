open Unix ;;

type fd = {
  num : int ;
  name : string ;
} ;;

type pid = int ;;
type content = Offset | Flags ;;

let pid_of_int i = i ;;
let int_of_pid i = i ;;

let get_fds pid =

  let file = Printf.sprintf "/proc/%d/fd" (int_of_pid pid) in
  
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
	
	fd_l := { num = (int_of_string fd_num) ; name = fd_name } :: (!fd_l)
      done;
      
    with End_of_file -> close_in ic
  end;
  
  !fd_l

;;

let get_content pid fd t =
  
  let r = Str.regexp "[0-9]+" in

  let grep =
    match t with
      | Offset -> "pos"
      | Flags -> "flags"
  in

  let file = Printf.sprintf "/proc/%d/fdinfo/%d" (pid_of_int pid) fd.num in

  Unix.access file [R_OK ; F_OK] ;

  let cmd = Printf.sprintf "grep %s %s" grep file in

  let ic = Unix.open_process_in cmd in
  let line = input_line ic in
  close_in ic ;

  let delim = List.nth (Str.full_split r line) 1 in

  let value =
    match delim with
    | Str.Text _ -> assert false
    | Str.Delim value -> value
  in

  Int64.of_string value
;;

let get_offset pid fd =
  get_content pid fd Offset
;;

let get_flags pid fd =
  get_content pid fd Flags
;;
