test "basic_type_checking" {
  let my_module = Module::{name: "main", symbols: {}}
  let expresssion = Parser::new("12").expression(0)
  if !my_module.get_expression_type(expresssion).equal(int) {
    println("12 should have inferred an Int type from the 2")
    panic()
  }
}


test "var_type_checking" {
  let my_module = Module::{name: "main", symbols: {}}
  let var_ =Parser::new("a Int = 2").var()
  my_module.ensure_var_has_proper_type(var_)
}

test "basic_type_inference" {
  let my_module = Module::{name: "main", symbols: {}}
  let var_ =Parser::new("a = 2").var()
  my_module.ensure_var_has_proper_type(var_)
  if !var_.type_.equal(int) {
    println("a should have inferred an Int type from the 2")
    panic()
  }
}