struct Var{
  name : String
  mut type_ : Type
  defualt_value : Option[Expresssion]
}


struct Function{
  name : String
  params : Array[Var]
  return_type : Type
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