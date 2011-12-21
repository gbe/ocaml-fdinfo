open Unix ;;

exception Fdinfo_parse_error ;;

type fdinfo = {
  offset : int64 ;
  flags : string ;
} ;;


type pid = int ;;
type fd = int ;;

let pid_of_int i = i ;;
let int_of_pid i = i ;;

let fd_of_int f = f ;;
let int_of_fd f = f ;;
let fd_of_string f = int_of_string f ;;


let get_infos pid fdnum =
  
  let pos = ref None in
  let flags = ref None in

  let r = Str.regexp "[0-9]+" in
  let file =
    Printf.sprintf "/proc/%d/fdinfo/%d"
      (int_of_pid pid) (int_of_fd fdnum)
  in


  let get_value delim =
    match delim with
      | Str.Delim value -> value
      | _ -> assert false
  in
  let strip_option var =
    match var with
      | None -> raise Fdinfo_parse_error
      | Some value -> value
  in

  let ic = ref None in

  begin
    try
      let inchan = open_in file in
      ic := Some inchan ;
      
      while true do
	let line = input_line inchan in
	
	match Str.full_split r line with
	  | text::[delim] ->
	    begin match text with
	      | Str.Text "pos:\t" ->
		pos := Some (get_value delim)

	      | Str.Text "flags:\t" ->
		flags := Some (get_value delim)

	      | _ -> raise Fdinfo_parse_error
	    end
	  | _ -> raise Fdinfo_parse_error

      done
    with
      | End_of_file ->
	begin match !ic with
	  | None -> ()
	  | Some inchan -> ignore (close_in inchan)
	end
      | Sys_error _ -> raise Fdinfo_parse_error

  end ;

  {
    offset = Int64.of_string (strip_option !pos) ;
    flags = strip_option !flags
  }

;;


let get_fds pid =

  let fds = ref [] in
  let dhopt = ref None in

  begin
    try
      let path = Printf.sprintf "/proc/%d/fd" (int_of_pid pid) in
      let dh = opendir path in
      dhopt := Some dh ;

      while true do
	let fdnum = readdir dh in
	let fullpath = path^"/"^fdnum in				
	let stats = Unix.stat fullpath in
	
	match stats.st_kind with
	  | S_LNK -> ()
 	  | S_DIR -> ()
	  | S_REG ->
	    fds := (fd_of_string fdnum, Unix.readlink fullpath)::(!fds)
	  | S_CHR -> ()
	  | S_BLK -> ()
	  | S_FIFO -> ()
	  | S_SOCK -> ()
      done;
    with End_of_file ->
      match !dhopt with
	| None -> ()
	| Some dh -> closedir dh
  end;
  !fds
;;
