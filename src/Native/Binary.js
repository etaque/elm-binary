var _user$project$Native_Binary = (function () {
  const Scheduler = _elm_lang$core$Native_Scheduler
  const Array = _elm_lang$core$Native_Array

  function Just (a) {
    return {ctor: 'Just',
      _0: a}
  }

  const Nothing = {ctor: 'Nothing'}

  function zeros (n) {
    return new ArrayBuffer(n)
  }

  function int8 (a) {
    var buffer = new ArrayBuffer(1)
    var view = new DataView(buffer)
    view.setInt8(0, a)
    return buffer
  }

  function uint8 (a) {
    var buffer = new ArrayBuffer(1)
    var view = new DataView(buffer)
    view.setUint8(0, a)
    return buffer
  }

  function int16 (a) {
    var buffer = new ArrayBuffer(2)
    var view = new DataView(buffer)
    view.setInt16(0, a)
    return buffer
  }

  function uint16 (a) {
    var buffer = new ArrayBuffer(2)
    var view = new DataView(buffer)
    view.setInt16(0, a)
    return buffer
  }

  function int32 (a) {
    var buffer = new ArrayBuffer(4)
    var view = new DataView(buffer)
    view.setInt32(0, a)
    return buffer
  }

  function uint32 (a) {
    var buffer = new ArrayBuffer(4)
    var view = new DataView(buffer)
    view.setUint32(0, a)
    return buffer
  }

  //

  function getInt8 (offset, buffer) {
    try {
      var view = new DataView(buffer)
      return Just(view.getInt8(offset))
    } catch (e) {
      return Nothing
    }
  }

  //

  function toArrayBuffer (bytes) {
    var length = Array.length(bytes)
    var buffer = new ArrayBuffer(length)
    var view = new Uint8Array(buffer)
    for (var i = 0; i < length; i++) {
      view.set(new Uint8Array(A2(Array.get, i, bytes)), i)
    }
    return buffer
  }

  function fromArrayBuffer (buffer) {
    var length = buffer.byteLength
    var bytes = Array.empty
    for (var i = 0; i < length; i++) {
      bytes = A2(Array.push, buffer.slice(i, i + 1), bytes)
    }
    return bytes
  }

  function test () {
    var buffer = new ArrayBuffer(20)
    var view = new DataView(buffer)
    for (var i = 0; i < 20; i++) {
      view.setInt8(i, i)
    }
    return buffer
  }

  return {
    zeros: zeros,
    int8: int8,
    uint8: uint8,
    int16: int16,
    uint16: uint16,
    int32: int32,
    uint32: uint32,
    //
    getInt8: F2(getInt8),
    //
    toArrayBuffer: toArrayBuffer,
    fromArrayBuffer: fromArrayBuffer,
    //
    test: test
  }
})()
