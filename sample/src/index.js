'use strict';

require('./elm/Stylesheets');
var Elm = require('./elm/Main');
Elm.Main.embed(document.getElementById('main'));
