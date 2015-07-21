type protocol = 
  | TLS_PROTOCOL_TLSv1_0
  | TLS_PROTOCOL_TLSv1_1
  | TLS_PROTOCOL_TLSv1_2

type uchar_bigarray =
  (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t

module type TLS_CONFIG =
sig
  type t
  val create : unit -> t
  val set_ca_file : t -> string -> unit
  val set_ca_path : t -> string -> unit
  val set_ca_mem : t -> uchar_bigarray -> unit
  val set_cert_file : t -> string -> unit
  val set_cert_mem : t -> uchar_bigarray -> unit
  val set_ciphers : t -> string -> unit
  val set_dheparams : t -> string -> unit
  val set_ecdhecurve : t -> string -> unit
  val set_key_file : t -> string -> unit
  val set_key_mem : t -> uchar_bigarray -> unit
  val set_protocols : t -> protocol list -> unit
  val set_verify_depth : t -> int -> unit
  val clear_keys : t -> unit
  val parse_protocols : string -> Unsigned.uint32
  val insecure_noverifyhost : t -> unit
  val insecure_noverifycert : t -> unit
  val verify : t -> unit
end

module type ERROR =
sig
  type t
  val to_string : t -> string
  exception E of t
end

module type TLS =
sig
  type t

  module Error : ERROR
  module Config : TLS_CONFIG

  val init : unit -> unit
  val client : unit -> t
  val server : unit -> t
  val configure : t -> Config.t -> unit
  val reset : t -> unit
  val close : t -> unit
  val connect : t -> string -> string -> unit
  val connect_socket : t -> int -> string -> unit
  val read : t -> uchar_bigarray -> int
  val write : t -> uchar_bigarray -> unit
end
