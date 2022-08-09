open Base

let create_newdir path =
  let dirpath = Filepaths.site ^ path in
  match Core_compat.Sys_unix.file_exists dirpath with
  | `Yes -> ()
  | `No -> Core_compat.Core_unix.mkdir dirpath
  | `Unknown -> Core_compat.Core_unix.mkdir dirpath (* idk if error comes we check what happened *)

let save_file content filepath =
  Stdio.Out_channel.write_all (Filepaths.site ^ filepath) ~data:content

let copy_file from_path to_path =
  let content = Stdio.In_channel.read_all from_path in
  Stdio.Out_channel.write_all to_path ~data:content

let populate_site () =
  create_newdir "";
  let all_files_in path = Core_compat.Sys_unix.ls_dir path in
  let css = Stdio.In_channel.read_all (Filepaths.base ^ "styles/index.css") in
  create_newdir "css";
  save_file css "css/default.css";
  let main_page = Index.render |> Default.render in
  save_file main_page "index.html";
  let sections = all_files_in Filepaths.sections in
  Base.List.iter sections ~f:(fun dirname ->
      let section_page = Section.render dirname |> Default.render in
      create_newdir dirname;
      save_file section_page (dirname ^ "/index.html");
      let section_dir = Filepaths.sections ^ dirname in
      let posts = all_files_in section_dir in
      match posts with
      | ["index.html"] -> ()
      | _ ->
         Base.List.iter posts ~f:(fun post_filename ->
             let post_filedir = (section_dir ^ "/" ^ post_filename) in
             let post_filepath = (post_filedir ^ "/" ^ post_filename ^ ".html") in
             let post_page = Post.render post_filepath |> Default.render in
             let post_dir = dirname ^ "/" ^ post_filename in
             create_newdir post_dir;
             save_file post_page (post_dir ^ "/index.html");
             let static = all_files_in post_filedir in
             let static = Base.List.filter static ~f:(fun name -> not (String.equal name (post_filename ^ ".html"))) in
             Base.List.iter static ~f:(fun static_name ->
                 copy_file (post_filedir ^ "/" ^ static_name) (Filepaths.site ^ post_dir ^ "/" ^ static_name)
               )
           )
    )
