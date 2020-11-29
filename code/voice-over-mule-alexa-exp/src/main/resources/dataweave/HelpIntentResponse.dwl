%dw 2.0
output application/json

var aplData = readUrl("classpath://templates/launch/data.json", "application/json")
---
{
	"version": "1.0",
	"response": {
		"outputSpeech": {
			"type": "PlainText",
			"text": "You can say perform operation, find app status, or, create an alert. You can also exit the skill anytime by saying stop or cancel. Create Alert use case is not yet completed. What would you like to do? "
		},
		"card": {
			"type": "Simple",
			"title": "Voice Over Mule",
			"content": "You can say perform operation, find app status, or, create an alert. You can also exit the skill anytime by saying stop or cancel. Create Alert use case is not yet completed. What would you like to do? "
		},
		"reprompt": {
			"outputSpeech": {
				"type": "PlainText",
				"text": "Can I help you with anything else?"
			}
		},
		"directives": [
			({
			"type": "Alexa.Presentation.APL.RenderDocument",
			"token": "LaunchIntent",
			"document": {
				"src": "doc://alexa/apl/documents/mainCategory",
				"type": "Link"
			},
			"datasources": aplData.datasources
		}) if(vars.vTokenPayload.display == "true")
		],
		"shouldEndSession": false
	}
}