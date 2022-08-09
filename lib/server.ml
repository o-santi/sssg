let loader root path request =
  match Filename.extension path with
  | "" -> Dream.from_filesystem root (path ^ "/index.html") request
  | _ -> Dream.from_filesystem root path request

let launch_server () =
  Dream.run
  @@ Dream.router [
         Dream.get "/" (Dream.from_filesystem "_site/" "index.html");
         Dream.get "/**" @@ Dream.static ~loader "_site";
       ]
