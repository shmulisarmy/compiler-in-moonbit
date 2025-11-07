enum Scope{
    Module(Module)
    Function(Function)
}



fn Scope::validate_function_call_against_function_signiture(self : Scope, function_call : FunctionCall, function_signature : Type) -> Unit{
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


fn Scope::get_symbol(self : Scope, name : String) -> Symbol{
  match self {
    Scope::Module(module) => return module.symbols[name]
    Scope::Function(function) => {
      for statement in function.body.statements.rev_iter() {
        match statement {
          Statement::VarDeclaration(var_) => {
            if var_.name == name {
              return Symbol::Var(var_)
            }
          }
          _ => ()
        }
      }
      for param in function.params {
        if param.name == name {
          return Symbol::Var(param)
        }
      }
      println("symbol \"\{name}\" not found")
      panic()
    }
  }
}
fn Scope::get_expression_type(self : Scope, expression : Expresssion) -> Type{
  match expression {
    Expresssion::Operation(operation) => return self.get_expression_type(operation.left)
    Expresssion::FunctionCall(function_call) => return self.get_symbol_type(self.get_symbol(function_call.name)).subtypes.unwrap()[1]
    Expresssion::VarReference(var_reference) => return self.get_symbol_type(self.get_symbol(var_reference))
    Expresssion::FieldAccess(field_access) => return self.get_expression_type(field_access.object)
    Expresssion::Ast_Array(ast_array) => return array
    Expresssion::String(_) => return string
    Expresssion::Number(_) => return int
  }
}


fn Scope::get_symbol_type(self : Scope, symbol : Symbol) -> Type{
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
fn Scope::ensure_var_has_proper_type(self : Scope, var_ : Var) -> Unit {
  if var_.type_.name != "unknown" {
    match var_.defualt_value{
      Some(default_value) => {
        if !var_.type_.can_hold(self.get_expression_type(default_value)) {
          println("var \"\{var_.name}\" type \"\{var_.type_.name}\" and defualt value \"\{self.get_expression_type(default_value).name}\" mismatch")
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