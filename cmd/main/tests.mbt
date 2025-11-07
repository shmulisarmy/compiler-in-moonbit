test "valid referencing of var statement to type inferred param" {
    let parser = Parser::new("add(a = 0, b Int)Int {\nvar c Int = a}")
    let function = parser.function()
    function.type_check_var_statments()
} 