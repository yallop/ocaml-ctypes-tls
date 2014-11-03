(** Apply the Stubs functor to the generated bindings to link the generated
    code into the library. *)
include Tls_bindings.Stubs(Tls_dummy)(Tls_generated_bindings)
