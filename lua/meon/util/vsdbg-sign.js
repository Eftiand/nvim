const vsda_location = '/Applications/Visual Studio Code.app/Contents/Resources/app/node_modules.asar.unpacked/vsda/build/Release/vsda.node';
const vsda = require(vsda_location);
const signer = new vsda.signer();

process.argv.forEach((value, index) => {
  if (index >= 2) {
    const r = signer.sign(value);
    console.log(r);
  }
});
