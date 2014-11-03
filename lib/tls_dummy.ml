module Error =
struct
  type t = unit
  let to_string () = "()"
  exception E of t
end

module Config =
struct
  type t = unit
  let create () = ()
  let set_ca_file () _ = ()
  let set_ca_path () _ = ()
  let set_cert_file () _ = ()
  let set_cert_mem () _ = ()
  let set_ciphers () _ = ()
  let set_ecdhcurve () _ = ()
  let set_key_file () _ = ()
  let set_key_mem  () _ = ()
  let set_protocols () _ = ()
  let set_verify_depth () _ = ()
  let clear_keys () = ()
  let insecure_noverifyhost () = ()
  let insecure_noverifycert () = ()
  let verify () = ()
end

type t = unit

let init () = ()
let client () = ()
let server () = ()
let configure () () = ()
let reset () = ()
let close () = ()
let connect () _ _ = ()
let connect_socket () _ _ = ()
let read () _ = 0
let write () _ = ()
