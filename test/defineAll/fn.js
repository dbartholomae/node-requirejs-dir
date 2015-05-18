DirRequirer = require('../lib/DirRequirer');

new DirRequirer("files").defineAll(function(){ return arguments; });