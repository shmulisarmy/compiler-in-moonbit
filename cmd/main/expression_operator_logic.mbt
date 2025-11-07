
struct Operation{
  left : Expresssion
  right : Expresssion
  op : Token
} derive (Eq) 



fn Operation::to_string(self : Operation) -> String{
  return "(\{self.left.to_string()} \{self.op.to_string()} \{self.right.to_string()})"
}






let operater_precedence: Map[String, Int] = {
  "+" : 1,
  "-" : 1,
  "*" : 2,
  "/" : 2,
}

fn Parser::expression(self : Parser, left_pull: Int) -> Expresssion {
    let mut left: Expresssion = self.wrapped_term()
    while self.tokenizer.in_range() {
      let prev = self.tokenizer.pos
      let token = self.tokenizer.next()
      match token.type_ {
        TokenType::Operator => {
          if left_pull >= operater_precedence[token.value.to_string()] {
            self.tokenizer.pos = prev
            return left
          }
          let op = token
          let right = self.expression(operater_precedence[token.value.to_string()])
          left = Expresssion::Operation(Operation::{left: left, right: right, op: op})
        }
        _ => {
          self.tokenizer.pos = prev
          return left
        }
      }
    }
    return left
}