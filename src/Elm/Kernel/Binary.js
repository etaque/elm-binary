/*

import Elm.Kernel.List exposing (toArray)
import Maybe exposing (Just, Nothing)

*/

function _Binary_zeros(n) {
  return new ArrayBuffer(n);
}

function _Binary_int8(a) {
  var buffer = new ArrayBuffer(1);
  var view = new DataView(buffer);
  view.setInt8(0, a);
  return buffer;
}

function _Binary_uint8(a) {
  var buffer = new ArrayBuffer(1);
  var view = new DataView(buffer);
  view.setUint8(0, a);
  return buffer;
}

var _Binary_int16 = F2(function (le, a) {
  var buffer = new ArrayBuffer(2);
  var view = new DataView(buffer);
  view.setInt16(0, a, le);
  return buffer;
});

var _Binary_uint16 = F2(function (le, a) {
  var buffer = new ArrayBuffer(2);
  var view = new DataView(buffer);
  view.setInt16(0, a, le);
  return buffer;
});

var _Binary_int32 = F2(function (le, a) {
  var buffer = new ArrayBuffer(4);
  var view = new DataView(buffer);
  view.setInt32(0, a, le);
  return buffer;
});

var _Binary_uint32 = F2(function (le, a) {
  var buffer = new ArrayBuffer(4);
  var view = new DataView(buffer);
  view.setUint32(0, a, le);
  return buffer;
});

var _Binary_float32 = F2(function (le, a) {
  var buffer = new ArrayBuffer(4);
  var view = new DataView(buffer);
  view.setFloat32(0, a, le);
  return buffer;
});

var _Binary_float64 = F2(function (le, a) {
  var buffer = new ArrayBuffer(8);
  var view = new DataView(buffer);
  view.setFloat64(0, a, le);
  return buffer;
});
//

var _Binary_getInt8 = F2(function (offset, view) {
  try {
    return __Maybe_Just(view.getInt8(offset));
  } catch (e) {
    return __Maybe_Nothing;
  }
});

var _Binary_getUint8 = F2(function (offset, view) {
  try {
    return __Maybe_Just(view.getUint8(offset));
  } catch (e) {
    return __Maybe_Nothing;
  }
});

var _Binary_getInt16 = F3(function (le, offset, view) {
  try {
    return __Maybe_Just(view.getInt16(offset, le));
  } catch (e) {
    return __Maybe_Nothing;
  }
});

var _Binary_getUint16 = F3(function (le, offset, view) {
  try {
    return __Maybe_Just(view.getUint16(offset, le));
  } catch (e) {
    return __Maybe_Nothing;
  }
});

var _Binary_getInt32 = F3(function (le, offset, view) {
  try {
    return __Maybe_Just(view.getInt32(offset, le));
  } catch (e) {
    return __Maybe_Nothing;
  }
});

var _Binary_getUint32 = F3(function (le, offset, view) {
  try {
    return __Maybe_Just(view.getUint32(offset, le));
  } catch (e) {
    return __Maybe_Nothing;
  }
});

var _Binary_getFloat32 = F3(function (le, offset, view) {
  try {
    return __Maybe_Just(view.getFloat32(offset, le));
  } catch (e) {
    return __Maybe_Nothing;
  }
});

var _Binary_getFloat64 = F3(function (le, offset, view) {
  try {
    return __Maybe_Just(view.getFloat64(offset, le));
  } catch (e) {
    return __Maybe_Nothing;
  }
});

//

function _Binary_concat(elmBuffers) {
  var buffers = __List_toArray(elmBuffers);

  var length = buffers.reduce(function(total, buffer) {
    return total + buffer.byteLength;
  }, 0);

  var out = new ArrayBuffer(length);
  var view = new Uint8Array(out);
  var offset = 0;

  for (var i = 0; i < buffers.length; i++) {
    var buffer = buffers[i];
    view.set(new Uint8Array(buffer), offset);
    offset = offset + buffer.byteLength;
  }

  return out;
}

function _Binary_length(buffer) {
  return buffer.byteLength;
}

var _Binary_slice = F3(function(begin, end, buffer) {
  try {
    return __Maybe_Just(buffer.slice(begin, end));
  } catch (e) {
    return __Maybe_Nothing;
  }
});

//

function _Binary_dataView(buffer) {
  return new DataView(buffer);
}

function _Binary_fromDataView(view) {
  return view.buffer.slice(view.byteOffset);
}
