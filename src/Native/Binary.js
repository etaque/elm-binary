var _user$project$Native_Binary = (function () {
  const Scheduler = _elm_lang$core$Native_Scheduler
  const List = _elm_lang$core$Native_List

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

  function int16 (le, a) {
    var buffer = new ArrayBuffer(2)
    var view = new DataView(buffer)
    view.setInt16(0, a, le)
    return buffer
  }

  function uint16 (le, a) {
    var buffer = new ArrayBuffer(2)
    var view = new DataView(buffer)
    view.setInt16(0, a, le)
    return buffer
  }

  function int32 (le, a) {
    var buffer = new ArrayBuffer(4)
    var view = new DataView(buffer)
    view.setInt32(0, a, le)
    return buffer
  }

  function uint32 (le, a) {
    var buffer = new ArrayBuffer(4)
    var view = new DataView(buffer)
    view.setUint32(0, a, le)
    return buffer
  }

  function float32 (le, a) {
    var buffer = new ArrayBuffer(4)
    var view = new DataView(buffer)
    view.setFloat32(0, a, le)
    return buffer
  }

  function float64 (le, a) {
    var buffer = new ArrayBuffer(8)
    var view = new DataView(buffer)
    view.setFloat64(0, a, le)
    return buffer
  }
  //

  function getInt8 (offset, view) {
    try {
      return Just(view.getInt8(offset))
    } catch (e) {
      return Nothing
    }
  }

  function getUint8 (offset, view) {
    try {
      return Just(view.getUint8(offset))
    } catch (e) {
      return Nothing
    }
  }

  function getInt16 (le, offset, view) {
    try {
      return Just(view.getInt16(offset, le))
    } catch (e) {
      return Nothing
    }
  }

  function getUint16 (le, offset, view) {
    try {
      return Just(view.getUint16(offset, le))
    } catch (e) {
      return Nothing
    }
  }

  function getInt32 (le, offset, view) {
    try {
      return Just(view.getInt32(offset, le))
    } catch (e) {
      return Nothing
    }
  }

  function getUint32 (le, offset, view) {
    try {
      return Just(view.getUint32(offset, le))
    } catch (e) {
      return Nothing
    }
  }

  function getFloat32 (le, offset, view) {
    try {
      return Just(view.getFloat32(offset, le))
    } catch (e) {
      return Nothing
    }
  }

  function getFloat64 (le, offset, view) {
    try {
      return Just(view.getFloat64(offset, le))
    } catch (e) {
      return Nothing
    }
  }

  //

  function concat (elmBuffers) {
    var buffers = List.toArray(elmBuffers)

    var length = buffers.reduce(function (total, buffer) {
      return total + buffer.byteLength
    }, 0)

    var out = new ArrayBuffer(length)
    var view = new Uint8Array(out)
    var offset = 0

    for (var i = 0; i < buffers.length; i++) {
      var buffer = buffers[i]
      view.set(new Uint8Array(buffer), offset)
      offset = offset + buffer.byteLength
    }

    return out
  }

  //

  function dataView (buffer) {
    return new DataView(buffer)
  }

  return {
    zeros: zeros,
    int8: int8,
    uint8: uint8,
    int16: F2(int16),
    uint16: F2(uint16),
    int32: F2(int32),
    uint32: F2(uint32),
    float32: F2(float32),
    float64: F2(float64),

    getInt8: F2(getInt8),
    getUint8: F2(getUint8),
    getInt16: F3(getInt16),
    getUint16: F3(getUint16),
    getInt32: F3(getInt32),
    getUint32: F3(getUint32),
    getFloat32: F3(getFloat32),
    getFloat64: F3(getFloat64),

    concat: concat,

    dataView: dataView
  }
})()
