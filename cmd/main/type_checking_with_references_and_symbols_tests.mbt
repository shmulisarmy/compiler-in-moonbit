


test "get symbol type from var reference"{
  let my_module = Module::{name: "main", symbols: {
    "a" : Symbol::Var(Parser::new("a Int = 2").var())
  }}
  let var_reference = Expresssion::VarReference("a")
  if !my_module.get_expression_type(var_reference).equal(int) {
    println("a should have inferred an Int type from the 2")
    panic()
  }
}


test "get symbol type from var reference with var type inference"{
  let my_module = Module::{name: "main", symbols: {
    "a" : Symbol::Var(Parser::new("a = 2").var())
  }}
  let var_reference = Expresssion::VarReference("a")
  if !my_module.get_expression_type(var_reference).equal(int) {
    println("a should have inferred an Int type from the 2")
    panic()
  }
}


test "function call that references real function"{
  let my_module = Module::{name: "main", symbols: {
    "add" : Symbol::Function(Function::{name: "add", params: [
      Var::{name: "a", type_: int, defualt_value: None},
      Var::{name: "b", type_: int, defualt_value: None}
    ], return_type: int})
  }}
  let add_func_sig = my_module.get_symbol_type(my_module.symbols["add"])
  
  let function_call = Parser::new("add(1, 2,)").expression(0)
  my_module.validate_function_call_against_function_signiture(match function_call{
    Expresssion::FunctionCall(function_call) => function_call
    _ => {
      println("function call expected")
      panic()
    }
  }, add_func_sig)
}
