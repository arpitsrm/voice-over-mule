%dw 2.0
output application/json

var aplData = readUrl("classpath://templates/launch/data.json", "application/json")
---
{
	"version": "1.0",
	"response": {
		"outputSpeech": {
			"type": "PlainText",
			"text": "GoodBye!"
		},
		"card": {
			"type": "Simple",
			"title": "Voice Over Mule",
			"content": "GoodBye!"
		},
		"shouldEndSession": true
	}
}