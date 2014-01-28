/*******************************************************************************
* Copyright (c) 2013 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/

Speaker = require('speaker');

/*
    Music player component.

    Currently it is able to play mp3 streams from icecast servers.
    It will also intercept meta data events and provide some information a
    about artist/title of the currently played song.
*/

function MusicPlayer() {
  this.lame = require('lame');
  this.icecast = require('icecast');
  this.stream = null;
}

// export the "constructor" function to provide a class-like interface
module.exports = MusicPlayer;

MusicPlayer.prototype.play = function(url) {
  var _this = this;

  // connect to the remote stream
  _this.icecast.get(url, function (res) {

    // log the HTTP response headers
    //console.error(res.headers);
    if (res.headers['icy-genre']) {
      _this.genre = res.headers['icy-genre'];
    } else {
      _this.genre = null;
    }

    // detect any "metadata" events that happen
    res.on('metadata', function (metadata) {
      var parsed = _this.icecast.parse(metadata);
      if (typeof(_this.onStreamTitle) === "function") {
        if (parsed.StreamTitle && parsed.StreamTitle.length>3) {
          // send title information to client
          _this.onStreamTitle(parsed.StreamTitle);
        } else {
          // use genre as default
          if (_this.genre) {
            _this.onStreamTitle(_this.genre);
          }
        }
      }
    });

    // stop currently running stream (if any)
    if (_this.stream) {
      _this.stream.end();
    }

    // let's play the music (assuming MP3 data).
    // lame decodes and Speaker sends to speakers!
    _this.stream = res.pipe(new _this.lame.Decoder())
       .pipe(new Speaker());
  });
}

MusicPlayer.prototype.stop = function() {
  if (this.stream) {
    this.stream.end();
    this.onStreamTitle('');
    this.genre = null
  }
}
