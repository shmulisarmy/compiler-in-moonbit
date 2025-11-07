enum TokenType {
  Number
  String
  Identifier
  Operator
  Keyword
  Invalid
  Punctuation
  Assign
  NewLine
} derive(Show, Eq)

struct Token {
  type_ : TokenType
  value : StringView
}derive (Eq) 



let keywords = ["return", "var", "func", "if", "else", "while", "for", "break", "continue", "null"]
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
  if ! self.in_range(){
    return ' '
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
  if !self.in_range(){
    return ' '
  }
  return self.source.get_char(self.pos).unwrap()
}

fn Tokenizer::skip_spaces(self : Tokenizer) -> Unit {
  while self.in_range() && (self.cur_char() == ' ' || self.cur_char() == '\t') {
    self.pos += 1
  }
}

fn Tokenizer::skip_lines(self : Tokenizer) -> Unit {
  while self.in_range() && (self.cur_char() == '\n' || self.cur_char() == '\r' || self.cur_char() == ' ' || self.cur_char() == '\t' || self.cur_char() == '\f') {
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


fn Tokenizer::optionally_expect_token_type(self : Tokenizer, token_type : TokenType) -> (Bool, StringView) {
  let before_pos = self.pos
  let token = self.next()
  if token.type_ != token_type {
    self.pos = before_pos
    return (false, token.value)
  }
  return (true, token.value)
}



fn Tokenizer::expect_token_type(self : Tokenizer, token_type : TokenType) -> StringView {
  let token = self.next()
  if token.type_ != token_type {
    println("expecting \"\{token_type}\" but found \"\{token.value}\"")
    panic()
  }
  return token.value
}



fn Tokenizer::next(self : Tokenizer) -> Token {
  self.skip_spaces()
  
  if self.cur_char().is_ascii_digit() {
    return Token::{
      type_: TokenType::Number,
      value: self.collect_while_in(fn(c : Char) -> Bool {
        return c.is_ascii_digit()
      })
    }
  }
  if self.cur_char().is_ascii_alphabetic() || self.cur_char() == '_' {
    let ident = self.identifier()
    if keywords.contains(ident.to_string()) {
      return Token::{
        type_: TokenType::Keyword,
        value: ident
      }
    }
    return Token::{
      type_: TokenType::Identifier,
      value: ident
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
  if self.cur_char() == '=' {
    self.pos += 1
    return Token::{
      type_: TokenType::Assign,
      value: "="
    }
  }
  if self.cur_char() == '\n' {
    self.pos += 1
    return Token::{
      type_: TokenType::NewLine,
      value: "\n"
    }
  }
  println("don't know how to handle \"\{self.cur_char()}\"")
  panic()
}