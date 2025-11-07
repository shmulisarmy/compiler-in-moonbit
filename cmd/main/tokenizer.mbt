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