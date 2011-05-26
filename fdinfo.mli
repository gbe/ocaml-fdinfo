exception Fdinfo_parse_error

type fdinfo = {
  num : int ;
  name : string ;
  offset : int64;
  flags : int64;
}
    
type pid
    
val pid_of_int : int -> pid

(** Returns all the fds opened by a pid. In case of errors, it can raise both the Unix module's exceptions and Fdinfo_parse_error **)
val get : pid -> fdinfo list
