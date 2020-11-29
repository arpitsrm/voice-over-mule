%dw 2.0
output application/json

var aplData = readUrl("classpath://templates/launch/data.json", "application/json")
---
{
	"version": "1.0",
	"response": {
		"outputSpeech": {
			"type": "PlainText",
			"text": "Welcome to Voice Over Mule " ++ (vars.vMasterMap.userInfo.firstName default "") ++ ". I am your anypoint platform voice assistant. You can find status of an app, perform operations on them, or even set up an alert. What would you like to do?"
		},
		"card": {
			"type": "Simple",
			"title": "Voice Over Mule",
			"content": "I can't help you with that. Please choose any one of the options. You can say, Find status, perform operation, or, create alert"
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