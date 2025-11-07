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