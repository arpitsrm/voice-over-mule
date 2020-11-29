%dw 2.0
output application/json


var speakAppListText = (appList map ((item, index) -> (index + 1) ++ ". " ++ "<say-as interpret-as='spell-out'>" ++ item ++ "</say-as>") joinBy  ", ")

var speakText = "<speak>"
++ 
if(sizeOf(vars.vAppName) == 0) ("That was an invalid number provided. Please mention the app number, or you can chose it from the list. You can say search for, followed by the app number.")
else ("You have selected" ++ vars.vAppName ++ " application. The apps are " ++ speakAppListText ++ ". Please choose the app from the list or say the number associated with it. You can say search for, followed by thr app Number.")
++  
"</speak>"
---
{
	"version": payload.version,
	"sessionAttributes": {
		"scope": "environment"
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
				"slots": {
					"environment": {
						
						"name": payload.request.intent.slots.environment.name,
						"value": payload.request.intent.slots.environment.value,
						"confirmationStatus": payload.request.intent.slots.environment.confirmationStatus
					},
					"organization": {
						"name": payload.request.intent.slots.organization.name,
						"value": payload.request.intent.slots.organization.value,
						"confirmationStatus": payload.request.intent.slots.organization.confirmationStatus
					},
					"appName": {
						"name": payload.request.intent.slots.appName.name,
						"confirmationStatus": payload.request.intent.slots.appName.confirmationStatus
					},
					"appIdentifier": {
						"name": payload.request.intent.slots.appIdentifier.name,
						"confirmationStatus": payload.request.intent.slots.organization.confirmationStatus
					}
				}
			}
		}],
		"shouldEndSession": false
	}
}