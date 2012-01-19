module Self :
  sig
    val dispatch : string -> string list -> unit

    val show_usage : unit -> unit

    val install : unit -> unit

    val status : unit -> unit
  end
