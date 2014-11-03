open Ctypes
open Tls_types

(* We need to think about the semantics here.  Is there an extra level
   of indirection? *)
external create_stable_reference : Obj.t -> unit ptr = "%identity"
external read_stable_reference : unit ptr -> Obj.t = "%identity"
external release_stable_reference : unit ptr -> unit = "%identity"

module Make (T : TLS) =
struct
  (** Extend the TLS API so that each value of type [t] and each value of type
      [Config.t] holds a stable pointer to itself that can be passed to C. *)

  type 'a stabilised =
    { value: 'a;
      (* This is mutable to set up the cyclic reference, but is never modified
         after initialization. *)
      mutable stable: unit ptr }

  let build value =
    let r = { value; stable = null } in
    r.stable <- create_stable_reference (Obj.repr r);
    r

  let stable_ptr { stable } = stable
  let of_stable_ptr p = Obj.magic (read_stable_reference p)
  let release_stable_ptr { stable } = release_stable_reference stable

  let proj_1 f { value }       = f value
  let proj_2 f { value } x     = f value x
  let proj_3 f { value } x y   = f value x y
  let proj_4 f { value } x y z = f value x y z

  type t = T.t stabilised

  module Error = T.Error

  module Config =
  struct
    type t = T.Config.t stabilised
    let stable_ptr = stable_ptr
    let of_stable_ptr = of_stable_ptr
    let release_stable_ptr = release_stable_ptr

    let create () = build (T.Config.create ())

    let set_ca_file           = proj_1 T.Config.set_ca_file
    let set_ca_path           = proj_1 T.Config.set_ca_path
    let set_cert_file         = proj_1 T.Config.set_cert_file
    let set_cert_mem          = proj_1 T.Config.set_cert_mem
    let set_ciphers           = proj_1 T.Config.set_ciphers
    let set_ecdhcurve         = proj_1 T.Config.set_ecdhcurve
    let set_key_file          = proj_1 T.Config.set_key_file
    let set_key_mem           = proj_1 T.Config.set_key_mem
    let set_protocols         = proj_1 T.Config.set_protocols
    let set_verify_depth      = proj_1 T.Config.set_verify_depth
    let clear_keys            = proj_1 T.Config.clear_keys
    let insecure_noverifyhost = proj_1 T.Config.insecure_noverifyhost
    let insecure_noverifycert = proj_1 T.Config.insecure_noverifycert
    let verify                = proj_1 T.Config.verify
  end

  let init           = T.init
  let client ()      = build (T.client ())
  let server ()      = build (T.server ())
  let configure t c  = T.configure t.value c.value
  let reset          = proj_1 T.reset
  let close          = proj_1 T.close
  let connect        = proj_3 T.connect
  let connect_socket = proj_3 T.connect_socket
  let read           = proj_2 T.read
  let write          = proj_2 T.write
end
