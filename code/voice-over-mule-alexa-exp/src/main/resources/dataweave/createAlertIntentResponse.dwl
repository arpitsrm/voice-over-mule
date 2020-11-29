%dw 2.0
output application/json

var aplData = readUrl("classpath://templates/launch/data.json", "application/json")
---
{
	"version": "1.0",
	"response": {
		"outputSpeech": {
			"type": "PlainText",
			"text": "I was unable to implement this use case for now. You can come back later next month to check out other updates along with this one. What else would you like to do? Perform operation or check app status?"
		},
		"card": {
			"type": "Simple",
			"title": "Voice Over Mule",
			"content": "I was unable to implement this use case for now. You can come back later next month to check out other updates along with this one. What else would you like to do? Perform operation or check app status?"
		},
		"reprompt": {
			"outputSpeech": {
				"type": "PlainText",
				"text": "Can I help you with anything else?"
			}
		},
		"directives": [({
			"type": "Alexa.Presentation.APL.RenderDocument",
			"token": "LaunchIntent",
			"document": {
				"src": "doc://alexa/apl/documents/mainCategory",
				"type": "Link"
			},
			"datasources": aplData.datasources
		}) if(vars.vTokenPayload.display == "true"),
			
			{
			"type": "Dialog.UpdateDynamicEntities",
			"updateBehavior": "REPLACE",
			"types": [{
				"name": "organization",
				"values": flatten(vars.vMasterMap.idMapping) default [] map ((orgItem, orgIndex) -> 
					{
					"id": orgItem.id,
					"name": {
						"value": orgItem.name,
						"synonyms": [orgItem.name]
					}
				}
					)
			},
						
				{
				"name": "environment",
				"values": flatten(vars.vMasterMap..environments) default [] map ((envItem, envIndex) -> 
					{
					"id": envItem.envId,
					"name": {
						"value": envItem.envName,
						"synonyms": [envItem.envName]
					}
				}
					)
			},
			{
				"name": "apps",
				"values": flatten(vars.vMasterMap..apps) default [] map ((appItem, appIndex) -> 
					{
					"id": appItem.fullDomain,
					"name": {
						"value": appItem.appName,
						"synonyms": [appItem.appName]
					}
				}
					)
			}]
		}],
		"shouldEndSession": false
	}
}