test "valid referencing of var statement to type inferred param" {
    let parser = Parser::new("add(a = 0, b Int)Int {\nvar c Int = a}")
    let function = parser.function()
    function.type_check_vars()
} 


test "valid referencing of var statement to another var statement" {
  // c gets its type inferred from a and d then checks against c to see if its type matches as its assigning to it
  let parser = Parser::new("add(a = 0, b Int)Int {\nvar c = a\nvar d Int = c}")
  let function = parser.function()
  function.type_check_vars()
} 

test "valid assignment types" {
  //i tested to make sure that it fails if there was a line a = "2"
  let parser = Parser::new("add()Int {\nvar a Int = 1\na = 2}")
  let function = parser.function() 
  function.type_check_vars()
} 



test "auto cast"{
  //returning a 9 number from a function that returns string is legal because String is one of the types that an int can automatically get cast to (this wouldn't work if string was not in the '[]' after 'auto_cast')
  let main_file = (#|
    #|class Int{
    #|  auto_cast[String]
    #|}
    #|function returns_string()String{
    #|  return "9"
    #|  return 9
    #|}
    #|
  )


  let module_ = Module::from_files([main_file])
  module_.do_parenting()
  for name, symbol in module_.symbols {
    match symbol {
      Symbol::Function(function_) => {
        if function_.return_type.name == "unknown" {
          function_.infer_return_type()
        }
        function_.type_check_vars()
        function_.ensure_var_has_proper_return_type()
      }
      _ => ()
    }
  }
}