test "valid referencing of var statement to type inferred param" {
    let parser = Parser::new("add(a = 0, b Int)Int {\nvar c Int = a}")
    let function = parser.function()
    function.type_check_var_statments()
} 


test "valid referencing of var statement to another var statement" {
  // c gets its type inferred from a and d then checks against c to see if its type matches as its assigning to it
  let parser = Parser::new("add(a = 0, b Int)Int {\nvar c = a\nvar d Int = c}")
  let function = parser.function()
  function.type_check_var_statments()
} 