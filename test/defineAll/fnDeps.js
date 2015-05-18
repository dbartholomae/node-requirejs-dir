DirRequirer = require('../lib/DirRequirer');

new DirRequirer("files").defineAll(["defineAll/data"], function(){ return arguments; });