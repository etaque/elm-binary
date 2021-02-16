# elm-binary

Binary data in Elm.

This is very much inspired by https://github.com/jinjor/elm-binary-decoder.

## Kernel code

This package uses Kernel code, so it can not be directly installed.

## Getting started

Use `nix-shell --run elm-pkg` to list available commands.

## Limitations

-   Equality is not well-defined on `Binary.ArrayBuffer`, it will be true for any two values.

## References

-   [MDN ArrayBuffer](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer)
-   [MDN DataView](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/DataView)
