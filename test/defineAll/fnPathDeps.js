DirRequirer = require('../lib/DirRequirer');

new DirRequirer().defineAll("files", ["defineAll/data"], function(){ return arguments; });