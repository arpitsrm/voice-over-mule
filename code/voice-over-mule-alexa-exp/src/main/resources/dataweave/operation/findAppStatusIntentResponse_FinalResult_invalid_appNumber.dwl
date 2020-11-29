%dw 2.0
output application/json skipNullOn="everywhere"
var aplData = readUrl("classpath://templates/operation_list/data.json", "application/json")

var appList = (((flatten(vars.vMasterMap.idMapping..environments) default []) filter ((item, index) -> 

(item.orgId == ((payload.request.arguments[0] default {}).orgId) and (item.envId == payload.request.arguments[0].envId)

)
)).apps default [])..appName




// var speakText = (appList map ((item, index) -> (index + 1) ++ ". " ++ "<say-as interpret-as='spell-out'>" ++ item ++ "</say-as>") joinBy  ", ")


---
{
	"version": payload.version,
	"sessionAttributes": (payload.session.attributes default {}) ++ {
		"appSearchWord": lower(vars.vSearchTerm)
	},
	"response": {
		"outputSpeech": {
			"type": "SSML",
			"ssml": "You provided an invalid app Number. Please provide a valid one. You can say, app number one, to choose the first app."
		},
		"directives": [
			({
			"type": "Alexa.Presentation.APL.RenderDocument",
			"token": "AppOperationsIntent",
			"document": {
				"src": "doc://alexa/apl/documents/list_apps",
				"type": "Link"
			},
			"datasources": (aplData update {
				case data at .datasources -> data update {
					case dataList at .textListData -> dataList update {
						case .listItems -> vars.vAppList map ((item, index) -> {
							"primaryText": item,
							"primaryAction": [{
								"type": "SendEvent",
								"arguments": [{
									"intentName": "AppOperationsIntent",
									"orgName": orgName,
									"orgId": orgId,
									"envName": envName,
									"envId": envId
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
			"slotToElicit": "appIdentifier",
			"updatedIntent": {
				"name": "AppOperationsIntent",
				"confirmationStatus": "NONE",
				"slots": {
					"environment": {
						"name": "environment",
						"value": payload.request.intent.slots.environment.value,
						"confirmationStatus": "NONE"
					},
					"organization": {
						"name": "organization",
						"value": payload.request.intent.slots.organization.value,
						"confirmationStatus": "NONE"
					},
					"appName": {
						"name": "appName",
						("value": payload.request.intent.slots.appName.value) if(payload.request.intent.slots.appName.value != null),
						"confirmationStatus": "NONE"
					},
					"appIdentifier": {
						"name": "appIdentifier",
						("value": payload.request.intent.slots.appIdentifier.value) if(payload.request.intent.slots.appIdentifier.value != null),
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