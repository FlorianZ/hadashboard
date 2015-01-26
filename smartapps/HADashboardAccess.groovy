/**
 *  Home Automation Dashboard Access
 *
 *  https://github.com/FlorianZ/hadashboard
 *
 */


//
// Definition
//
definition(
    name: "Dashboard Access",
    namespace: "florianz",
    author: "florianz",
    description: "SmartThings access for the Dashboard web app.",
    category: "Convenience",
    iconUrl: "https://s3.amazonaws.com/smartapp-icons/Convenience/Cat-Convenience.png",
    iconX2Url: "https://s3.amazonaws.com/smartapp-icons/Convenience/Cat-Convenience@2x.png",
    oauth: true) {
}


//
// Preferences
//
preferences {
    section("Allow access to the following things...") {
        input "contactSensorDevices", "capability.contactSensor", title: "Which Contact Sensors?", multiple: true, required: false
        input "switchLevelDevices", "capability.switchLevel", title: "Which Dimmer Switches?", multiple: true, required: false
        input "relativeHumidityMeasurementDevices", "capability.relativeHumidityMeasurement", title: "Which Humidity Sensors?", multiple: true, required: false
        input "lockDevices", "capability.lock", title: "Which Locks?", multiple: true, required: false
        input "powerMeterDevices", "capability.powerMeter", title: "Which Power Meters?", multiple: true, required: false
        input "motionSensorDevices", "capability.motionSensor", title: "Which Motion Sensors?", multiple: true, required: false
        input "presenceSensorDevices", "capability.presenceSensor", title: "Which Presence Sensors?", multiple: true, required: false
        input "switchDevices", "capability.switch", title: "Which Switches?", multiple: true, required: false
        input "temperatureMeasurementDevices", "capability.temperatureMeasurement", title: "Which Temperature Sensors?", multiple: true, required: false
    }
}


//
// Mappings
//
mappings {
    path("/version") {
        action: [
            GET: "getVersion"
        ]
    }

    path("/v1/info/:detail") {
        action: [
            GET: "getInfo"
        ]
    }

    path("/v1/configure") {
        action: [
            POST: "postConfigure"
        ]
    }

    path("/v1/subscribe") {
        action: [
            POST: "postSubscribe"
        ]
    }

    path("/v1/unsubscribe") {
        action: [
            POST: "postUnsubscribe"
        ]
    }

    path("/v1/execute") {
        action: [
            POST: "postExecute"
        ]
    }
}


//
// Installation
//
def installed() {
    initialize()
}

def updated() {
    initialize()
}

def initialize() {
    state.dashingURI = ""
    state.dashingAuthToken = ""
    state.subscribers = [:]

    subscribeToEvents()
}


//
// API Version
//
def getVersion() {
    ["version": 1]
}


//
// Info
//
def getInfo() {
    switch(params.detail) {
        case "devices":
            return getDevices()

        case "weather":
            return getWeather(request.JSON?.feature)
    }

    respondWithStatus(1, "${params.detail} not supported.")
}

def getDevices() {
    def response = [:]

    settings.each {
        it.value.each {
            if (it.hasProperty("capabilities")) {
                def capabilities = it.capabilities.collect { it.name }
                def attributes = it.supportedAttributes.collect {
                    [name: it.name, dataType: it.dataType, values: it.values]
                }
                def commands = it.supportedCommands.collect {
                    [name: it.name, arguments: it.arguments]
                }

                response[it.displayName] = [
                    capabilities: capabilities,
                    attributes: attributes,
                    commands: commands
                ]
            }
        }
    }

    log.debug "getDevices ${response}"

    return response
}

def getWeather(feature) {
    if (!feature) {
        feature = "conditions"
    }
    return getWeatherFeature(feature)
}


//
// Configuration
//
def postConfigure() {
    state.dashingURI = request.JSON?.dashingURI
    state.dashingAuthToken = request.JSON?.dashingAuthToken

    log.debug "configure ${state.dashingURI}"

    respondWithSuccess()
}


//
// Subscription
//
def postSubscribe() {
    def widgets = request.JSON?.widgets
    def response = [:]

    widgets.each {
        def widgetId = it.key
        def devices = it.value

        response[widgetId] = [:]

        devices.each {
            def deviceKey = it.key
            def attributes = it.value

            registerWidget(deviceKey, widgetId, attributes)

            if (!attributes.isEmpty()) {
                response[widgetId][deviceKey] =
                    getValues(getDevice(deviceKey), attributes)
            }
        }
    }

    subscribeToEvents()

    return response
}

def postUnsubscribe() {
    def widgets = request.JSON?.widgets

    widgets.each {
        def widgetId = it.key
        def devices = it.value


        devices.each {
            def deviceKey = it

            state.subscribers[deviceKey].remove(widgetId)

            log.debug "unsubscribe ${widgetId} from ${deviceKey}"
        }

        // Unsubscribe from all devices
        if (devices.isEmpty()) {
            state.subscribers.each {
                it.value.remove(widgetId)
            }

            log.debug "unsubscribe ${widgetId} from all devices"
        }
    }
}


//
// Commands
//
def postExecute() {
    def devices = request.JSON?.devices

    devices.each {
        def deviceKey = it.key
        def device = getDevice(deviceKey)
        def commands = it.value

        commands.each {
            device."$it.key"(*it.value)
            log.debug "executeCommand ${deviceKey} ${it.key} ${it.value}"
        }
    }

    respondWithSuccess()
}


//
// Event Helpers
//
def eventHandler(evt) {
    def deviceKey = evt.displayName
    def device = getDevice(deviceKey)

    state.subscribers[deviceKey].each {
        def data = [:]
        data[deviceKey] = getValues(device, it.value)
        notifyWidget(it.key, data)
    }
}

private subscribeToEvents() {
    log.debug "subscribeToEvents (unsubscribe)"
    unsubscribe()

    state.subscribers.each {
        def deviceKey = it.key
        def device = getDevice(deviceKey)

        def attributes = []
        it.value.each {
            attributes += it.value
        }
        attributes.unique()

        log.debug "subscribToEvents ${deviceKey} ${attributes}"

        attributes.each {
            subscribe(device, it, eventHandler)
        }
    }
}

private getDevice(deviceKey) {
    def result = null
    settings.find {
        result = it.value.find { 
            it.hasProperty("capabilities") && it.displayName == deviceKey
        }
    }
    return result
}

private getValues(device, attributes) {
    def result = [:]
    attributes.each {
        def value = device.currentValue(it)
        if (value) {
            result[it] = value
        }
    }
    return result
}


//
// Widget Helpers
//
private registerWidget(deviceKey, widgetId, attributes) {
    if (!state.subscribers[deviceKey]) {
        state.subscribers[deviceKey] = [:]
    }

    def registeredAttributes = [attributes].flatten()
    if (registeredAttributes.isEmpty()) {
        state.subscribers[deviceKey].remove(widgetId)
        log.debug "registerWidget ${widgetId} ${deviceKey} (unsubscribe)"
    } else {
        state.subscribers[deviceKey][widgetId] = [attributes].flatten()
        log.debug "registerWidget ${widgetId} ${deviceKey} ${attributes}"
    }
}

private getWidgetURI(widgetId) {
    state.dashingURI + "/widgets/${widgetId}"
}

private notifyWidget(widgetId, data) {
    if (widgetId && state.dashingURI && state.dashingAuthToken) {
        def uri = getWidgetURI(widgetId)
        data["auth_token"] = state.dashingAuthToken
        log.debug "notifyWidget ${uri} ${data}"
        httpPostJson(uri, data)
    }
}


//
// Response Helpers
//
private respondWithStatus(status, details = null) {
    def response = ["error": status as Integer]
    if (details) {
        response["details"] = details as String
    }
    return response
}

private respondWithSuccess() {
    return respondWithStatus(0)
}
