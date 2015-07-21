open Ctypes
open Tls_types

let uchar_bigarray_view : 'a. 'a ptr -> Unsigned.size_t -> uchar_bigarray =
  fun start n ->
    bigarray_of_ptr array1 (Unsigned.Size_t.to_int n) Bigarray.int8_unsigned
      (coerce (ptr (reference_type start)) (ptr int) start)

module Stubs(T : TLS)(I : Cstubs_inverted.INTERNAL) =
struct
  module T_stable = Tls_stable.Make(T)
  module T = Tls_errors.Make(T_stable)

  (* The "abstract" types that we expose to C *)
  let struct_tls : [`tls] structure typ = structure "tls"
  let struct_tls_config : [`tls_config] structure typ = structure "tls_config"

  (* View 'struct tls *' as T_stable.t *)
  let ptr_of_t t = from_voidp struct_tls (T_stable.stable_ptr t)
  let t_of_ptr p = T_stable.of_stable_ptr (to_voidp p)
  let tls = view (ptr struct_tls)
      ~read:t_of_ptr ~write:ptr_of_t

  (* View 'struct tls_config *' as T_stable.Config.t *)
  let ptr_of_config t = from_voidp struct_tls_config (T_stable.Config.stable_ptr t)
  let config_of_ptr p = T_stable.Config.of_stable_ptr (to_voidp p)
  let tls_config = view (ptr struct_tls_config)
      ~read:config_of_ptr ~write:ptr_of_config

  (* View uint32_t as a protocol list *)
  let protocol_value = Unsigned.UInt32.(function
        TLS_PROTOCOL_TLSv1_0 -> of_int 1
      | TLS_PROTOCOL_TLSv1_1 -> of_int 2
      | TLS_PROTOCOL_TLSv1_2 -> of_int 4)
  let crush_options f =
    Unsigned.UInt32.(List.fold_left (fun i o -> Infix.(i lor (f o))) (of_int 0))
  let extract_options u = Unsigned.UInt32.(Infix.(
      if u land of_int 1 <> zero then [TLS_PROTOCOL_TLSv1_0] else [] @
      if u land of_int 2 <> zero then [TLS_PROTOCOL_TLSv1_1] else [] @
      if u land of_int 4 <> zero then [TLS_PROTOCOL_TLSv1_2] else []))
  let protocols : protocol list typ = view uint32_t
      ~read:extract_options ~write:(crush_options protocol_value)

  let tls_init = I.internal "tls_init"
      (void @-> returning int) T.init

  let tls_error = I.internal "tls_error"
      (tls @-> returning string_opt)
      T.error

  let tls_config_new = I.internal "tls_config_new"
      (void @-> returning (tls_config))
      T.Config.create

  let tls_config_free = I.internal "tls_config_free"
      (tls_config @-> returning void)
      T_stable.Config.release_stable_ptr

  let tls_config_set_ca_file = I.internal "tls_config_set_ca_file"
      (tls_config @-> string @-> returning int)
      T.Config.set_ca_file

  let tls_config_set_ca_path = I.internal "tls_config_set_ca_path"
      (tls_config @-> string @-> returning int)
      T.Config.set_ca_path

  let tls_config_set_ca_mem = I.internal "tls_config_set_ca_mem"
      (tls_config @-> ptr uint8_t @-> size_t @-> returning int)
      (fun t buf n -> T.Config.set_ca_mem t (uchar_bigarray_view buf n))

  let tls_config_set_cert_file = I.internal "tls_config_set_cert_file"
      (tls_config @-> string @-> returning int)
      T.Config.set_cert_file

  let tls_config_set_cert_mem = I.internal "tls_config_set_cert_mem"
      (tls_config @-> ptr uint8_t @-> size_t @-> returning int)
      (fun t buf n -> T.Config.set_cert_mem t (uchar_bigarray_view buf n))

  let tls_config_set_ciphers = I.internal "tls_config_set_ciphers"
      (tls_config @-> string @-> returning int)
      T.Config.set_ciphers

  let tls_config_set_dheparams = I.internal "tls_config_set_dheparams"
      (tls_config @-> string @-> returning int)
      T.Config.set_dheparams

  let tls_config_set_ecdhecurve = I.internal "tls_config_set_ecdhecurve"
      (tls_config @-> string @-> returning int)
      T.Config.set_ecdhecurve

  let tls_config_set_key_file = I.internal "tls_config_set_key_file"
      (tls_config @-> string @-> returning int)
      T.Config.set_key_file

  let tls_config_set_key_mem = I.internal "tls_config_set_key_mem"
      (tls_config @-> ptr uint8_t @-> size_t @-> returning int)
      (fun t buf n -> T.Config.set_key_mem t (uchar_bigarray_view buf n))

  let tls_config_set_protocols = I.internal "tls_config_set_protocols"
      (tls_config @-> protocols @-> returning int)
      T.Config.set_protocols

  let tls_config_set_verify_depth = I.internal "tls_config_set_verify_depth"
      (tls_config @-> int @-> returning int)
      T.Config.set_verify_depth

  let tls_config_clear_keys = I.internal "tls_config_clear_keys"
      (tls_config @-> returning void)
      T.Config.clear_keys

  let tls_config_parse_protocols = I.internal "tls_config_parse_protocols"
      (ptr uint32_t @-> string @-> returning int)
      T.Config.parse_protocols

  let tls_config_insecure_noverifyhost = I.internal "tls_config_insecure_noverifyhost"
      (tls_config @-> returning void)
      T.Config.insecure_noverifyhost

  let tls_config_insecure_noverifycert = I.internal "tls_config_insecure_noverifycert"
      (tls_config @-> returning void)
      T.Config.insecure_noverifycert

  let tls_config_verify = I.internal "tls_config_verify"
      (tls_config @-> returning void)
      T.Config.verify

  let tls_client = I.internal "tls_client"
      (void @-> returning tls)
      T.client

  let tls_server = I.internal "tls_server"
      (void @-> returning tls)
      T.server

  let tls_configure = I.internal "tls_configure"
      (tls @-> tls_config @-> returning int)
      T.configure

  let tls_reset = I.internal "tls_reset"
      (tls @-> returning void)
      T.reset

  let tls_close = I.internal "tls_close"
      (tls @-> returning int)
      T.close

  let tls_free = I.internal "tls_free"
      (tls @-> returning void)
      T_stable.release_stable_ptr

  let tls_connect = I.internal "tls_connect"
      (tls @-> string @-> string @-> returning int)
      T.connect
  
  let tls_connect_socket = I.internal "tls_connect_socket"
      (tls @-> int @-> string @-> returning int)
      T.connect_socket

  let tls_read = I.internal "tls_read"
      (tls @-> ptr void @-> size_t @-> ptr size_t @-> returning int)
      (fun t buf n outp ->
         match T.read t (uchar_bigarray_view buf n) with
           Some n -> outp <-@ Unsigned.Size_t.of_int n; 0
         | None -> -1)

  let tls_write = I.internal "tls_write"
      (tls @-> ptr void @-> size_t @-> returning int)
      (fun t buf n -> T.write t (uchar_bigarray_view buf n))
end
