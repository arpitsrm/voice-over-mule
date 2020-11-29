%dw 2.0
output application/json
---
{
	"version": "1.0",
	"response": {
		"outputSpeech": {
			"type": "PlainText",
			"text": "Welcome to Voice Over Mule. I am your anypoint platform voice assistant. Please select one of the Categories. You can say Runtime Manager, Alerts or add-ons"
		},
		"card": {
			"type": "Simple",
			"title": "Voice Over Mule",
			"content": "Welcome to Voice Over Mule. I am your anypoint platform voice assistant. Please select one of the Categories."
		},
		"reprompt": {
			"outputSpeech": {
				"type": "PlainText",
				"text": "Can I help you with anything else?"
			}
		},
		"directives": [{
			"type": "Dialog.UpdateDynamicEntities",
			"updateBehavior": "REPLACE",
			"types": [
				
				
				{
				"name": "organization",
				"values":  flatten(vars.vMasterMap.idMapping) default [] map ((orgItem, orgIndex) -> 
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
					"id": envItem.id,
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
			}
			
			
			
			
			]
		}],
		"shouldEndSession": false
	}
}