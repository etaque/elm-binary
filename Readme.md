# elm-binary

Binary data in Elm.

This is very much inspired by https://github.com/jinjor/elm-binary-decoder.

## Kernel code

This package uses Kernel code, so it can not be directly installed.

## Tests

To execute the tests, run `elm-test` from the `tests` directory:

    cd tests && elm-test

Because the module contains kernel code, a minimal application has to be set up in order to run the tests.

### Gotchas

-   Equality test on `Binary.ArrayBuffer` has unexpected behaviour: `Binary.uint32 0 == Binary.uint32 1` is `True`. Also see test case for this.

## References

-   [MDN ArrayBuffer](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer)
-   [MDN DataView](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/DataView)
