const fz = require('zigbee-herdsman-converters/converters/fromZigbee');
const tz = require('zigbee-herdsman-converters/converters/toZigbee');
const exposes = require('zigbee-herdsman-converters/lib/exposes');
const reporting = require('zigbee-herdsman-converters/lib/reporting');
const extend = require('zigbee-herdsman-converters/lib/extend');
const ota = require('zigbee-herdsman-converters/lib/ota');
const e = exposes.presets;
const ea = exposes.access;


const definition = {
    // The model ID from: Device with modelID 'lumi.sens' is not supported.
    zigbeeModel: ['Tibea TW Z3'],
    // Vendor model number, look on the device for a model number
    model: '4058075168572',
    // Vendor of the device (only used for documentation and startup logging)
    vendor: 'LEDVANCE',
    // Description of the device, copy from vendor site. (only used for documentation and startup logging)
    description: 'SMART+ Tibea Lamp E27 tunable white',
    extend: extend.ledvance.light_onoff_brightness_colortemp(),
    ota: ota.ledvance,
};

module.exports = definition;
