
struct Operation{
  left : Expression
  right : Expression
  op : Token
} derive (Eq) 



fn Operation::to_string(self : Operation) -> String{
  return "(\{self.left.to_string()} \{self.op.to_string()} \{self.right.to_string()})"
}






let operator_precedence: Map[String, Int] = {
  "+" : 1,
  "-" : 1,
  "*" : 2,
  "/" : 2,
  "<" : 3,
  ">" : 3,
}

fn Parser::expression(self : Parser, left_pull: Int, okay_to_parse_object? : Bool=true) -> Expression {
    let mut left: Expression = self.wrapped_term(okay_to_parse_object~)
    while self.tokenizer.in_range() {
      let prev = self.tokenizer.pos
      let token = self.tokenizer.next()
      match token.type_ {
        TokenType::Operator => {
          if left_pull >= operator_precedence[token.value.to_string()] {
            self.tokenizer.pos = prev
            return left
          }
          let op = token
          let right = self.expression(operator_precedence[token.value.to_string()], okay_to_parse_object~)
          left = Expression::Operation(Operation::{left: left, right: right, op: op})
        }
        _ => {
          self.tokenizer.pos = prev
          return left
        }
      }
    }
    return left
}