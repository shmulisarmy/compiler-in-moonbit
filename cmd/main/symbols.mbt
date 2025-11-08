struct Var{
  name : String
  mut type_ : Type
  default_value : Option[Expression]
}

fn Var::to_string(self : Var) -> String{
  match self.default_value {
    Some(default_value) => return "\{yellow(self.name)}: \{self.type_.to_string()} = \{default_value.to_string()}"
    None => return "\{yellow(self.name)}: \{self.type_.to_string()}"
  }
}





struct Function{
  name : String
  params : Array[Var]
  body : Block
  mut return_type : Type //mut is for when we infer it
  mut parent : Option[Scope]
}




fn Function::to_string(self : Function) -> String{
  let params = self.params.map(fn(param : Var) -> String {
    return param.name
  }).join(", ")
  let body = "{\n"+ self.body.statements.map(fn(statement : Statement) -> String {
    return "     "+statement.to_string(0)
  }).join("\n")+"\n"+"}"
  return "\{yellow(self.name)}(\{params})[]\{self.return_type.to_string()}\{body}"
}
enum Symbol{
  Var(Var)
  Function(Function)
  Class(Class)
}




fn Function::do_parenting(self : Function) -> Unit{
  for statement in self.body.statements {
    match statement {
      Statement::Block(block) => {
        block.parent = Some(Scope::Function(self))
        block.do_parenting()
      }
      _ => ()
    }
  }
}


fn Symbol::get_name(self : Symbol) -> String{
  match self {
    Symbol::Var(var) => return var.name
    Symbol::Function(function) => return function.name
    Symbol::Class(class_) => return class_.name
  }
}