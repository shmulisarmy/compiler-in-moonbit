fn Parser::parse_file(self : Parser) -> Array[Symbol]{
  let symbols = []
  self.tokenizer.skip_lines()
  while self.tokenizer.in_range() { 
    let keyword = self.tokenizer.next()
    if !(keyword.type_ is TokenType::Keyword ){
      println("expected keyword but got \"\{keyword.value}\"")
      panic()
    }
    match keyword.value {
      "function" => symbols.push(Symbol::Function(self.function()))
      "var" => symbols.push(Symbol::Var(self.var()))
      _ => {
        println("expected keyword but got \"\{keyword.value}\"")
        panic()
      }
    }
    self.tokenizer.skip_lines()
  }
  return symbols
}




fn Module::from_files(files : Array[String]) -> Module{
  let module_ = Module::{name: "main", symbols: Map::new()}
  for file in files {
    let parser = Parser::new(file)
    for symbol in parser.parse_file() {
      module_.symbols[symbol.get_name()] = symbol
    }
  }
  return module_
}