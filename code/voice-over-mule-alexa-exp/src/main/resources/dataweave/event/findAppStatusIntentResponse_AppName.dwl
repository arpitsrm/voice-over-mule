%dw 2.0
output application/json
var aplData = readUrl("classpath://templates/app_list/data.json", "application/json")

var searchTerm = (payload.request.intent.slots.appName.value replace " " with "")
var appList = (((flatten(vars.vMasterMap.idMapping..environments) default [] filter ((item, index) -> 

item.orgId == (flatten(payload.request.intent.slots.organization.resolutions.resolutionsPerAuthority..values)..value..id default [])[0] default "" and item.envId == (flatten(payload.request.intent.slots.environment.resolutions.resolutionsPerAuthority..values)..value..id default [])[0] default "")).apps..appName) default []) filter ((item, index) -> upper(item) contains upper(searchTerm))
var speakAppListText = (appList map ((item, index) -> (index + 1) ++ ". " ++ "<say-as interpret-as='spell-out'>" ++ item ++ "</say-as>") joinBy  ", ")
var speakText = if(vars.vTokenPayload.display == "true") (
	if ( sizeOf(appList) == 0 ) ("<speak>" ++ "There were no applications found for the search word" ++ searchTerm ++ ". Please mention the app number, or you can chose it from the list. You can say app number, followed by the app number." ++ "</speak>")
else ("<speak>" ++ "I found " ++ sizeOf(appList) ++ " applications with the provided search name: " ++ searchTerm ++ ". The apps are " ++ speakAppListText ++ ". Please choose the app from the list or say the number associated with it. You can say app number, followed by the app Number." ++ "</speak>")
	
)
else (
	if ( sizeOf(appList) == 0 ) ("<speak>" ++ "There were no applications found for the search word" ++ searchTerm ++ ". Please mention the app number. You can say app number, followed by the app number." ++ "</speak>")
else ("<speak>" ++ "I found " ++ sizeOf(appList) ++ " applications with the provided search name: " ++ searchTerm ++ ". The apps are " ++ speakAppListText ++ ". Please say the number associated with it. You can say app number, followed by the app Number." ++ "</speak>")
	
)
---
{
	"version": payload.version,
	"sessionAttributes": (payload.session.attributes default {}) ++ {
		"appList": appList
	},
	"response": {
		"outputSpeech": {
			"type": "SSML",
			"ssml": speakText
		},
		"directives": [
			({
			"type": "Alexa.Presentation.APL.RenderDocument",
			"token": "FindAppStatusIntent",
			"document": {
				"src": "doc://alexa/apl/documents/list_apps",
				"type": "Link"
			},
			"datasources": (aplData update {
				case data at .datasources -> data update {
					case dataList at .textListData -> dataList update {
						case .listItems -> appList map ((item, index) -> {
							"primaryText": item,
							"primaryAction": [{
								"type": "SendEvent",
								"arguments": [{
									"orgName": payload.session.attributes.orgName,
									"orgId": payload.session.attributes.orgId,
									"envName": payload.session.attributes.envName,
									"envId": payload.session.attributes.envId,
									"apps": appList
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
			"slotToElicit": "appIdentifier",
			"updatedIntent": {
				"name": "FindAppStatusIntent",
				"confirmationStatus": "NONE",
				"slots": {
					"environment": {
						"name": payload.request.intent.slots.environment.name,
						"value": payload.request.intent.slots.environment.value,
						"confirmationStatus": payload.request.intent.slots.environment.confirmationStatus
					},
					"organization": {
						"name": payload.request.intent.slots.organization.name,
						"value": payload.request.intent.slots.organization.value,
						"confirmationStatus": payload.request.intent.slots.organization.confirmationStatus
					},
					"appName": {
						"name": payload.request.intent.slots.appName.name,
						("value": payload.request.intent.slots.appName.value) if(payload.request.intent.slots.appName.value != null),
						"confirmationStatus": payload.request.intent.slots.appName.confirmationStatus
					},
					"appIdentifier": {
						"name": payload.request.intent.slots.appIdentifier.name,
						("value": payload.request.intent.slots.appIdentifier.value) if(payload.request.intent.slots.appIdentifier.value != null),
						"confirmationStatus": payload.request.intent.slots.organization.confirmationStatus
					}
				}
			}
		}],
		"shouldEndSession": false
	}
}