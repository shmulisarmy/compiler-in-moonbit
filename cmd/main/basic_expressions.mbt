enum Expresssion{
  Number(Int)
  Operation(Operation)
  FunctionCall(FunctionCall)
  VarReference(String)
  FieldAccess(FieldAccess)
  Ast_Array(Ast_Array)
  String(String)
} derive (Eq) 


struct Ast_Array{
  elements : Array[Expresssion]
} derive (Eq) 


fn Ast_Array::to_string(self : Ast_Array) -> String{
  return "[\{self.elements.map((e) => e.to_string())}]"
}


fn Expresssion::to_string(self : Expresssion) -> String{
  match self {
    Expresssion::Number(number) => return number.to_string()
    Expresssion::Operation(operation) => return operation.to_string()
    Expresssion::FunctionCall(function_call) => return function_call.to_string()
    Expresssion::VarReference(var_reference) => return var_reference.to_string()
    Expresssion::FieldAccess(field_access) => return field_access.to_string()
    Expresssion::Ast_Array(ast_array) => return ast_array.to_string()
    Expresssion::String(string) => return "\"\{string}\""
  }
}



fn Parser::term(self : Parser) -> Expresssion {
  if self.tokenizer.next_non_space_char() == '[' {
    return Expresssion::Ast_Array(Ast_Array::{
      elements: self.expression_list('[' ,']'),
    })
  }
  if self.tokenizer.next_non_space_char() == '(' {
    let e = self.expression_list('(', ')')
    return e[0]
  }
  let token = self.tokenizer.next()
  match token.type_ {
    TokenType::Number => return Expresssion::Number(string_view_to_int(token.value))
    TokenType::Identifier => return Expresssion::VarReference(token.value.to_string())
    TokenType::String => return Expresssion::String(token.value.to_string())
    _ => {
      println("dont know how to handle \"\{token.type_} of \"\{token.value}\"")
      panic()
    }
  }
}