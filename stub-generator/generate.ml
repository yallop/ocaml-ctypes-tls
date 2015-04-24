(** A driver for stub generation.  Build OCaml and C code from the
    Tls_bindings.Stubs functor. *)

let generate (module T : Tls_types.TLS) dirname =
  let prefix = "tls" in
  let path basename = Filename.concat dirname basename in
  let ml_fd = open_out (path "tls_generated_bindings.ml") in
  let c_fd = open_out (path "tls.c") in
  let h_fd = open_out (path "tls_generated.h") in
  let stubs = (module Tls_bindings.Stubs(T) : Cstubs_inverted.BINDINGS) in
  begin
    (* Generate the ML module that links in the generated C. *)
    Cstubs_inverted.write_ml 
      (Format.formatter_of_out_channel ml_fd) ~prefix stubs;

    (* Generate the C source file that exports OCaml functions. *)
    Format.fprintf (Format.formatter_of_out_channel c_fd)
      "#define const@\n#include \"tls.h\"@\n#include \"tls_generated.h\"@\n%a"
      (Cstubs_inverted.write_c ~prefix) stubs;

    (* Generate a header. *)
    Format.fprintf (Format.formatter_of_out_channel h_fd)
      "%(%)%(%)%(%)%(%)%a@\n%(%)@."
      "#ifndef TLS_GENERATED_H@\n"
      "#define TLS_GENERATED_H@\n@\n"
      "#include <stdint.h>@\n"
      "#include <stddef.h>@\n@\n"
      (Cstubs_inverted.write_c_header ~prefix) stubs
      "#endif /* TLS_GENERATED_H */"
  end;
  close_out h_fd;
  close_out c_fd;
  close_out ml_fd

let () = generate (module Tls_dummy) (Sys.argv.(1))
