struct Module{
  name : String
  symbols : Map[String, Symbol]
}



fn Module::validate_function_call_against_function_signiture(self : Module, function_call : FunctionCall, function_signature : Type) -> Unit{
  if function_call.args.length() != function_signature.sub_type("params").subtypes.unwrap().length() {
    let params = "params".to_string()
    println("function call \"\{function_call.name}\" has \{function_call.args.length()} arguments but \{function_signature.sub_type(params).subtypes.unwrap().length()} expected")
    panic()
  }
  for i, arg in function_signature.sub_type("params").subtypes.unwrap().iter2() {
    if !arg.can_hold(self.get_expression_type(function_call.args[i])) {
      println("function call \"\{function_call.name}\" has argument \"\{arg.name}\" of type \"\{arg.name}\" but \{self.get_expression_type(function_call.args[i]).name} expected")
      panic() 
    }
  }
}
fn Module::get_expression_type(self : Module, expression : Expresssion) -> Type{
  match expression {
    Expresssion::Operation(operation) => return self.get_expression_type(operation.left)
    Expresssion::FunctionCall(function_call) => return self.get_symbol_type(self.symbols[function_call.name]).subtypes.unwrap()[1]
    Expresssion::VarReference(var_reference) => return self.get_symbol_type(self.symbols[var_reference])
    Expresssion::FieldAccess(field_access) => return self.get_expression_type(field_access.object)
    Expresssion::Ast_Array(ast_array) => return array
    Expresssion::String(_) => return string
    Expresssion::Number(_) => return int
  }
}


fn Module::get_symbol_type(self : Module, symbol : Symbol) -> Type{
  match symbol {
    Symbol::Var(var) => {
      self.ensure_var_has_proper_type(var)
      return var.type_
    }
    Symbol::Function(function) => {
      // if function.return_type.name == "unknown" {
      //   println("function \"\{function.name}\" has an unknown return type")
      //   panic()
      // }
      let t =  Type::{
        name: "Function",
        subtypes: Some([Type::{name: "params", subtypes: Some(function.params.map((param) => {
          self.ensure_var_has_proper_type(param)
          return param.type_
        }))}, function.return_type])
      }
      println("got here")
      return t
    }
  }
}

///|
fn Module::ensure_var_has_proper_type(self : Module, var_ : Var) -> Unit {
  
  if var_.type_.name != "unknown" {
    match var_.defualt_value{
      Some(default_value) => {
        if !var_.type_.can_hold(self.get_expression_type(default_value)) {
          println("var type and defualt value mismatch")
          panic()
        }
      }
      _ => ()
    }
  } else if var_.defualt_value is Some(default_value) {
    var_.type_ = self.get_expression_type(default_value)
  } else {
    println("var \"\{var_.name}\" has an unknown type and no default value to infer a type")
    panic()
  }
}