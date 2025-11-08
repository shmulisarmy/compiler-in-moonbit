struct Assign{
  receiver: Expression
  value: Expression
}
enum Statement{
  FunctionCall(FunctionCall)
  VarDeclaration(Var)
  Assign(Assign)
  Return(Option[Expression])
  Block(Block)
}


fn Statement::to_string(self : Statement, depth: Int) -> String{
  match self {
    Statement::FunctionCall(function_call) => return function_call.to_string()
    Statement::VarDeclaration(var_) => return var_.to_string()
    Statement::Assign(assign) => return "\{assign.receiver.to_string()} = \{assign.value.to_string()}"
    Statement::Return(return_) => return match return_ {
      Some(return_) => "return \{return_.to_string()}"
      None => "return".to_string()
    }
    Statement::Block(block) => return block.to_string(depth)
  }
}





fn Parser::statement(self : Parser) -> Statement{
  match self.tokenizer.optionally_expect_token_type(TokenType::Keyword) {
    (true, "var") => return Statement::VarDeclaration(self.var())
    (true, "return") => return Statement::Return(Some(self.expression(0)))
    (true, "if") => return Statement::Block(Block::{parent: None, name: Some("if"), head: Some(self.expression(0)), statements: self.block_statements()})
    (true, "while") => return Statement::Block(Block::{parent: None, name: Some("while"), head: Some(self.expression(0)), statements: self.block_statements()})
    _ => ()
  }

  let expr = self.expression(0)
  if self.tokenizer.optionally_expect_char('=') {
    return Statement::Assign(Assign::{receiver: expr, value: self.expression(0)})
  }
  match expr{
    Expression::FunctionCall(function_call) => return Statement::FunctionCall(function_call)
    _ => {
      println("function call's are the only expressions valid as statements")
      panic()
    }
  }
}
fn Parser::block_statements(self : Parser) -> Array[Statement]{
  let statements = []
  self.tokenizer.expect_char('{')
  self.tokenizer.skip_lines()
  while self.tokenizer.in_range() && !self.tokenizer.optionally_expect_char('}') {
    statements.push(self.statement())
    self.tokenizer.skip_lines() 
    
  }
  return statements
}
struct Block{
  statements : Array[Statement]
  mut parent : Option[Scope]
  //these are for conditional blocks
  name: Option[String]
  head: Option[Expression]
}


fn Block::is_conditional(self : Block) -> Bool{
  if self.name is Some(name) {
    if self.head is None{
      println("conditional block \"\{name}\" has no head expression")
      panic()
    }
    return true
  }
  return false
}


fn Block::to_string(self : Block, previous_depth: Int) -> String{
  let depth: Int = previous_depth+1
  let indent = "    ".repeat(depth)
  let statements = indent+ self.statements.map(fn(statement : Statement) -> String {
    return statement.to_string(depth)
  }).join("\n"+indent)
  if self.is_conditional() {
    return "\{self.name.unwrap()} \{self.head.unwrap().to_string()}\n\{statements}\n"
  }
  return "\{statements}"
}


fn Block::do_parenting(self : Block) -> Unit{
  for statement in self.statements {
    match statement {
      Statement::Block(block) => {
        block.parent = Some(Block(self))
        block.do_parenting()
      }
      _ => ()
    }
  }
}