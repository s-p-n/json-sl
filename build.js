const path = require('path');
function build(data) {
	const Parser = require('jison').Parser;
	const fs = require ('fs');
	const calcLang = fs.readFileSync(path.join(__dirname, "lib/calc.jison"), "utf8");
	const labelSearchLang = fs.readFileSync(path.join(__dirname, "lib/labelSearch.jison"), "utf8");
	const muncherClass = fs.readFileSync(path.join(__dirname, "lib/muncher.js"), "utf8")
	const calc = new Parser(calcLang);
	const labelSearch = new Parser(labelSearchLang);
	let out = `const jsonSL = (function () {`;
	out += muncherClass;
	out += calc.generate({moduleName: "calc"});
	out += labelSearch.generate({moduleName: "labelSearch"});
	out = out.replace(/if\ \(typeof\ require[^{]*\{[^{]*\{[^{]*\{[^}]*\}[^}]*\}[^}]*\}[^}]*\}/g, '');
	out += `
		return function jsonSL(data) {
			const m = new Muncher(data);
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
		}
	}());
if (typeof require !== 'undefined' && typeof exports !== 'undefined') {
	module.exports = jsonSL;
}`
	fs.writeFile(path.join(__dirname, "./json-sl.js"), out, function (err, res) {
		if (err) {
			console.error(err);
			return;
		}
		console.log("./json-sl.js generated.");
	});
};
if (require.main === module) {
	build()
} else {
	module.exports = build;
}