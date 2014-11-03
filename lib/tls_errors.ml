open Tls_types

module Make (T : TLS) =
struct
  (** Translate the error handling protocol: from each TLS functions that can
      either raise an exception or return unit, build a new function that
      returns -1 or 0 and stores exceptions in a global buffer.

      Add a function [errror] that formats the last error, if any. *)

  (* The global error buffer is rather unpleasant, but the API seems to impose
     it.  Many of the tls_config_* functions can return error statuses but the only
     way to retrieve an error message is via the tls_error function which is
     unconnected with the tls_config struct. *)
  let last_error = ref None

  let error _ =
    (* This function needs to handle errors from all contexts; how could it take
       the argument into account? *)
    match !last_error with
      None -> None
    | Some (T.Error.E e) -> Some (T.Error.to_string e)
    | Some e -> Some (Printexc.to_string e)

  let store_error e = last_error := Some e

  let handle_1 f w =
    match f w       with exception e -> store_error e; -1 | () -> 0
  let handle_2 f w x =
    match f w x     with exception e -> store_error e; -1 | () -> 0
  let handle_3 f w x y =
    match f w x y   with exception e -> store_error e; -1 | () -> 0
  let handle_4 f w x y z =
    match f w x y z with exception e -> store_error e; -1 | () -> 0

  type t = T.t

  module Config =
  struct
    include T.Config
    let set_ca_file      = handle_2 set_ca_file
    let set_ca_path      = handle_2 set_ca_path
    let set_cert_file    = handle_2 set_cert_file
    let set_cert_mem     = handle_2 set_cert_mem
    let set_ciphers      = handle_2 set_ciphers
    let set_ecdhcurve    = handle_2 set_ecdhcurve
    let set_key_file     = handle_2 set_key_file
    let set_key_mem      = handle_2 set_key_mem
    let set_protocols    = handle_2 set_protocols
    let set_verify_depth = handle_2 set_verify_depth
  end

  let init           = handle_1 T.init
  let client         =          T.client
  let server         =          T.server
  let configure      = handle_2 T.configure
  let reset          =          T.reset
  let close          = handle_1 T.close
  let connect        = handle_3 T.connect
  let connect_socket = handle_3 T.connect_socket
  let write          = handle_2 T.write
  let read t buf =
    match T.read t buf with
    exception e -> store_error e; None
    | n -> Some n
end
