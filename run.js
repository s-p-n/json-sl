const path = require('path');
function jsonSl(data) {
	const Parser = require('jison').Parser;
	const fs = require ('fs');
	const Muncher = require ('./lib/muncher.js');
	const calcLang = fs.readFileSync(path.join(__dirname, "lib/calc.jison"), "utf8");
	const labelSearchLang = fs.readFileSync(path.join(__dirname, "lib/labelSearch.jison"), "utf8");

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

	function labelEvalRef (ref, obj=this.ctx) {
		let label = this.getRef(ref, obj);
		if (typeof label !== "object") {
			return label;
		}
		while(typeof label === "object" && label.value !== undefined) {
			label = label.value;
		}

		if (!isNaN(+label)) {
			return +label;
		}
		return label;
	}

	function labelGetRef (ref, obj=this.ctx) {
		const self = this;
		if (ref.indexOf('.') === -1) {
			if (!isNaN(+obj[ref])) {
				return {
					name: ref, 
					valueOf:() => +obj[ref], 
					obj: obj
				};
			} else if (obj[ref] !== undefined) {
				return {
					name: ref,
					value: obj[ref],
					obj: obj
				}
			}
			return {name: ref, obj: obj};
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
	labelSearch.yy.evalRef = labelEvalRef;

	m.setValueParser(calc);
	m.setLabelParser(labelSearch);
	m.munch();
	return m.out;
};
if (require.main === module) {
	console.log(jsonSl(require(path.join(process.cwd(),process.argv[2]))))
} else {
	module.exports = jsonSl;
}