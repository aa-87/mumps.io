(function () {
  function uint8ToBase64(uint8) {
    var binary = '';
    var i;
    for (i = 0; i < uint8.length; i += 1) binary += String.fromCharCode(uint8[i]);
    return self.btoa(binary);
  }

  function readBlobAsArrayBuffer(blob) {
    if (typeof FileReaderSync !== 'undefined') {
      return Promise.resolve(new FileReaderSync().readAsArrayBuffer(blob));
    }
    return new Promise(function (resolve, reject) {
      var reader = new FileReader();
      reader.onload = function (evt) { resolve((evt.target && evt.target.result) || new ArrayBuffer(0)); };
      reader.onerror = function () { reject(new Error('file_read_failed')); };
      reader.readAsArrayBuffer(blob);
    });
  }

  self.addEventListener('message', function (event) {
    var msg = event && event.data;
    if (!msg || msg.action !== 'prepareBinary') return;
    readBlobAsArrayBuffer(msg.blob).then(function (buffer) {
      var bytes = new Uint8Array(buffer || new ArrayBuffer(0));
      self.postMessage({ ok: 1, taskId: msg.taskId, index: +msg.index || 0, bytes: bytes.length, data: uint8ToBase64(bytes) });
    }).catch(function (err) {
      self.postMessage({ ok: 0, taskId: msg.taskId, index: +msg.index || 0, error: (err && err.message) || 'worker_prepare_failed' });
    });
  });
}());
