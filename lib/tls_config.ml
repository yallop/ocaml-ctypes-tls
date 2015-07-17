open Tls_types

module Tls_config : TLS_CONFIG =
struct
  type t = {
      mutable ca_file      : string option;
      mutable ca_path      : string option;
      mutable cert_file    : string option;
      mutable cert_mem     : uchar_bigarray option;
      mutable ciphers      : string option;
      mutable ecdhcurve    : string option;
      mutable key_file     : string option;
      mutable key_mem      : uchar_bigarray option;
      mutable protocols    : protocol list option;
      mutable verify_depth : int option;
    }
  let create () = {
      ca_file      = None;
      ca_path      = None;
      cert_file    = None;
      cert_mem     = None;
      ciphers      = None;
      ecdhcurve    = None;
      key_file     = None;
      key_mem      = None;
      protocols    = None;
      verify_depth = None;
    }      

  let set_ca_file conf v = conf.ca_file <- Some v
  let set_ca_path conf v = conf.ca_path <- Some v
  let set_cert_file conf v = conf.cert_file <- Some v
  let set_cert_mem conf v = conf.cert_mem <- Some v
  let set_ciphers conf v = conf.ciphers <- Some v
  let set_ecdhcurve conf v = conf.ecdhcurve <- Some v
  let set_key_file conf v = conf.key_file <- Some v
  let set_key_mem conf v = conf.key_mem <- Some v
  let set_protocols conf v = conf.protocols <- Some v
  let set_verify_depth conf v = conf.verify_depth <- Some v
  let clear_keys _ = () (* TODO *)
  let insecure_noverifyhost _ = () (* TODO *)
  let insecure_noverifycert _ = () (* TODO *)
  let verify _ = () (* TODO *)
end
