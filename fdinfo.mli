type fd = {
  num : int ;
  name : string ;
}
    
type pid
    
val pid_of_int : int -> pid

(** Returns all the fds opened by a pid. In case of errors, it raises the Unix module's exceptions **)
val get_fds : pid -> fd list

(** Returns the offset of a fd opened by pid. In case of errors, it raises the Unix module's exceptions **)
val get_offset : pid -> fd -> int64

(** Returns the flags of a fd opened by pid. In case of errors, it raises the Unix module's exceptions **)
val get_flags : pid -> fd -> int64
