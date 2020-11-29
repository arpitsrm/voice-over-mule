%dw 2.0
output application/json skipNullOn="everywhere"
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
			"token": "FindAppStatusIntent",
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
									"intentName": "FindAppStatusIntent",
									"orgName": orgName,
									"orgId": orgId,
									"envName": item.envName,
									"envId": item.envId 	
								}],
								"components": ["FindAppStatusIntent"]
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
				"name": "FindAppStatusIntent",
				"confirmationStatus": payload.request.intent.confirmationStatus,
				"slots": (payload.request.intent.slots) default {}
			}
		}],
		"shouldEndSession": false
	}
}