(**

	This module provides informations on file descriptors opened by another processus

*)

exception Fdinfo_parse_error
exception Fdinfo_unix_error of (Unix.error * string) ;;

type fdinfo = {
  offset : int64;
  flags : string;
}


type pid
type fd
    
val pid_of_int : int -> pid
val int_of_pid : pid -> int

val fd_of_int : int -> fd
val int_of_fd : fd -> int
val fd_of_string : string -> fd

val get_pids : unit -> pid list

(** [get_fds pid] returns a list of file descriptors [fd] and fullpath [string] of files opened by [pid]. In case of errors, it can raise both [Fdinfo_unix_error] and [Fdinfo_parse_error] *)
val get_fds : pid -> (fd * string) list

(** [get_infos pid fd] returns informations [fdinfo] extracted from /proc on the file [fd] opened by the processus [pid] *)
val get_infos : pid -> fd -> fdinfo
