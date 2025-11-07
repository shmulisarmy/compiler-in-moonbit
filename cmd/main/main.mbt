enum TokenType {
  Number
  String
  Identifier
  Operator
  Keyword
  Invalid
  Punctuation
} derive(Show, Eq)

struct Token {
  type_ : TokenType
  value : StringView
}derive (Eq) 



fn Token::to_string(self : Token)->String{
  return "\{self.value}"
}


struct Tokenizer {
  source: String
  mut pos: Int
  len: Int
}
fn Tokenizer::next_non_space_char(self : Tokenizer) -> Char{
  while self.in_range() && self.cur_char() == ' ' {
    self.pos += 1
  }
  return self.cur_char()
}
fn Tokenizer::optionally_expect_char(self : Tokenizer, c : Char) -> Bool{
  self.skip_spaces()
  if self.in_range() && self.cur_char() == c {
    self.pos += 1
    return true
  }
  return false
}
fn Tokenizer::expect_char(self : Tokenizer, c : Char)->Unit{
  self.skip_spaces()
  if self.in_range() && self.cur_char() == c {
    self.pos += 1
    return
  }
  println("expecting \"\{c}\" but found \"\{self.cur_char()}\"")
  panic()
}
fn Tokenizer::in_range(self : Tokenizer) -> Bool{
  return self.pos < self.len
}


fn Tokenizer::cur_char(self : Tokenizer) -> Char{
  return self.source.get_char(self.pos).unwrap()
}

fn Tokenizer::skip_spaces(self : Tokenizer) -> Unit {
  while self.in_range() && self.cur_char() == ' ' {
    self.pos += 1
  }
}

let operatorChars = ['+', '-', '(', ')', '*', '/']
let punctuationChars = ['}', '{', '(', ')', '[', ']', ';', ':', ',']


fn Tokenizer::collect_while_in(self : Tokenizer, predicate : (Char) -> Bool) -> StringView {
  let start = self.pos
  while self.in_range() && predicate(self.cur_char()) {
    self.pos += 1
  }
  return try{ self.source.sub(start=start, end=self.pos)}catch{
    _ => {
      println("collect_while_in failed")
      panic()
    }
  }
}


fn string_view_to_int(view : StringView) -> Int {
  return match view.to_string() {
    "0" => 0
    "1" => 1
    "2" => 2
    "3" => 3
    "4" => 4
    "5" => 5
    "6" => 6
    "7" => 7
    "8" => 8
    "9" => 9
    "10" => 10
    "11" => 11
    "12" => 12
    "13" => 13
    "14" => 14
    "15" => 15
    "16" => 16
    "17" => 17
    "18" => 18
    "19" => 19
    "20" => 20
    "21" => 21
    "22" => 22
    "23" => 23
    "24" => 24
    "25" => 25
    "26" => 26
    "27" => 27
    "28" => 28    
    _ => {
      println("only do nunbers 0-28")
      panic()
    }
  }
}
///|
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
fn Tokenizer::next(self : Tokenizer) -> Token {
  self.skip_spaces()
  
  if self.cur_char() >= '0' && self.cur_char() <= '9' {
    return Token::{
      type_: TokenType::Number,
      value: self.collect_while_in(fn(c : Char) -> Bool {
        return c >= '0' && c <= '9'
      })
    }
  }
  if (self.cur_char() >= 'a' && self.cur_char() <= 'z') || (self.cur_char() >= 'A' && self.cur_char() <= 'Z') || self.cur_char() == '_' {
    return Token::{
      type_: TokenType::Identifier,
      value: self.collect_while_in(fn(c : Char) -> Bool {
        return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_'
      })
  }
  }
  if operatorChars.contains(self.cur_char()) {
    return Token::{
      type_: TokenType::Operator,
      value: self.collect_while_in(fn(c : Char) -> Bool {
        return operatorChars.contains(c)
      })
    }
  }
  if punctuationChars.contains(self.cur_char()) {
    return Token::{
      type_: TokenType::Punctuation,
      value: self.collect_while_in(fn(c : Char) -> Bool {
        return punctuationChars.contains(c)
      })
    }
  }
  if self.cur_char() == '"' {
    self.pos += 1
    let string_value = self.collect_while_in(fn(c : Char) -> Bool {
        return c != '"'
      })
    self.pos += 1
    return Token::{
      type_: TokenType::String,
      value: string_value
    }
  }
  println("dont know how to handle \"\{self.cur_char()}\"")
  panic()
}





struct Parser{
  tokenizer: Tokenizer
}


struct Operation{
  left : Expresssion
  right : Expresssion
  op : Token
} derive (Eq) 


// pub impl Show for Operation with to_string(self)->String{
//   return "(\{self.left} \{self.op} \{self.right})"
// }


fn Operation::to_string(self : Operation) -> String{
  return "(\{self.left.to_string()} \{self.op.to_string()} \{self.right.to_string()})"
}

// pub impl Show for Operation with output(self, logger: Logger)->Unit{
//   logger.println(self.to_string())
// }

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

struct FieldAccess{
  object : Expresssion
  field : StringView
} derive (Eq) 

fn FieldAccess::to_string(self : FieldAccess) -> String{
  return "\{self.object.to_string()}.\{self.field.to_string()}"
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

struct FunctionCall{
  name : String
  args : Array[Expresssion]
} derive (Eq) 

fn FunctionCall::to_string(self : FunctionCall) -> String{
  let args = self.args.map((arg) => arg.to_string()).join(", ")
  return "\{self.name}(\{args})"
}






let operater_precedence: Map[String, Int] = {
  "+" : 1,
  "-" : 1,
  "*" : 2,
  "/" : 2,
}

///|
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
    self.tokenizer.expect_char(',')
  }
  return expressions
}
fn Parser::var(self : Parser) -> Var {
  let name = self.tokenizer.collect_while_in(fn(c : Char) -> Bool {
    return c.is_ascii_alphabetic()
  })
  let type_ = if self.tokenizer.next_non_space_char().is_ascii_alphabetic() {
    Type::new(self.tokenizer.collect_while_in(fn(c : Char) -> Bool {
      return c.is_ascii_alphabetic()
    }).to_string())
  } else {
    Type::new("unknown")
  }
  let defualt_value = 
  if self.tokenizer.optionally_expect_char('=') {
    Some(self.expression(0))
  } else {
    None
  }
  return Var::{name: name.to_string(), type_: type_, defualt_value: defualt_value}
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


fn Parser::new(source : String) -> Parser {
  return Parser::{
    tokenizer: Tokenizer::{
      source: source,
      pos: 0,
      len: source.length()
    }
  }
}

struct Type {
  name : String
  subtypes : Option[Array[Type]]
} derive (Eq)
fn green(text: String) -> String {
    "\x1b[32m\{text}\x1b[0m".to_string()
}

fn Type::to_string(self : Type) -> String{
  if self.subtypes.is_some() {
    let subs_string = self.subtypes.unwrap().map(fn(subtype : Type) -> String {
      return subtype.to_string()
    }).join(", ")
    return green(self.name) + "<\{subs_string}>"
  }
  green(self.name)
}

fn Type::sub_type(self : Type, name : String) -> Type{
  if self.subtypes.is_empty() {
    println("there are no sub types of type \{self.name}")
    panic()
  }
  for subtype in self.subtypes.unwrap() {
    if subtype.name == name {
      return subtype
    }
  }
  println("type \"\{name}\" not found in \"\{self.name}\"")
  panic()
}
fn Type::can_hold(self : Type, other : Type) -> Bool{
  if self.name != other.name {
    return false
  }
  if self.subtypes.is_some() {
    for subtype in self.subtypes.unwrap() {
      if !subtype.can_hold(other) {
        return false
      }
    }
  }
  return true
}
/// types
fn Type::new(name : String) -> Type {
  return Type::{name: name, subtypes: None}
}
let int : Type = Type::new("Int")
let string : Type = Type::new("String")
let array : Type = Type::new("Array")
let function : Type = Type::new("Function")


/// 
/// compiler bit
/// 
struct Var{
  name : String
  mut type_ : Type
  defualt_value : Option[Expresssion]
}


struct Function{
  name : String
  params : Array[Var]
  return_type : Type
}
enum Symbol{
  Var(Var)
  Function(Function)
}


fn Symbol::get_name(self : Symbol) -> String{
  match self {
    Symbol::Var(var) => return var.name
    Symbol::Function(function) => return function.name
  }
}


struct Module{
  name : String
  symbols : Map[String, Symbol]
}



fn Module::validate_function_call_against_function_signiture(self : Module, function_call : FunctionCall, function_signature : Type) -> Unit{
  if function_call.args.length() != function_signature.sub_type("params").subtypes.unwrap().length() {
    let params = "params".to_string()
    println("function call \"\{function_call.name}\" has \{function_call.args.length()} arguments but \{function_signature.sub_type(params).subtypes.unwrap().length()} expected")
    panic()
  }
  for i, arg in function_signature.sub_type("params").subtypes.unwrap().iter2() {
    if !arg.can_hold(self.get_expression_type(function_call.args[i])) {
      println("function call \"\{function_call.name}\" has argument \"\{arg.name}\" of type \"\{arg.name}\" but \{self.get_expression_type(function_call.args[i]).name} expected")
      panic() 
    }
  }
}
fn Module::get_expression_type(self : Module, expression : Expresssion) -> Type{
  match expression {
    Expresssion::Operation(operation) => return self.get_expression_type(operation.left)
    Expresssion::FunctionCall(function_call) => return self.get_symbol_type(self.symbols[function_call.name]).subtypes.unwrap()[1]
    Expresssion::VarReference(var_reference) => return self.get_symbol_type(self.symbols[var_reference])
    Expresssion::FieldAccess(field_access) => return self.get_expression_type(field_access.object)
    Expresssion::Ast_Array(ast_array) => return array
    Expresssion::String(_) => return string
    Expresssion::Number(_) => return int
  }
}


fn Module::get_symbol_type(self : Module, symbol : Symbol) -> Type{
  match symbol {
    Symbol::Var(var) => {
      self.ensure_var_has_proper_type(var)
      return var.type_
    }
    Symbol::Function(function) => {
      // if function.return_type.name == "unknown" {
      //   println("function \"\{function.name}\" has an unknown return type")
      //   panic()
      // }
      let t =  Type::{
        name: "Function",
        subtypes: Some([Type::{name: "params", subtypes: Some(function.params.map((param) => {
          self.ensure_var_has_proper_type(param)
          return param.type_
        }))}, function.return_type])
      }
      println("got here")
      return t
    }
  }
}

///|
fn Module::ensure_var_has_proper_type(self : Module, var_ : Var) -> Unit {
  
  if var_.type_.name != "unknown" {
    match var_.defualt_value{
      Some(default_value) => {
        if !var_.type_.can_hold(self.get_expression_type(default_value)) {
          println("var type and defualt value mismatch")
          panic()
        }
      }
      _ => ()
    }
  } else if var_.defualt_value is Some(default_value) {
    var_.type_ = self.get_expression_type(default_value)
  } else {
    println("var \"\{var_.name}\" has an unknown type and no default value to infer a type")
    panic()
  }
}





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
  let expected = Expresssion::FieldAccess(FieldAccess::{object: Expresssion::VarReference("person1"), field: "name"})
  if !parser.expression(0).equal(expected) {
    println("expected \{expected.to_string()} but got \{parser.expression(0).to_string()}")
    panic()
  }
}

test "basic_type_checking" {
  let my_module = Module::{name: "main", symbols: {}}
  let expresssion = Parser::new("12").expression(0)
  if !my_module.get_expression_type(expresssion).equal(int) {
    println("12 should have inferred an Int type from the 2")
    panic()
  }
}


test "var_type_checking" {
  let my_module = Module::{name: "main", symbols: {}}
  let var_ =Parser::new("a Int = 2").var()
  my_module.ensure_var_has_proper_type(var_)
}

test "basic_type_inference" {
  let my_module = Module::{name: "main", symbols: {}}
  let var_ =Parser::new("a = 2").var()
  my_module.ensure_var_has_proper_type(var_)
  if !var_.type_.equal(int) {
    println("a should have inferred an Int type from the 2")
    panic()
  }
}


test "get symbol type from var reference"{
  let my_module = Module::{name: "main", symbols: {
    "a" : Symbol::Var(Parser::new("a Int = 2").var())
  }}
  let var_reference = Expresssion::VarReference("a")
  if !my_module.get_expression_type(var_reference).equal(int) {
    println("a should have inferred an Int type from the 2")
    panic()
  }
}


test "get symbol type from var reference with var type inference"{
  let my_module = Module::{name: "main", symbols: {
    "a" : Symbol::Var(Parser::new("a = 2").var())
  }}
  let var_reference = Expresssion::VarReference("a")
  if !my_module.get_expression_type(var_reference).equal(int) {
    println("a should have inferred an Int type from the 2")
    panic()
  }
}


test "function call that references real function"{
  let my_module = Module::{name: "main", symbols: {
    "add" : Symbol::Function(Function::{name: "add", params: [
      Var::{name: "a", type_: int, defualt_value: None},
      Var::{name: "b", type_: int, defualt_value: None}
    ], return_type: int})
  }}
  let add_func_sig = my_module.get_symbol_type(my_module.symbols["add"])
  
  let function_call = Parser::new("add(1, 2,)").expression(0)
  my_module.validate_function_call_against_function_signiture(match function_call{
    Expresssion::FunctionCall(function_call) => function_call
    _ => {
      println("function call expected")
      panic()
    }
  }, add_func_sig)
}




fn main{
  let parser = Parser::new("\"12\" + 4.get_len(a,a,) * add() + []")

  println(parser.expression(0).to_string())
}





