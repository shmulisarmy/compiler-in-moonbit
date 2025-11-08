enum Expression{
  Number(Int)
  Operation(Operation)
  FunctionCall(FunctionCall)
  VarReference(String)
  FieldAccess(FieldAccess)
  Ast_Array(Ast_Array)
  String(String)
  Object(Object)
} derive (Eq) 


struct Ast_Array{
  elements : Array[Expression]
} derive (Eq) 


fn Ast_Array::to_string(self : Ast_Array) -> String{
  return "[\{self.elements.map((e) => e.to_string())}]"
}


fn Expression::to_string(self : Expression) -> String{
  match self {
    Expression::Number(number) => return number.to_string()
    Expression::Operation(operation) => return operation.to_string()
    Expression::FunctionCall(function_call) => return function_call.to_string()
    Expression::VarReference(var_reference) => return var_reference.to_string()
    Expression::FieldAccess(field_access) => return field_access.to_string()
    Expression::Ast_Array(ast_array) => return ast_array.to_string()
    Expression::String(string) => return "\"\{string}\""
    Expression::Object(object) => return object.to_string()
  }
}



fn Parser::term(self : Parser) -> Expression {
  if self.tokenizer.next_non_space_char() == '[' {
    return Expression::Ast_Array(Ast_Array::{
      elements: self.expression_list('[' ,']'),
    })
  }
  if self.tokenizer.next_non_space_char() == '(' {
    let e = self.expression_list('(', ')')
    return e[0]
  }
  let token = self.tokenizer.next()
  match token.type_ {
    TokenType::Number => return Expression::Number(string_view_to_int(token.value))
    TokenType::Identifier => return Expression::VarReference(token.value.to_string())
    TokenType::String => return Expression::String(token.value.to_string())
    _ => {
      println("don't know how to handle \"\{token.type_} of \"\{token.value}\"")
      panic()
    }
  }
}