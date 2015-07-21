open Tls_types

module Tls_config : TLS_CONFIG =
struct
  type t = {
      mutable ca_file      : string option;
      mutable ca_path      : string option;
      mutable ca_mem       : uchar_bigarray option;
      mutable cert_file    : string option;
      mutable cert_mem     : uchar_bigarray option;
      mutable ciphers      : string option;
      mutable ecdhecurve   : int;
      mutable dheparams    : int;
      mutable key_file     : string option;
      mutable key_mem      : uchar_bigarray option;
      mutable protocols    : protocol list option;
      mutable verify_cert  : int;
      mutable verify_depth : int;
      mutable verify_name  : int;
    }
  let defaults = {
      ca_file      = None;
      ca_path      = None;
      ca_mem       = None;
      cert_file    = None;
      cert_mem     = None;
      ciphers      = None;
      ecdhecurve   = -1;
      dheparams    = 0;
      key_file     = None;
      key_mem      = None;
      protocols    = None;
      verify_depth = 6;
      verify_cert  = 0;
      verify_name  = 0;
    }

  let create () =
    (* Return a copy of 'defaults' *)
    {defaults with ca_file = defaults.ca_file}

  let set_ca_file conf v = conf.ca_file <- Some v
  let set_ca_path conf v = conf.ca_path <- Some v
  let set_ca_mem conf v = conf.ca_mem <- Some v
  let set_cert_file conf v = conf.cert_file <- Some v
  let set_cert_mem conf v = conf.cert_mem <- Some v
  let set_ciphers conf v = conf.ciphers <- Some v
  let set_ecdhecurve conf v = assert false (* TODO *)
  let set_dheparams conf v = assert false (* TODO *)
  let set_key_file conf v = conf.key_file <- Some v
  let set_key_mem conf v = conf.key_mem <- Some v
  let set_protocols conf v = conf.protocols <- Some v
  let set_verify_depth conf v = conf.verify_depth <- v
  let clear_keys _ = () (* TODO *)
  let parse_protocols _ = assert false (* TODO *)
  let insecure_noverifyhost _ = () (* TODO *)
  let insecure_noverifycert _ = () (* TODO *)
  let verify conf =
    begin
      conf.verify_cert <- 1;
      conf.verify_name <- 1;
    end
end
