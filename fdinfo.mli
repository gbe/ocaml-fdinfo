(**

	This module provides informations on file descriptors opened by another processus

*)

type fdinfo = {
  offset : int64;
  flags : string;
}

type pid
type fd

type valret = 
  | Ppid of pid list
  | Ffd of (fd * string) list

exception Fdinfo_parse_error
exception Fdinfo_sys_error of string

(* string is the failing Unix function name *)
exception Fdinfo_unix_error of (Unix.error * string * valret) ;;
    
val pid_of_int : int -> pid
val int_of_pid : pid -> int

val fd_of_int : int -> fd
val int_of_fd : fd -> int
val fd_of_string : string -> fd

val get_pids : unit -> pid list

(** [get_fds pid] returns a list of file descriptors [fd] and fullpath [string] of files opened by [pid]. In case of errors, it raises [Fdinfo_unix_error] *)
val get_fds : pid -> (fd * string) list

(** [get_infos pid fd] returns informations [fdinfo] extracted from /proc on the file [fd] opened by the processus [pid]. In case of errors, it raises [Fdinfo_parse_error] or [Fdinfo_sys_error] *)
val get_infos : pid -> fd -> fdinfo
