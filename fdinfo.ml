open Unix ;;

exception Fdinfo_parse_error ;;
exception Fdinfo_unix_error of (Unix.error * string) ;;

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


let close_dh dhopt =
  match dhopt with
    | None -> ()
    | Some dh -> closedir dh
;;


let get_pids () =
  
  let dhopt = ref None in
  let proc = "/proc/" in
  
  let pids = ref [] in
  let r = Str.regexp "^[0-9]+$" in
  
  begin
    try
      let dh = Unix.opendir proc in
      dhopt := Some dh ;
      
      while true do
	let entry = Unix.readdir dh in
	
	(* This try/with is to prevent race conditions, but silently fails *)
	try
	  match Sys.is_directory (proc^entry) with
	    | false -> ()
	    | true ->
	      begin match entry with
		| ("." | "..") -> ()
		| _ ->
		  if Str.string_match r entry 0 then
		    pids := pid_of_int (int_of_string entry) :: (!pids)
		  else
		    ()
	      end
	with Sys_error _ -> ()
      done
    with
      | Unix_error (err, "opendir", _) ->
	close_dh !dhopt;
	raise (Fdinfo_unix_error (err, "opendir"))
	  
      | Unix_error (err, "readdir", _) ->
	close_dh !dhopt;
	raise (Fdinfo_unix_error (err, "readdir"))
	  
      | End_of_file -> close_dh !dhopt
  end ;

  !pids
;;


let get_fds pid =

  let fds = ref [] in
  let dhopt = ref None in

  begin
      let path = Printf.sprintf "/proc/%d/fd" (int_of_pid pid) in
      try
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
      with 
	| Unix_error (err, "opendir", _) ->
	  close_dh !dhopt;
	  raise (Fdinfo_unix_error (err, "opendir"))

	| Unix_error (err, "readdir", _) ->
	  close_dh !dhopt;
	  raise (Fdinfo_unix_error (err, "readdir"))

	| Unix_error (err, "readlink", _) ->
	  close_dh !dhopt;
	  raise (Fdinfo_unix_error (err, "readlink"))

	| Unix_error (err, "stat", _) ->
	  close_dh !dhopt;
	  raise (Fdinfo_unix_error (err, "stat"))

	| End_of_file ->
	  close_dh !dhopt;
  end;
  !fds
;;



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
