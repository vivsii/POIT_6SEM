(module
  (type (;0;) (func (param i32 i32) (result i32)))
  (type (;1;) (func))
  (func (;0;) (type 1)
    nop)
  (func (;1;) (type 0) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.add)
  (func (;2;) (type 0) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.mul)
  (func (;3;) (type 0) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.sub)
  (export "__wasm_call_ctors" (func 0))
  (export "sum" (func 1))
  (export "mul" (func 2))
  (export "sub" (func 3)))
