open Unix
open Str

let exists filename = try ignore (lstat filename); true with error -> false;;

let list_of_dir dirname =
  let dirh = opendir dirname in
  let rec readit () =
    match (try Some (readdir dirh) with End_of_file -> None) with
      Some "." -> readit ()
    | Some ".." -> readit ()
    | Some x -> x :: readit ()
    | None -> []
  in 
  let result = readit () in
  closedir dirh;
  result;;

let fold_directory func firstval dirname =
  List.fold_left func firstval (list_of_dir dirname);;

let isdir name =
  try (stat name).st_kind = S_DIR with error -> false;;

let abspath name =
  if not (Filename.is_relative name) then
    name
  else begin
    let startdir = Sys.getcwd() in
    if isdir name then begin
      chdir name;
      let retval = Sys.getcwd () in
      chdir startdir;
      retval;
    end else begin
      let base = Filename.basename name in
      let dirn = Filename.dirname name in
      chdir dirn;
      let retval = Filename.concat (Sys.getcwd()) base in
      chdir startdir;
      retval;
    end;
  end;;

let getfirstline filename =
  let fd = open_in filename in
  let line = input_line fd in
  close_in fd;
  line

let getlines filename =
  let fd = open_in filename in
  let retval = ref [] in
  begin
    try
      while true do
        retval := (input_line fd) :: !retval
      done
    with End_of_file -> ();
  end;
  close_in fd;
  !retval

let regexp_of_glob pat =
  Str.regexp
    (Printf.sprintf "^%s$"
       (String.concat ""
          (List.map
             (function
                | Str.Text s -> Str.quote s
                | Str.Delim "*" -> ".*"
                | Str.Delim "?" -> "."
                | Str.Delim _ -> assert false)
             (Str.full_split (Str.regexp "[*?]") pat))))

let glob pat =
  let basedir = Filename.dirname pat in
  let files = Sys.readdir basedir in
  let regexp = regexp_of_glob (Filename.basename pat) in
  List.map
    (Filename.concat basedir)
    (List.filter
       (fun file -> Str.string_match regexp file 0)
       (Array.to_list files))
