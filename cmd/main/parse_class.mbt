fn Parser::class(self : Parser) -> Class{
  let c = Class::{name: self.tokenizer.identifier().to_string(), parent: None, fields: [], methods: [], auto_cast_types: []}
  self.tokenizer.expect_char('{')
  self.tokenizer.skip_lines()
  while !self.tokenizer.optionally_expect_char('}') {
    let two_down = self.tokenizer.peek(2)
    if two_down.value.has_prefix("(") {
      c.methods.push(self.function())
    } else {
      if self.tokenizer.next_non_space_char() == 'a' && self.tokenizer.peek(1).value == "auto_cast" {
        let _ = self.tokenizer.identifier()
        c.auto_cast_types = self.custom_list('[' , ']', fn(parser : Parser) -> String {
          return parser.tokenizer.identifier().to_string()
        })
      }
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