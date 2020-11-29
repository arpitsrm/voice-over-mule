%dw 2.0
output application/json
var aplData = readUrl("classpath://templates/launch/data.json", "application/json")


var speakText =  "Your app is currently " ++ vars.vResponse.appStatus ++ ". It is currently running on mule runtime version " ++ vars.vResponse.muleVersion ++ " and is deployed in region " ++ vars.vResponse.region ++ ". There are total of " ++ vars.vResponse.totalProps ++ " runtime properties configured. The cpu usage in the last hour has been around " ++ vars.vResponse.cpu ++ ", and the memory usage has been around" ++ vars.vResponse.memory ++ ". What else would you like to do? Perform operation, create alert, or, find app status?"

---
{
	"version": payload.version,
	"sessionAttributes": {
		"fromIntent": "FindAppStatusIntent",
		"toIntent": "LaunchIntent"
	},
	"response": {
		"outputSpeech": {
			"type":"PlainText",
			"text":  speakText
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