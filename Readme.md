# elm-bluetooth

[WebBluetooth](https://webbluetoothcg.github.io/web-bluetooth/) bindings for Elm.

**_WARNING: Very experimental!_**

## Native modules

As this package uses Elm Native modules you will need to install with something like [elm-github-install](https://github.com/gdotdesign/elm-github-install).

## Example

An example app that connects to a Bluetooth Heart Rate Monitor is provided (`example/HeartRateMonitor.elm`).

    cd examples
    elm-install
    elm reactor

## Todos

-   [ ] Equality test between `Binary.ArrayBuffer` does not work the way I expect: `Binary.uint32 0 == Binary.uint32 1` is `True`. Also see test case for this. I don't fully understnd how Elm checks equality. How can this be fixed?
-   [ ] Split of binary stuff to `elm-binary`.
-   [ ] Make Heart rate monitor example nicer.
-   [ ] Improve error Handling (get rid of `Unknown` error type).
-   [ ] Add binding to `BluetoothUUID` (<https://webbluetoothcg.github.io/web-bluetooth/#standardized-uuids>)

Contributions are very welcome.

## References

-   [WebBluetooth](https://webbluetoothcg.github.io/web-bluetooth/)
-   [MDN - Web Bluetooth API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Bluetooth_API)
