enum Scope{
    Module(Module)
    Function(Function)
    Block(Block)
}



fn Scope::validate_function_call_against_function_signature(self : Scope, function_call : FunctionCall, function_signature : Type) -> Unit{
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




fn Block::get_symbol(self : Block, name : String) -> Symbol{
  let local_sym = self.get_local_symbol(name)
  if local_sym is Some(local_sym){
    return local_sym
  }
  if self.parent is None{
    println("block has no parent")
    panic()
  }
  return self.parent.unwrap().get_symbol(name)
}

fn Block::get_local_symbol(self : Block, name : String) -> Option[Symbol]{
  for statement in self.statements.rev_iter() {
      match statement {
        Statement::VarDeclaration(var_) => {
          if var_.name == name {
            return Some(Symbol::Var(var_))
          }
        }
        _ => ()
      }
    }
    return None
}

fn Function::get_local_symbol(self : Function, name : String) -> Option[Symbol]{
  for statement in self.body.statements.rev_iter() {
        match statement {
          Statement::VarDeclaration(var_) => {
            if var_.name == name {
              return Some(Symbol::Var(var_))
            }
          }
          _ => ()
        }
      }
      for param in self.params {
        if param.name == name {
          return Some(Symbol::Var(param))
        }
      }
      return None
}
fn Scope::find_symbol_type(self : Scope, name : String) -> Type{
  match self{
    Scope::Block(block) => return block.find_symbol_type(name)
    Scope::Function(function) => {
      if  function.get_local_symbol(name) is Some(local_sym){
        return Scope::Function(function).get_symbol_type(local_sym)
      }
      if function.parent is None{
        println("function has no parent")
        panic()
      }
      return function.parent.unwrap().find_symbol_type(name)
    }
    Scope::Module(module_) => {
      let symbol = module_.get_local_symbol(name)
      if symbol is Some(symbol){
        return Scope::Module(module_).get_symbol_type(symbol)
      }
      println("symbol \"\{name}\" not found in module \"\{module_.name}\"")
      panic()
    }
  }
}
fn Block::find_symbol_type(self : Block, name : String) -> Type{
  let local_symbol = self.get_local_symbol(name)
  if local_symbol is Some(local_symbol){
    return Scope::Block(self).get_symbol_type(local_symbol)
  }
  //
  if self.parent is None{
    println("block has no parent")
    panic()
  }
  return self.parent.unwrap().find_symbol_type(name)
}


fn Module::get_local_symbol(self : Module, name : String) -> Option[Symbol]{
  //its returned as an option to fit into the scope interface 
  if self.symbols.contains(name){
    return Some(self.symbols[name])
  }
  println("symbol \"\{name}\" not found in module \"\{self.name}\"")
  panic()
}
fn Scope::get_symbol(self : Scope, name : String) -> Symbol{
  match self {
    Scope::Module(module_) => return module_.get_local_symbol(name).unwrap()
    Scope::Function(function) => {
      if  function.get_local_symbol(name) is Some(local_sym){
        return local_sym
      }
      return function.parent.unwrap().get_symbol(name)
    } 
    Scope::Block(block) => return block.get_symbol(name)
  }
}


fn Scope::get_expression_type(self : Scope, expression : Expression) -> Type{
  match expression {
    Expression::Operation(operation) => return self.get_expression_type(operation.left)
    Expression::FunctionCall(function_call) => return self.find_symbol_type(function_call.name)
    Expression::VarReference(var_reference) => return self.find_symbol_type(var_reference)
    Expression::FieldAccess(field_access) => return {
      let class_name = self.get_expression_type(field_access.object).name
      let class_ = self.get_symbol(class_name)
      if class_ is Class(class_){
        let field = class_.dot(field_access.field.to_string())
        match field {
          Some(field) => {
            return match field{
              Symbol::Var(var_) => var_.type_
              Symbol::Function(function_) => function_.return_type
              _ => {
                println("there shouldnt be a symbol other than var or function that you can get from a field access on a class")
                panic()
              }
            }
          }
          None => {
            println("field \"\{field_access.field}\" not found in class \"\{class_name}\"")
            panic()
          }
        }
      }
      println("symbol \"\{class_name}\" is not a class")
      panic()
    }
    Expression::Ast_Array(ast_array) => return array
    Expression::String(_) => return string
    Expression::Number(_) => return int
  }
}


fn Scope::get_symbol_type(self : Scope, symbol : Symbol) -> Type{
  match symbol {
    Symbol::Var(var_) => {
      self.ensure_var_has_proper_type(var_)
      return var_.type_
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
      return t
    }
    Symbol::Class(class_) => {
      return Type::new("class")
    }
  }
}

///|
fn Scope::ensure_var_has_proper_type(self : Scope, var_ : Var) -> Unit {
  if var_.type_.name != "unknown" {
    match var_.default_value{
      Some(default_value) => {
        if !var_.type_.can_hold(self.get_expression_type(default_value)) {
          println("var \"\{var_.name}\" type \"\{var_.type_.name}\" and default value \"\{self.get_expression_type(default_value).name}\" mismatch")
          panic()
        }
      }
      _ => ()
    }
  } else if var_.default_value is Some(default_value) {
    var_.type_ = self.get_expression_type(default_value)
  } else {
    println("var \"\{var_.name}\" has an unknown type and no default value to infer a type")
    panic()
  }
}