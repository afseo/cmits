module Test_subject_mapping =
    let username = Subject_mapping.username
    let arrow = Subject_mapping.arrow
    let certdn = Subject_mapping.certdn
    let line = Subject_mapping.line

    test [ username ] get "foo" = { "foo" }
    test [ arrow ] get " -> " = {}
    test [ arrow ] get "\t->\t" = {}
    test [ arrow . username ] get "\t->\tfoo" = { "foo" }
    test [ certdn ] get "foo" = { = "foo" }
    test [ certdn ] get "foo bar" = { = "foo bar" }
    test line get "foo -> bar\n" = { "bar" = "foo" }
    test line get "Really Odd, Certificate Name. /#$%^&* -> un61\n" =
        { "un61" = "Really Odd, Certificate Name. /#$%^&*" }
