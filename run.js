const path = require('path');
const jsonSL = require('./json-sl.js');
console.log(jsonSL);
if (require.main === module) {
	console.log(jsonSL(require(path.join(process.cwd(),process.argv[2]))))
} else {
	module.exports = jsonSL;
}