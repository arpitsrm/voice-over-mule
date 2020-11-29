%dw 2.0
output application/json skipNullOn="everywhere"
var aplData = readUrl("classpath://templates/app_list/data.json", "application/json")

var envName = if(payload.session.attributes.envName?)(payload.session.attributes.envName) else  payload.request.intent.slots.environment.value
var orgName = if(payload.session.attributes.orgName?)(payload.session.attributes.orgName) else (payload.request.intent.slots.organization.value)
var orgId = vars.vOrgId
var envId = vars.vEnvId
var speakAppListText = (vars.vAppList map ((item, index) -> (index + 1) ++ ". " ++ "" ++ item ++ "") joinBy  ", ")
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
		"appSearchWord": lower(vars.vSearchTerm)
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
						case .listItems -> vars.vAppList map ((item, index) -> {
							"primaryText": item,
							"primaryAction": [{
								"type": "SendEvent",
								"arguments": [{
									"intentName": "FindAppStatusIntent",
									"orgName": orgName,
									"orgId": orgId,
									"envName": envName,
									"envId": envId
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
						"value": if(payload.request.intent.slots.appName.value != null) (payload.request.intent.slots.appName.value) else (payload.session.attributes.appName),
						"confirmationStatus": "NONE"
					},
					"appIdentifier": {
						"name": "appIdentifier",
						"value": if(payload.request.intent.slots.appIdentifier.value != null) (payload.request.intent.slots.appIdentifier.value) else (payload.session.attributes.appIdentifier) ,
						"confirmationStatus": "NONE"
					}
				}
			}
		}],
		"shouldEndSession": false
	}
}