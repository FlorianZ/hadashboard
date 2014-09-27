/**
 *  Dashing Access
 *
 *  Copyright 2014 florianz
 *
 *	Author: florianz
 *  Contributor: bmmiller
 *
 */


//
// Definition
//
definition(
    name: "Dashing Access",
    namespace: "florianz",
    author: "florianz",
    description: "API access for Dashing dashboards.",
    category: "Convenience",
    iconUrl: "http://atulsql.com/wp-content/uploads/2014/04/icon_256.png",
    iconX2Url: "http://atulsql.com/wp-content/uploads/2014/04/icon_256.png",
    oauth: true) {
}


//
// Preferences
//
preferences {
    section("Allow access to the following things...") {
        input "switches", "capability.switch", title: "Which switches?", multiple: true, required: false
        input "temperatures", "capability.temperatureMeasurement", title: "Which temperature sensors?", multiple: true, required: false
		input "meters", "capability.powerMeter", title: "Which meters?", multiple: true, required: false
        input "presences", "capability.presenceSensor", title: "Which presence sensors?", multiple: true, required: false
        input "contacts", "capability.contactSensor", title: "Which contact sensors?", multiple: true, required: false
    }
}


//
// Mappings
//
mappings {
    path("/config") {
        action: [
            GET: "getConfig",
            POST: "postConfig"
        ]
    }
    path("/switch") {
        action: [
            GET: "getSwitch",
            POST: "postSwitch"
        ]
    }
	path("/power") {
        action: [
            GET: "getPower"
        ]
    }
    path("/temperature") {
        action: [
            GET: "getTemperature"
        ]
    }
    path("/contact") {
        action: [
            GET: "getContact"
        ]
    }
    path("/mode") {
        action: [
            GET: "getMode",
            POST: "postMode"
        ]
    }
    path("/phrase") {
        action: [
            POST: "postPhrase"
        ]
    }
    path("/weather") {
        action: [
            GET: "getWeather"
        ]
    }
    path("/presence") {
    	action: [
        	GET: "getPresence"
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
    unsubscribe()
    initialize()
}

def initialize() {
    state.dashingURI = ""
    state.dashingAuthToken = ""
    state.widgets = [
    	"presence": [:],
        "switch": [:],
        "power": [:],
        "temperature": [:],
        "mode": [],
        "contact": [:],
        ]

    subscribe(presences, "presence", presenceHandler)
    subscribe(switches, "switch", switchHandler)
    subscribe(meters, "power", meterHandler)
    subscribe(temperatures, "temperature", temperatureHandler)
    subscribe(contacts, "contact", contactHandler)
    subscribe(location, locationHandler)
}


//
// Config
//
def getConfig() {
    ["dashingURI": state.dashingURI, "dashingAuthToken": state.dashingAuthToken]
}

def postConfig() {
    state.dashingURI = request.JSON?.dashingURI
    state.dashingAuthToken = request.JSON?.dashingAuthToken
    respondWithSuccess()
}

//
// Presences
//

def getPresence() {
    def deviceId = request.JSON?.deviceId
    log.debug "getPresence ${deviceId}"

    if (deviceId) {
        registerWidget("presence", deviceId, request.JSON?.widgetId)

        def whichPresence = presences.find { it.displayName == deviceId }
        if (!whichPresence) {
            return respondWithStatus(404, "Device '${deviceId}' not found.")
        } else {
            return ["deviceId": deviceId, "state": whichPresence.currentPresence]
        }
    }

    def result = [:]
    presences.each {
        result[it.displayName] = [
            "state": it.currentPresence,
            "widgetId": state.widgets.presence[it.displayName]]}

    return result
}

def presenceHandler(evt) {
    def widgetId = state.widgets.presence[evt.displayName]
    notifyWidget(widgetId, ["state": evt.currentPresence])
}

//
// Contacts
//

def getContact() {
    def deviceId = request.JSON?.deviceId
    log.debug "getContact ${deviceId}"

    if (deviceId) {
        registerWidget("contact", deviceId, request.JSON?.widgetId)

        def whichContact = contacts.find { it.displayName == deviceId }
        if (!whichContact) {
            return respondWithStatus(404, "Device '${deviceId}' not found.")
        } else {
            return ["deviceId": deviceId, "state": whichContact.currentContact]
        }
    }

    def result = [:]
    contacts.each {
        result[it.displayName] = [
            "state": it.currentContact,
            "widgetId": state.widgets.contact[it.displayName]]}

    return result
}

def contactHandler(evt) {
    def widgetId = state.widgets.contact[evt.displayName]
    notifyWidget(widgetId, ["state": evt.value])
}

//
// Switches
//
def getSwitch() {
    def deviceId = request.JSON?.deviceId
    log.debug "getSwitch ${deviceId}"

    if (deviceId) {
        registerWidget("switch", deviceId, request.JSON?.widgetId)

        def whichSwitch = switches.find { it.displayName == deviceId }
        if (!whichSwitch) {
            return respondWithStatus(404, "Device '${deviceId}' not found.")
        } else {
            return ["deviceId": deviceId, "switch": whichSwitch.currentSwitch]
        }
    }

    def result = [:]
    switches.each {
        result[it.displayName] = [
            "state": it.currentSwitch,
            "widgetId": state.widgets.switch[it.displayName]]}

    return result
}

def postSwitch() {
    def command = request.JSON?.command
    def deviceId = request.JSON?.deviceId
    log.debug "postSwitch ${deviceId}, ${command}"

    if (command && deviceId) {
        def whichSwitch = switches.find { it.displayName == deviceId }
        if (!whichSwitch) {
            return respondWithStatus(404, "Device '${deviceId}' not found.")
        } else {
            whichSwitch."$command"()
        }
    }
    return respondWithSuccess()
}

def switchHandler(evt) {
    def widgetId = state.widgets.switch[evt.displayName]
    notifyWidget(widgetId, ["state": evt.value])
}

//
// Meters
//

def getPower() {
    def deviceId = request.JSON?.deviceId
    log.debug "getPower ${deviceId}"

    if (deviceId) {
        registerWidget("power", deviceId, request.JSON?.widgetId)

        def whichMeter = meters.find { it.displayName == deviceId }
        if (!whichMeter) {
            return respondWithStatus(404, "Device '${deviceId}' not found.")
        } else {
            return ["deviceId": deviceId, "value": whichMeter.currentValue("power")]
        }
    }

    def result = [:]
    meters.each {
        result[it.displayName] = [
            "value": it.currentValue("power"),
            "widgetId": state.widgets.power[it.displayName]]}

    return result
}

def meterHandler(evt) {
    def widgetId = state.widgets.power[evt.displayName]
    notifyWidget(widgetId, ["value": evt.value])
}

//
// Temperatures
//
def getTemperature() {
    def deviceId = request.JSON?.deviceId
    log.debug "getTemperature ${deviceId}"

    if (deviceId) {
        registerWidget("temperature", deviceId, request.JSON?.widgetId)

        def whichTemperature = temperatures.find { it.displayName == deviceId }
        if (!whichTemperature) {
            return respondWithStatus(404, "Device '${deviceId}' not found.")
        } else {
            return ["deviceId": deviceId, "value": whichTemperature.currentTemperature]
        }
    }

    def result = [:]
    temperatures.each {
        result[it.displayName] = [
            "value": it.currentTemperature,
            "widgetId": state.widgets.temperature[it.displayName]]}

    return result
}

def temperatureHandler(evt) {
    def widgetId = state.widgets.temperature[evt.displayName]
    notifyWidget(widgetId, ["value": evt.value])
}

//
// Modes
//
def getMode() {
    def widgetId = request.JSON?.widgtId
    if (widgetId) {
        if (!state['widgets']['mode'].contains(widgetId)) {
            state['widgets']['mode'].add(widgetId)
            log.debug "registerWidget for mode: ${widgetId}"
        }
    }

    log.debug "getMode"
    return ["mode": location.mode]
}

def postMode() {
    def mode = request.JSON?.mode
    log.debug "postMode ${mode}"

    if (mode) {
        setLocationMode(mode)
    }

    if (location.mode != mode) {
        return respondWithStatus(404, "Mode not found.")
    }
    return respondWithSuccess()
}

def locationHandler(evt) {
    for (i in state['widgets']['mode']) {
        notifyWidget(i, ["mode": evt.value])
    }
}

//
// Phrases
//
def postPhrase() {
    def phrase = request.JSON?.phrase
    log.debug "postPhrase ${phrase}"

    if (!phrase) {
        respondWithStatus(404, "Phrase not specified.")
    }

    location.helloHome.execute(phrase)

    return respondWithSuccess()

}

//
// Weather
//
def getWeather() {
    def feature = request.JSON?.feature
    if (!feature) {
        feature = "conditions"
    }
    return getWeatherFeature(feature)
}

//
// Widget Helpers
//
private registerWidget(deviceType, deviceId, widgetId) {
    if (deviceType && deviceId && widgetId) {
        state['widgets'][deviceType][deviceId] = widgetId
        log.debug "registerWidget ${deviceType}:${deviceId}@${widgetId}"
    }
}

private notifyWidget(widgetId, data) {
    if (widgetId && state.dashingAuthToken) {
        def uri = getWidgetURI(widgetId)
        data["auth_token"] = state.dashingAuthToken
        log.debug "notifyWidget ${uri} ${data}"
        httpPostJson(uri, data)
    }
}

private getWidgetURI(widgetId) {
    state.dashingURI + "/widgets/${widgetId}"
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
