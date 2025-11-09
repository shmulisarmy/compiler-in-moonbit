fn Block::collect_all_return_types(self: Block, collection: Array[Type])->Unit{
  for statement in self.statements{
    match statement{
      Return(r) => {
        if r is Some(r) {
          collection.push(Scope::Block(self).get_expression_type(r))
        }
      }
      Block(block) => {
        block.collect_all_return_types(collection)
      }
    _ => ()
    }
  }
}


fn Block::first_return_type(self: Block)->Option[Type]{
  for statement in self.statements{
    match statement{
      Return(r) => {  
        if r is Some(r) {
          return Some(Scope::Block(self).get_expression_type(r))
        }
      }
      Block(block) => {
        return block.first_return_type()
      }
    _ => ()
    }
  }
  return None
}




fn Function::infer_return_type(self: Function)->Unit{
  let first_return_type = self.body.first_return_type()
  if first_return_type is Some(first_return_type){
    self.return_type = first_return_type
  } else {
    self.return_type = Type::new("none")
  }
}



fn Function::ensure_var_has_proper_return_type(self: Function)->Unit{
  if self.return_type.name == "none" {
    return
  }
  let all_return_types = []
  self.body.collect_all_return_types(all_return_types)
  if all_return_types.length() == 0 {
    println("function \"\{self.name}\" has a return type \{self.return_type.to_string()} but no return statements")
    panic()
  }
  for return_type_ in all_return_types.iter() {
    match Scope::Function(self).get_type_compliance(self.return_type, return_type_) {
      TypeCompliance::SameType => ()
      TypeCompliance::AutoCastable => ()
      TypeCompliance::DynamicCopyOnly => ()
      _ => {
        println("function \"\{self.name}\" has a return type \{self.return_type.to_string()} but returns \{return_type_.to_string()}")
        panic()
      }
    }
  }
}


