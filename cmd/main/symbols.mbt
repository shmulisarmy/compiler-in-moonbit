struct Var{
  name : String
  mut type_ : Type
  defualt_value : Option[Expresssion]
}

fn Var::to_string(self : Var) -> String{
  match self.defualt_value {
    Some(defualt_value) => return "\{self.name}: \{self.type_.to_string()} = \{defualt_value.to_string()}"
    None => return "\{self.name}: \{self.type_.to_string()}"
  }
}


struct Function{
  name : String
  params : Array[Var]
  return_type : Type
}




fn Function::to_string(self : Function) -> String{
  let params = self.params.map(fn(param : Var) -> String {
    return param.name
  }).join(", ")
  return "\{self.name}(\{params})[]\{self.return_type.to_string()}"
}
enum Symbol{
  Var(Var)
  Function(Function)
}


fn Symbol::get_name(self : Symbol) -> String{
  match self {
    Symbol::Var(var) => return var.name
    Symbol::Function(function) => return function.name
  }
}