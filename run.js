const Parser = require('jison').Parser;
const fs = require ('fs');
const path = require('path');
const Muncher = require ('./lib/muncher.js');
const data = require(path.join(process.cwd(),process.argv[2]));
const calcLang = fs.readFileSync("./lib/calc.jison", "utf8");
const labelSearchLang = fs.readFileSync("./lib/labelSearch.jison", "utf8");

const calc = new Parser(calcLang);
const labelSearch = new Parser(labelSearchLang);
let m = new Muncher(data);

function calcGetRef (ref, obj=this.ctx) {
	const self = this;
	if (ref.indexOf('.') === -1) {
		return obj[ref];
	}
	let nameArr = ref.split('.');
	let firstName = nameArr.shift();
	if (firstName === "parent") {
		return calcGetRef(nameArr.join('.'), self.parent.out);
	}
	return calcGetRef(nameArr.join('.'), obj[firstName]);
}

function labelGetRef (ref, obj=this.ctx) {
	const self = this;
	if (ref.indexOf('.') === -1) {
		return {
			name: ref, 
			valueOf:() => +obj[ref], 
			obj: obj
		};
	}
	let nameArr = ref.split('.');
	let firstName = nameArr.shift();
	if (firstName === "parent") {
		return labelGetRef(nameArr.join('.'), self.parent.out);
	}
	return labelGetRef(nameArr.join('.'), obj[firstName]);
}


calc.yy.getRef = calcGetRef;
labelSearch.yy.getRef = labelGetRef;

m.setValueParser(calc);
m.setLabelParser(labelSearch);
m.munch();
console.log(m.out);
