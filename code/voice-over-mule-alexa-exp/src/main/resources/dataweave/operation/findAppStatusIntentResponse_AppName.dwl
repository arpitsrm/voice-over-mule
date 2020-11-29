%dw 2.0
output application/json skipNullOn="everywhere"
var aplData = readUrl("classpath://templates/app_list/data.json", "application/json")

//var orgId1 = if(payload.session.attributes.orgId?) (payload.session.attributes.orgId) else ((flatten(payload.request.intent.slots.organization.resolutions.resolutionsPerAuthority..values)..value..id default [])[0] default "")
//var envId1 = if(payload.session.attributes.envId?) (payload.session.attributes.envId) else ((flatten(payload.request.intent.slots.environment.resolutions.resolutionsPerAuthority..values)..value..id default [])[0] default "")
//var searchTerm = if((payload.request.intent.slots.appName.value default "") contains "search for" ) trim((payload.request.intent.slots.appName.value splitBy "search for")[1] default "") else (payload.request.intent.slots.appName.value replace " " with "")
//
//
//var appList = (flatten(((flatten(vars.vMasterMap.idMapping..environments) default []) filter ((item, index) -> (item.orgId == orgId1 and item.envId == envId1))).apps default [])..appName default []) filter((item1, index1) -> upper(item1) contains upper(searchTerm))
//

var envName = if(payload.session.attributes.envName?)(payload.session.attributes.envName) else  payload.request.intent.slots.environment.value
var orgName = if(payload.session.attributes.orgName?)(payload.session.attributes.orgName) else (payload.request.intent.slots.organization.value)
var envId = vars.vEnvId
var orgId = vars.vOrgId


var speakAppListText = (vars.vAppList map ((item, index) -> (index + 1) ++ ". " ++ "<say-as interpret-as='spell-out'>" ++ item ++ "</say-as>") joinBy  ", ")
var speakText = if(vars.vTokenPayload.display == "true") (
	if ( sizeOf(vars.vAppList) == 0 ) ("<speak>" ++ "There were no applications found for the search word" ++ vars.vSearchTerm ++ ". Please mention the app number, or you can chose it from the list. You can say app number, followed by the app number." ++ "</speak>")
else ("<speak>" ++ "I found " ++ sizeOf(vars.vAppList) ++ " applications with the provided search name: " ++ vars.vSearchTerm ++ ". The apps are " ++ speakAppListText ++ ". Please choose the app from the list or say the number associated with it. You can say app number, followed by the app Number." ++ "</speak>")
	
)
else (
	if ( sizeOf(vars.vAppList) == 0 ) ("<speak>" ++ "There were no applications found for the search word" ++ vars.vSearchTerm ++ ". Please mention the app number. You can say app number, followed by the app number." ++ "</speak>")
else ("<speak>" ++ "I found " ++ sizeOf(vars.vAppList) ++ " applications with the provided search name: " ++ vars.vSearchTerm ++ ". The apps are " ++ speakAppListText ++ ". Please say the number associated with it. You can say app number, followed by the app Number." ++ "</speak>")
	
)
---
{
	"version": payload.version,
	"sessionAttributes": (payload.session.attributes default {}) ++ {
		"appSearchWord": lower(vars.vSearchTerm),
		"appList": vars.vAppList
	},
	"response": {
		"outputSpeech": {
			"type": "SSML",
			"ssml": speakText
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
						"value": envName,
						"confirmationStatus": "NONE"
					},
					"organization": {
						"name": "organization",
						"value": orgName,
						"confirmationStatus": "NONE"
					},
					"appName": {
						"name": "appName",
						"value": if(payload.request.intent.slots.appName.value != null) (payload.request.intent.slots.appName.value) else (payload.session.attributes.appName) ,
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