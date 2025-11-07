
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
  let expected = Expression::FieldAccess(FieldAccess::{object: Expression::VarReference("person1"), field: "name"})
  let actual = parser.expression(0)
  if !actual.equal(expected) {
    println("expected \{expected.to_string()} but got \{actual.to_string()}")
    panic()
  }
}