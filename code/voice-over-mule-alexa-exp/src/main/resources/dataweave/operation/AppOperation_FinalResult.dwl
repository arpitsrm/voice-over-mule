%dw 2.0
output application/json
var aplData = readUrl("classpath://templates/launch/data.json", "application/json")

---
{
	"version": payload.version,
	"sessionAttributes": {
		"fromIntent": "AppOperationsIntent",
		"toIntent": "LaunchIntent"
	},
	"response": {
		"outputSpeech": {
			"type":"PlainText",
			"text":  "The app was successfully " ++ vars.vOperation ++ "ed. What else would you like to do? Find status, perform operation, or, create an alert"
		},
		"shouldEndSession": false
	},
	"directives": [({
			"type": "Alexa.Presentation.APL.RenderDocument",
			"token": "LaunchIntent",
			"document": {
				"src": "doc://alexa/apl/documents/mainCategory",
				"type": "Link"
			},
			"datasources": aplData.datasources
		}) if(vars.vTokenPayload.display == "true")
		
		]
}