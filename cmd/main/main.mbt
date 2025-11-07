


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









struct Parser{
  tokenizer: Tokenizer
}

fn Parser::identifier(self: Parser) -> StringView{
  self.tokenizer.skip_spaces()
  return self.tokenizer.collect_while_in(fn(c : Char) -> Bool {
    return c.is_ascii_alphabetic()
  })
} 

fn Parser::type_(self: Parser) -> Type{
  if self.tokenizer.optionally_expect_char('[') {
    self.tokenizer.expect_char(']')
    return Type::{name: "Array", subtypes: Some([self.type_()])}
  }
  let t = Type::new(self.identifier().to_string())
  if self.tokenizer.next_non_space_char() == '<' {
    t.subtypes = Some(self.custom_list('<', '>', fn(parser : Parser) -> Type {
      return parser.type_()
    }))
  }
  return t
} 

fn Parser::looks_like_type(self: Parser) -> Bool{
  self.tokenizer.skip_spaces()
  return self.tokenizer.next_non_space_char().is_ascii_alphabetic() || self.tokenizer.next_non_space_char() == '['
}
fn Parser::function(self: Parser) -> Function{
  let name = self.identifier()
  let params = self.custom_list('(', ')', fn(parser : Parser) -> Var {
    return parser.var()
  })
  println("this point")
  let return_type = match self.looks_like_type() {
    true => self.type_()
    false => Type::new("unknown")
  }
  return Function::{name: name.to_string(), params, return_type}
} 

















///|

fn Parser::var(self : Parser) -> Var {
  let name = self.identifier()
  let type_ = if self.tokenizer.next_non_space_char().is_ascii_alphabetic() {
    Type::new(self.identifier().to_string())
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
  mut subtypes : Option[Array[Type]]
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












fn main{
  let parser = Parser::new("add(a Int, b Int)[]Person<Int> ")
  println(parser.function().to_string())
}





