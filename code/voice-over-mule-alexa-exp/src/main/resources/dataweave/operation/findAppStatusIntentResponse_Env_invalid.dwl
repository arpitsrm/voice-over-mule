%dw 2.0
output application/json
var aplData = readUrl("classpath://templates/env_list/data.json", "application/json")
var envList = (flatten((vars.vMasterMap.idMapping default [])..environments) default []) map ((item, index) -> 
	{
	"name":item.envName,
	"id": item.envId	
}
)
var orgId = vars.vOrgId
var orgName = vars.vOrgName
---
{
	"version": payload.version,
	"sessionAttributes": {
		"orgName": orgName,
		"orgId": orgId
		
	},
	"response": {
		"outputSpeech": {
			"type": "PlainText",
			"text": if(vars.vTokenPayload.display == "true") ("You provided an invalid environment. Can you tell me the environment under " ++ orgName ++ " organization? You can select it from the list.") else ("You provided an invalid environment. Can you tell me the environment under " ++ orgName ++ " organization?")
		},
		"directives": [
			
			({
			"type": "Alexa.Presentation.APL.RenderDocument",
			"token": "AppOperationsIntent",
			"document": {
				"src": "doc://alexa/apl/documents/list_env",
				"type": "Link"
			},
			"datasources": (aplData update {
				case data at .datasources -> data update {
					case dataList at .textListData -> dataList update {
						case .listItems -> envList map ((item, index) -> {
							"primaryText": item.name,
							"primaryAction": [{
								"type": "SendEvent",
								"arguments": [{
									"intentName": "AppOperationsIntent",
									"orgName": orgName,
									"orgId": orgId,
									"envName": item.envName,
									"envId": item.envId 	
								}],
								"components": ["AppOperationsIntent"]
							}]
						})
					}
				}
			}).datasources
		}) if(vars.vTokenPayload.display == "true"),
			
			{
			"type": "Dialog.ElicitSlot",
			"slotToElicit": "environment",
			"updatedIntent": {
				"name": "AppOperationsIntent",
				"confirmationStatus": payload.request.intent.confirmationStatus,
				"slots": {
					"environment": {
						"name": "environment",
						"confirmationStatus": "NONE"
					},
					"organization": {
						"name": "organization",
						"value": orgName,
						"confirmationStatus": "NONE"
					},
					"appName": {
						"name": "appName",
						"value": if(payload.request.intent.slots.appName.value != null) (payload.request.intent.slots.appName.value) else (payload.session.attributes.appName),
						"confirmationStatus": "NONE"
					},
					"appIdentifier": {
						"name": "appIdentifier",
						"value": if(payload.request.intent.slots.appIdentifier.value != null) (payload.request.intent.slots.appIdentifier.value) else (payload.session.attributes.appIdentifier),
						"confirmationStatus": "NONE"
					},
					"operation": {
						"name": "operation",
						"confirmationStatus": "NONE"
					}
				}
			}
		}],
		"shouldEndSession": false
	}
}