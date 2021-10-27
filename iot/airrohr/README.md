# "Airrohr" Airquality Sensor

+ Source: https://github.com/opendata-stuttgart/sensors-software
+ Base: https://platformio.org/
+ Platform: https://github.com/platformio/platform-espressif8266/
+ Framework: arduino
+ Board: nodemcuv2
+ platform_version: espressif8266@2.6.2
+ platform_version_esp32: espressif32@1.11.1

## SSL support in influxdb/post, http/post
+ SSL Provider: BearSSL (BEARSSL_SSL_BASIC)
+ Supported Ciphersuite list:
  + https://github.com/esp8266/Arduino/blob/master/libraries/ESP8266WiFi/src/WiFiClientSecureBearSSL.cpp#L847

+ openssl to iana mapping: https://testssl.sh/openssl-iana.mapping.html

|IANA Name|Nginx Name|
|---|---|
TLS_RSA_WITH_AES_128_CBC_SHA256 | AES128-SHA256
TLS_RSA_WITH_AES_256_CBC_SHA256 | AES256-SHA256
TLS_RSA_WITH_AES_128_CBC_SHA    | AES128-SHA
TLS_RSA_WITH_AES_256_CBC_SHA    | AES256-SHA

## HTTP/S POST payload

### Payload Content

|Fieldname|Content Description|
|---|---|
software_version | firmware version
esp8266id | unique id of esp chip
signal | signal strength in dBm
SDS_P1 | pm10 in µg/m³
SDS_P2 | pm2.5 in µg/m³
BME280_temperature | temperature in °C
BME280_pressure | pressure in hPa
BME280_humidity | humidity in %


+ application/json payload
```json
{
  "esp8266id": "123456789",
  "software_version": "NRZ-2020-133",
  "sensordatavalues": [{
    "value_type": "SDS_P1",
    "value": "7.35"
  }, {
    "value_type": "SDS_P2",
    "value": "4.15"
  }, {
    "value_type": "BME280_temperature",
    "value": "9.28"
  }, {
    "value_type": "BME280_pressure",
    "value": "99655.97"
  }, {
    "value_type": "BME280_humidity",
    "value": "48.10"
  }, {
    "value_type": "samples",
    "value": "5094690"
  }, {
    "value_type": "min_micro",
    "value": "28"
  }, {
    "value_type": "max_micro",
    "value": "20051"
  }, {
    "value_type": "interval",
    "value": "145000"
  }, {
    "value_type": "signal",
    "value": "-80"
  }]
}
```



## parse sensor data in homeassistant webhook
```yaml
- unique_id: 1234-use-uuidgen
  trigger:
  - platform: webhook
    webhook_id: same-as-unique_id
  binary_sensor: []
  sensor:
  - unique_id: sensor_version
    state: '{{ trigger.json.software_version }}'
    icon: mdi:chip
  - unique_id: sensor_id
    state: '{{ trigger.json.esp8266id }}'
  - unique_id: sensor_signal
    device_class: signal_strength
    state_class: measurement
    unit_of_measurement: dBm
    state: '{{ trigger.json.sensordatavalues|selectattr("value_type", "eq", "signal")|map(attribute="value")|list|last() }}'
  - unique_id: BME280_temperature
    device_class: temperature
    unit_of_measurement: °C
    state_class: measurement
    state: '{{ trigger.json.sensordatavalues|selectattr("value_type", "eq", "BME280_temperature")|map(attribute="value")|list|last() }}'
  - unique_id: SDS_P1_PM10
    device_class: pm10
    unit_of_measurement: µg/m³
    state_class: measurement
    state: '{{ trigger.json.sensordatavalues|selectattr("value_type", "eq", "SDS_P1")|map(attribute="value")|list|last() }}'
  - unique_id: SDS_P2_PM25
    device_class: pm25
    unit_of_measurement: µg/m³
    state_class: measurement
    state: '{{ trigger.json.sensordatavalues|selectattr("value_type", "eq", "SDS_P2")|map(attribute="value")|list|last() }}'
  - unique_id: BME280_pressure
    device_class: pressure
    unit_of_measurement: hPa
    state_class: measurement
    state: '{{ trigger.json.sensordatavalues|selectattr("value_type", "eq", "BME280_pressure")|map(attribute="value")|list|last() }}'
  - unique_id: BME280_humidity
    device_class: humidity
    unit_of_measurement: '%'
    state_class: measurement
    state: '{{ trigger.json.sensordatavalues|selectattr("value_type", "eq", "BME280_humidity")|map(attribute="value")|list|last() }}'
```

## calculation of derrived values

### norm_pressure (QFF)

Luftdruck auf Meereshöhe = Barometeranzeige /
    (1 - Temperaturgradient * Höhe /
    Temperatur auf Meereshöhe in Kelvin ) ^
    (0,03416 / Temperaturgradient)

temp_factor=0,03416
Tg=0,0065
H=223
kelvin_shift=273,15

norm_pressure= (pressure/100) /
 (1-Tg*location_height/
    (temperature+kelvin_shift)^
	(temp_factor/Tg))

#### influxdb

SELECT (mean("BME280_pressure") / 100) /
  (1- [[Tg]] * [[location_height]] /
    (
	(mean( "BME280_temperature") + [[kelvin_shift]]) ^
	([[temp_factor]] / [[Tg]])
    )
  )
FROM "feinstaub" WHERE $timeFilter GROUP BY time($__interval) fill(null)

(mean("BME280_pressure")/100) / (1 - 0.0065 * 223 / (273.15 + mean("BME280_temperature") + 0.0065 * 223)) ** (0.034163 / 0.0065)

(mean("BME280_pressure")/100) / pow((1 - 0.0065 * [[location_height]] / (273.15 + mean("BME280_temperature") + 0.0065 * [[location_height]])), (0.034163 / 0.0065))

987,90 / (1 - 0,0065 * 223 / (273,15 + 20 + 0,0065 * 223)) ** (0,034163 / 0,0065)

#### promql

avg(${sensor_name}_BME280_pressure) / 100 /
    ((1 - 0.0065 * $location_height / (273.15 + avg(${sensor_name}_BME280_temperature) +
    0.0065 * $location_height)) ^ (0.034163 / 0.0065))

### absolute_humidity

(6.112 * exp((17.67 * ${sensor_name}_BME280_temperature) / (243.5 + ${sensor_name}_BME280_temperature)) * ${sensor_name}_BME280_humidity * 2.1674) / (273.15 + ${sensor_name}_BME280_temperature)

(6.112 * exp((17.67 * mean("BME280_temperature")) / (243.5 + mean("BME280_temperature"))) * mean("BME280_humidity") * 2.1674) / (273.15 + mean("BME280_temperature"))

mean("BME280_humidity")  / 100 * mean("BME280_temperature")

(6.112 * exp((17.67 * ${sensor_name}_BME280_temperature) / (243.5 + ${sensor_name}_BME280_temperature)) * ${sensor_name}_BME280_humidity * 2.1674) / (273.15 + ${sensor_name}_BME280_temperature)

a=13.2471*Math.pow(Math.E,17.67*t/(t+243.5))*r/(273.15+t);
	document.getElementById("al").value=Math.round(a*100)/100

(6.112 × e^[(17.67 × T)/(T+243.5)] × rh × 2.1674 ) / (273.15+T)


|name|description|
|---|---|
r | relative Luftfeuchte
T | Temperatur in °C
TK | Temperatur in Kelvin (TK = T + 273.15)
TD | Taupunkttemperatur in °C
DD | Dampfdruck in hPa
SDD | Sättigungsdampfdruck in hPa

|parameter|condition|
|---|---|
a = 7.5, b = 237.3 | T >= 0
a = 7.6, b = 240.7 | T < 0 über Wasser (Taupunkt)
a = 9.5, b = 265.5 | T < 0 über Eis (Frostpunkt)

R* = 8314.3 J/(kmol*K) (universelle Gaskonstante)
mw = 18.016 kg/kmol (Molekulargewicht des Wasserdampfes)
AF = absolute Feuchte in g Wasserdampf pro m3 Luft

Formeln:
SDD(T) = 6.1078 * 10^((a*T)/(b+T))
DD(r,T) = r/100 * SDD(T)
r(T,TD) = 100 * SDD(TD) / SDD(T)
TD(r,T) = b*v/(a-v) mit v(r,T) = log10(DD(r,T)/6.1078)
AF(r,TK) = 10^5 * mw/R* * DD(r,T)/TK; AF(TD,TK) = 10^5 * mw/R* * SDD(TD)/TK
