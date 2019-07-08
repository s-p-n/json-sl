const state = new WeakMap();

class Muncher {
	constructor (obj) {
		state.set(this, {
			in: obj,
			out: null,
			labelParser: null,
			valueParser: null,
			parent: null,
		});
	}

	munch () {
		const self = this;
		const s = state.get(self);

		// Reset the output.
		s.out = {};

		// Iterate over input, set output.
		for (let prop of Object.entries(s.in)) {
			prop = self.parseProperty(...prop);
			if (!prop) {
				continue;
			}
			let [name, value] = prop
			while (typeof value === "object" && "value" in value) {
				value = value.value;
			}
			if (value instanceof Array) {

			} else if (!isNaN(+value)) {
				value = +value;
			} else if(("" + value) !== "[object Object]") {
				value = "" + value;
			}
			s.out[name] = value;
		}
		if ("value" in s.out) {
			s.out = s.out.value;
		}
	}

	setLabelParser (parser) {
		const self = this;
		const s = state.get(self);
		s.labelParser = parser;
	}

	setValueParser (parser) {
		const self = this;
		const s = state.get(self);
		s.valueParser = parser;
	}

	setParent (m) {
		const self = this;
		const s = state.get(self);
		s.parent = m;
	}

	parseLabel (label) {
		const self = this;
		const s = state.get(self);
		if (s.labelParser === null || !s.labelParser.parse) {
			return label
		}
		//console.log("parseLabel in:", label)
		s.labelParser.yy.ctx = self.out;
		s.labelParser.yy.parent = s.parent;
		let result =  s.labelParser.parse(label);
		//console.log("parseLabel out:", result)
		if (typeof result !== "object") {
			return;
		}
		if (!(result.name in result.obj)) {
			return result.name;
		}
		return result;
	}

	parseValue (value) {
		const self = this;
		const s = state.get(self);
		//console.log("parseValue in:", value);
		if (typeof value === "object") {
			const m = new Muncher(value);
			m.setValueParser(s.valueParser);
			m.setLabelParser(s.labelParser);
			m.setParent(self);
			m.munch();
			return m.out;
		}
		if (typeof value === "string") {
			s.valueParser.yy.ctx = self.out;
			s.valueParser.yy.parent = s.parent;
			let result = s.valueParser.parse(value);
			//console.log("parseValue out:", result);
			return result;
		}
		return value;
	}

	parseProperty (name, value) {
		const self = this;
		const s = state.get(self);
		name = self.parseLabel(name);
		if (!name) {
			return;
		}
		if (typeof name === "object") {
			name.obj[name.name] = self.parseValue(value);
			return;
		}
		return [
			name, 
			self.parseValue(value)
		];
	}

	toString () {
		let out = state.get(this).out;
		if (!out) {
			return "" + out;
		}
		if (typeof out.value === "string") {
			return out.value;
		}
		return out.toString();
	}

	valueOf () {
		let out = state.get(this).out;
		if (!out) {
			return +out;
		}
		if (typeof out.value === "number") {
			return out.value;
		}
		return out.valueOf();
	}

	get out () {
		return state.get(this).out;
	}
}

module.exports = Muncher;