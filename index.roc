# Run with `roc ./examples/CommandLineArgsFile/main.roc -- examples/CommandLineArgsFile/input.txt`
app [main!] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br",
}

main! = |args|
    Stdout.line!("Hello!")
