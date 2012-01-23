module Stat =
  struct

    open Datatypes
    open Printf
    open Glist
    open Gstr
    open Jark
    open Config
    open Plugin
    open Jvm

    let registry = Plugin.create ()
    let register_fn = Plugin.register_fn registry
    let alias_fn = Plugin.alias_fn registry

    let show_usage args = Plugin.show_usage registry "stat"

    let get_pid () = Jvm.get_pid ()

    let instrument name =
      Jark.nfa "recon.core" ~f:"instrument-value" ~a:["localhost"; get_pid() ; name] ()

    let stat_instrument args = match args with
      [x] -> instrument x
    | _   -> Plugin.show_cmd_usage registry "instrument"


    let instruments args = match args with
      [] -> Jark.nfa "recon.core" ~f:"instrument-names" ~a:["localhost"; get_pid()] ()
    | x :: xs -> stat_instrument [x]

    let vms args =
      Jark.nfa "recon.core" ~f:"vms" ~a:args ()

    let mem args =
      Jark.nfa "jark.vm" ~f:"stats" ~fmt:ResHash ()

    let pid args = Gstr.pe (get_pid ())

    let _ =
      register_fn "instruments" instruments [
        "[prefix]" ;
        "List all available instruments. Optionally takes a regex\n"];

      register_fn "instrument" stat_instrument [
        "<instrument-name>" ;
        "Print the value for the given instrument name"];

      register_fn "mem" mem ["Print the memory usage of the JVM"];

      register_fn "vms" vms [
        "--remote-host <host>" ;
        "List the vms running on remote host\n"];

      register_fn "pid" pid ["Show pid of running JVM"]

    let dispatch cmd arg =
      Plugin.dispatch registry cmd arg

end
