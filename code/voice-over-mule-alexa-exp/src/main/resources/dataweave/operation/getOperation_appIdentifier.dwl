%dw 2.0
output application/json

var searchTerm = (payload.request.intent.slots.appIdentifier.value)

var appList = flatten(vars.vMasterMap.idMapping..environments..apps..appName) default [] filter ((item, index) -> item contains searchTerm)

var speakAppListText = (appList map ((item, index) -> (index + 1) ++ ". " ++ "<say-as interpret-as='spell-out'>" ++ item ++ "</say-as>") joinBy  ", ")



var speakText = if ( sizeOf(appList) == 0 ) ("<speak>" ++ "I could not find any application with the search name: " ++ searchTerm ++ ". Please state the business organization under which your app lies?  </speak>")
else ("<speak>" ++ "I found " ++ sizeOf(appList) ++ " applications with the provided search name: " ++ searchTerm ++ ". The apps are " ++ speakAppListText ++ ". Please choose the app from the list or say the number associated with it. You can say app number, followed by the app Number." ++ "</speak>")



---
if(sizeOf(appList) == 0 ) (
{
	"version": payload.version,
	"sessionAttributes": {
	},
	"response": {
		"outputSpeech": {
			"type": "SSML",
			"ssml": speakText
		},
		"directives": [{
			"type": "Dialog.ElicitSlot",
			"slotToElicit": "organization",
			"updatedIntent": {
				"name": payload.request.intent.name,
				"confirmationStatus": "NONE",
				"slots": payload.request.intent.slots
			}
		}],
		"shouldEndSession": false
	}
}
)
else (
{
	"version": payload.version,
	"sessionAttributes": {
	},
	"response": {
		"outputSpeech": {
			"type": "SSML",
			"ssml": speakText
		},
		"directives": [{
			"type": "Dialog.ElicitSlot",
			"slotToElicit": "appIdentifier",
			"updatedIntent": {
				"name": "FindAppStatusIntent",
				"confirmationStatus": "NONE",
				"slots": payload.request.intent.slots
			}
		}],
		"shouldEndSession": false
	}
}
)