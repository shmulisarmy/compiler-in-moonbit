
test "operator precedence" {
  let parser = Parser::new("12 + 4 * 9")
  assert_eq(parser.expression(0).to_string(), "(12 + (4 * 9))")
  //
  let parser = Parser::new("person1.name")
  assert_eq(parser.expression(0).to_string(), "person1.name")
  //
  
}



test {
  let parser = Parser::new("person1.name")
  let expected = Expresssion::FieldAccess(FieldAccess::{object: Expresssion::VarReference("person1"), field: "name"})
  if !parser.expression(0).equal(expected) {
    println("expected \{expected.to_string()} but got \{parser.expression(0).to_string()}")
    panic()
  }
}