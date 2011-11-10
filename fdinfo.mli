(**

	This module provides informations on file descriptors opened by another processus

*)

exception Fdinfo_parse_error

type fdinfo = {
  offset : int64;
  flags : int64;
}


type pid
    
val pid_of_int : int -> pid

(** [get pid] returns file descriptors informations [fdinfo list] opened by [pid]. In case of errors, it can raise both the Unix module's exceptions and [Fdinfo_parse_error] *)
val get_fds : pid -> (int * string) list
val get_infos : int -> int -> fdinfo
