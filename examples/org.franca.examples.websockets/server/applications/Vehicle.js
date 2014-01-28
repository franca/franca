/*******************************************************************************
* Copyright (c) 2013 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/

/*
    Simulation of a vehicle.
    This simulates a driving car and produces some data for the UI.
*/

function Vehicle() { }

// export the "constructor" function to provide a class-like interface
module.exports = Vehicle;


Vehicle.prototype.init = function() {
  var vTarget = 0.0;
  var vActual = 0.0;
  var acc = 0.0;
  var phase = 0;
  var t = 0;

  var _this = this;

  // simulation of driving car, sending broadcasts for current velocity
  this.timerID = setInterval(function() {
    switch (phase) {
      case 0: // set target values
        vTarget = 1 + Math.random()*120;
        acc = 3.0 + Math.random()*8.0;
        if (vTarget<vActual) acc = -acc;
        phase = 1;
        break;

      case 1: // accelerate / decelerate
        vActual += acc;

        // send velocity to client
        if (typeof(_this.onUpdateVelocity) === "function") {
          _this.onUpdateVelocity(vActual);
        }

        if (sign(acc) == sign(vActual-vTarget)) {
          t = 1 + Math.floor(Math.random()*10);
          phase = 2;
        }
        break;

      case 2: // wait
        t -= 1;
        if (t<=0) { phase = 0; }
        break;
    }
  },
  500);
}

function sign(x) { return x ? x < 0 ? -1 : 1 : 0; }
