# elm-binary

Binary data in Elm.

**_WARNING: Very experimental!_**

## Native modules

As this package uses Elm Native modules you will need to install with something like [elm-github-install](https://github.com/gdotdesign/elm-github-install).

## Todos

-   [ ] Equality test between `Binary.ArrayBuffer` does not work the way I expect: `Binary.uint32 0 == Binary.uint32 1` is `True`. Also see test case for this. I don't fully understnd how Elm checks equality. How can this be fixed?

Contributions are very welcome.

## References

-   [MDN ArrayBuffer](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer)
-   [MDN DataView](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/DataView)
