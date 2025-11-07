struct Assign{
  reciever: Expresssion
  value: Expresssion
}
enum Statement{
  FunctionCall(FunctionCall)
  VarDeclaration(Var)
  Assign(Assign)
  Return(Option[Expresssion])
}


fn Statement::to_string(self : Statement) -> String{
  match self {
    Statement::FunctionCall(function_call) => return function_call.to_string()
    Statement::VarDeclaration(var_) => return var_.to_string()
    Statement::Assign(assign) => return "\{assign.reciever.to_string()} = \{assign.value.to_string()}"
    Statement::Return(return_) => return match return_ {
      Some(return_) => "return \{return_.to_string()}"
      None => "return".to_string()
    }
  }
}





fn Parser::statement(self : Parser) -> Statement{
  match self.tokenizer.optionaly_expect_token_type(TokenType::Keyword) {
    (true, "var") => return Statement::VarDeclaration(self.var())
    (true, "return") => return Statement::Return(Some(self.expression(0)))
    _ => ()
  }

  let expr = self.expression(0)
  if self.tokenizer.optionally_expect_char('=') {
    return Statement::Assign(Assign::{reciever: expr, value: self.expression(0)})
  }
  match expr{
    Expresssion::FunctionCall(function_call) => return Statement::FunctionCall(function_call)
    _ => {
      println("function call's are the only expressions valid as statements")
      panic()
    }
  }
}
fn Parser::block(self : Parser) -> Block{
  let block = Block::{statements: []}
  self.tokenizer.expect_char('{')
  self.tokenizer.skip_lines()
  while self.tokenizer.in_range() && !self.tokenizer.optionally_expect_char('}') {
    block.statements.push(self.statement())
    self.tokenizer.skip_lines() 
    
  }
  return block
}
struct Block{
  statements : Array[Statement]
}