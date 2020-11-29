%dw 2.0
output application/json
var aplData = readUrl("classpath://templates/env_list/data.json", "application/json")
var envList = (flatten((vars.vMasterMap.idMapping default [])..environments) default []) default []
var orgName = if(payload.session.attributes.orgName?) (payload.session.attributes.orgName) else payload.request.arguments[0].orgName
var orgId = if(payload.session.attributes.orgId?) (payload.session.attributes.orgId) else payload.request.arguments[0].orgId
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
			"text": if(vars.vTokenPayload.display == "true") ("can you tell me the environment under " ++ orgName ++ " organization? You can select it from the list.") else ("can you tell me the environment under " ++ orgName ++ " organization?")
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
							"primaryText": item.envName,
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
				"confirmationStatus": "NONE",
				"slots": {
					"environment": {
						"name": "environment",
						"confirmationStatus": "NONE"
					},
					"organization": {
						"name": "organization",
						"confirmationStatus": "NONE",
						"value": orgName
					},
					"appName": {
						"name": "appName",
						"confirmationStatus": "NONE"
					},
					"appIdentifier": {
						"name": "appIdentifier",
						"confirmationStatus": "NONE"
					}
				}
			}
		}],
		"shouldEndSession": false
	}
}