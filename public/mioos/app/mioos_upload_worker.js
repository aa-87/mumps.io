self.onmessage = function (event) {
  var msg = (event && event.data) || {};
  function toBase64(bytes) {
    var out = '';
    var i;
    for (i = 0; i < bytes.length; i += 1) out += String.fromCharCode(bytes[i]);
    return self.btoa(out);
  }
  if (msg.type !== 'uploadChunk') return;
  Promise.resolve().then(function () {
    return msg.file.slice(msg.start, msg.end).arrayBuffer();
  }).then(function (buffer) {
    return fetch(msg.route, {
      method: 'POST',
      credentials: 'include',
      headers: { 'Accept': 'application/json', 'Content-Type': 'application/json' },
      body: JSON.stringify({
        uploadId: msg.uploadId,
        index: msg.index,
        bytes: msg.bytes,
        data: toBase64(new Uint8Array(buffer || new ArrayBuffer(0)))
      })
    });
  }).then(function (response) {
    return response.text().then(function (text) {
      var body = {};
      try { body = text ? JSON.parse(text) : {}; } catch (err) { body = {}; }
      if (!response.ok || !body) throw new Error((body && (body.detail || body.reason || body.error)) || 'worker_upload_failed');
      self.postMessage({ type: 'result', uploadId: msg.uploadId, index: msg.index, ok: 1 });
    });
  }).catch(function (err) {
    self.postMessage({ type: 'error', error: (err && err.message) || 'worker_upload_failed', index: msg.index });
  });
};
