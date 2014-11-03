open Tls_types

module Make(T : TLS) :
sig
  module Config :
  sig
    include TLS_CONFIG
    val stable_ptr : t -> unit Ctypes.ptr
    val of_stable_ptr : unit Ctypes.ptr -> t
    val release_stable_ptr : t -> unit
  end

  include TLS
    with module Config := Config
  val stable_ptr : t -> unit Ctypes.ptr
  val of_stable_ptr : unit Ctypes.ptr -> t
  val release_stable_ptr : t -> unit
end

