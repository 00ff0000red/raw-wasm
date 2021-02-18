// forked from https://github.com/binji/raw-wasm

const {
	document: {
		head,
		body
	},
	WebAssembly: {
		Memory,
		instantiateStreaming
	},
	Math,
	globalThis,
	Uint8ClampedArray,
	ImageData
} = self;

head.querySelector("script").remove();

const context = body.querySelector("canvas").getContext("2d");

const memory = new Memory({
	initial: 5,
	maximum: 5,
	shared: false
});

const data = new Uint8ClampedArray(
	memory.buffer,
	53760,
	215040
);

const imageData = new ImageData(
	data,
	320,
	168
);

instantiateStreaming(
	fetch(
		"./fire.wasm", {
			mode		: "same-origin",
			credentials	: "omit",
			cache		: "default",
			referrer	: "no-referrer"
		}
	), [
		Math,
		globalThis, [
			context.putImageData.bind(
				context,
				imageData,
				0,
				0
			),
			memory
		]
	]
);
