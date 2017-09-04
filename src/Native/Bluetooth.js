/* global F2, _elm_lang$core$Native_Scheduler, _user$project$Native_Binary */
// TODO: remove debugs console.logs

var _user$project$Native_Bluetooth = (function () {
  var scheduler = _elm_lang$core$Native_Scheduler

  // NOTE: we need to store BluetoothDevices outside of Elm as it is an infinite structure (device.gatt.device = device) which makes the Elm runtime go into an infinte recursion
  var devices = {}
  var services = {}
  var characteristics = {}

  function requestDevice (options) {
    try {
      var request = navigator.bluetooth.requestDevice(options)
      return request
    } catch (e) {
      // Return a rejected Promise if the request fails here
      return new Promise(function (resolve, reject) {
        reject(e)
      })
    }
  }

  function connect (request) {
    return scheduler.nativeBinding(function (callback) {
      request.then(function (device) {
        console.log('Connected')
        devices[device.id] = device
        return device.gatt.connect()
      }).then(function (gattServer) {
        console.log('Connected to GATT')
        callback(scheduler.succeed(gattServer.device.id))
      }).catch(function (e) {
        console.log(e)
        if (e instanceof TypeError) {
          callback(scheduler.fail({ctor: 'NoBluetooth'}))
        } else {
          callback(scheduler.fail({ctor: 'Unknown', _0: e.message}))
        }
      })
    })
  }

  function getPrimaryService (uuid, deviceId) {
    var device = devices[deviceId]
    return scheduler.nativeBinding(function (callback) {
      console.log('Getting primary service')
      device.gatt.getPrimaryService(uuid).then(function (service) {
        console.log('Got primary service')
        // use symbol in order to be able to handle multiple services with same uuid from multiple devices without passing along reference to device
        var symbol = Symbol(service.uuid)
        services[symbol] = service
        callback(scheduler.succeed(symbol))
      }).catch(function (e) {
        console.log(e)
        callback(scheduler.fail({ctor: 'Unknown', _0: e.message}))
      })
    })
  }

  function getCharacteristic (uuid, serviceSymbol) {
    var service = services[serviceSymbol]
    return scheduler.nativeBinding(function (callback) {
      service.getCharacteristic(uuid).then(function (characteristic) {
        console.log('Got characteristic')
        var symbol = Symbol(characteristic.uuid)
        characteristics[symbol] = characteristic
        callback(scheduler.succeed(symbol))
      }).catch(function (e) {
        console.log(e)
        callback(scheduler.fail({ctor: 'Unknown', _0: e.message}))
      })
    })
  }

  function readValue (characteristicSymbol) {
    var characteristic = characteristics[characteristicSymbol]
    return scheduler.nativeBinding(function (callback) {
      characteristic.readValue().then(function (value) {
        // In Chrome 50+, a DataView is returned instead of an ArrayBuffer.
        value = value.buffer ? value.buffer : value
        callback(scheduler.succeed(value))
      }).catch(function (e) {
        console.log(e)
        callback(scheduler.fail({ctor: 'Unknown', _0: e.message}))
      })
    })
  }

  function onCharacteristicValueChanged (onValueChange, characteristicSymbol) {
    console.log('in onCharacteristicValueChanged')
    var characteristic = characteristics[characteristicSymbol]
    return scheduler.nativeBinding(function (callback) {
      // event handler
      function handler (event) {
        // In Chrome 50+, a DataView is returned instead of an ArrayBuffer.
        var value = event.target.value.buffer ? event.target.value.buffer : event.target.value
        scheduler.rawSpawn(onValueChange(value))
      }

      characteristic.addEventListener('characteristicvaluechanged', handler)

      characteristic.startNotifications()

      // Return a function describing how to clean up (this will be called when the Process this is run in is killed).
      return function () {
        characteristic.removeEventListener('characteristicvaluechanged', handler)
      }
    })
  }

  return {
    requestDevice: requestDevice,
    connect: connect,
    getPrimaryService: F2(getPrimaryService),
    getCharacteristic: F2(getCharacteristic),
    readValue: readValue,
    onCharacteristicValueChanged: F2(onCharacteristicValueChanged)
  }
})()
