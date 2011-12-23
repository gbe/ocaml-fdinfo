(**

	This module provides informations on file descriptors opened by another processus

*)

exception Fdinfo_parse_error

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

(** [get_fds pid] returns a list of file descriptors [fd] and fullpath [string] of files opened by [pid]. In case of errors, it can raise both the Unix module's exceptions and [Fdinfo_parse_error] *)
val get_fds : pid -> (fd * string) list

val get_infos : pid -> fd -> fdinfo
