struct Module{
  name : String
  symbols : Map[String, Symbol]
}



fn Module::do_parenting(self : Module) -> Unit{
  for symbol in self.symbols.values() {
    match symbol {
      Symbol::Function(function) => {function.parent = Some(Scope::Module(self))
        function.do_parenting()
      }
      _ => ()
    }
  }
}