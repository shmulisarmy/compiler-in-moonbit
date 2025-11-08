fn Parser::class(self : Parser) -> Class{
  let c = Class::{name: self.tokenizer.identifier().to_string(), parent: None, fields: [], methods: []}
  self.tokenizer.expect_char('{')
  self.tokenizer.skip_lines()
  while !self.tokenizer.optionally_expect_char('}') {
    let two_down = self.tokenizer.peek(2)
    if two_down.value.has_prefix("(") {
      c.methods.push(self.function())
    } else {
      c.fields.push(self.var())
    }
    self.tokenizer.skip_lines()
  }
  return c
}



test "parse class"{
  let parser = Parser::new(
    (#|Test {
    #|  x Int = 0
    #|  test() {
    #|  }
    #|}
    #|
    )
    )
  let class_ = parser.class()
  assert_eq(class_.name, "Test")
  assert_eq(class_.fields.length(), 1)
  assert_eq(class_.methods.length(), 1)
}