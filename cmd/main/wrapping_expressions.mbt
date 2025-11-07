fn Parser::expression_list(
  self : Parser,
  opening_char : Char,
  closing_char : Char,
) -> Array[Expresssion] {
  let expressions = []
  self.tokenizer.expect_char(opening_char)
  while self.tokenizer.in_range() {
    if self.tokenizer.optionally_expect_char(closing_char) {
      break
    }
    expressions.push(self.expression(0))
    if !self.tokenizer.optionally_expect_char(',') {
      self.tokenizer.expect_char(closing_char)
      break
    }
  }
  return expressions
}


fn[T] Parser::custom_list(
  self : Parser,
  opening_char : Char,
  closing_char : Char,
  parser_func : (Parser) -> T,
) -> Array[T] {
  let expressions = []
  self.tokenizer.expect_char(opening_char)
  while self.tokenizer.in_range() {
    if self.tokenizer.optionally_expect_char(closing_char) {
      break
    }
    expressions.push(parser_func(self))
    if !self.tokenizer.optionally_expect_char(',') {
      self.tokenizer.expect_char(closing_char)
      break
    }
  }
  return expressions
}


fn Parser::wrapped_term(self : Parser) -> Expresssion {
  let mut expr = self.term()
  while self.tokenizer.in_range()  {
    let mut changed_since_last_time = false
    if self.tokenizer.next_non_space_char() == '(' {
      expr = Expresssion::FunctionCall(FunctionCall::{name: expr.to_string(), args: self.expression_list('(', ')')})
      changed_since_last_time = true
    }
    if self.tokenizer.optionally_expect_char('.') {
      let field = self.tokenizer.next().value
      expr = Expresssion::FieldAccess(FieldAccess::{object: expr, field: field})
      changed_since_last_time = true
    }
    if !changed_since_last_time{
      break
    }
  }
  return expr
}



struct FieldAccess{
  object : Expresssion
  field : StringView
} derive (Eq) 

fn FieldAccess::to_string(self : FieldAccess) -> String{
  return "\{self.object.to_string()}.\{self.field.to_string()}"
}


struct FunctionCall{
  name : String
  args : Array[Expresssion]
} derive (Eq) 

fn FunctionCall::to_string(self : FunctionCall) -> String{
  let args = self.args.map((arg) => arg.to_string()).join(", ")
  return "\{self.name}(\{args})"
}