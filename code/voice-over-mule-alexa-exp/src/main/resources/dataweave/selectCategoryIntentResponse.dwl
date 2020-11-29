%dw 2.0
output application/json
---
{
	"version": ("1.0" default ""),
	"response": {
		"outputSpeech": {
			"type": "PlainText",
			"text": "Alright. You can find status of your app, start, stop, restart them or even set up an alert. What would you like to do?"
		},
		"card": {
			"type": "Simple",
			"title": "Voice Over Mule",
			"content": "Alright. You can find status of your app, start, stop, restart them or even set up an alert. What would you like to do?"
		},
		"reprompt": {
			"outputSpeech": {
				"type": "PlainText",
				"text": "Can I help you with anything else?"
			}
		},
		"shouldEndSession": false
	}
}