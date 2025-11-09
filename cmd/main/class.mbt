struct Class{
  name : String
  parent : Option[Module]
  fields : Array[Var]
  methods : Array[Function]
  mut auto_cast_types : Array[String]
}


fn Class::dot(self : Class, name : String) -> Option[Symbol]{
  for field in self.fields {
    if field.name == name {
      return Some(Symbol::Var(field))
    }
  }
  for function in self.methods {
    if function.name == name {
      return Some(Symbol::Function(function))
    }
  }
  return None
}