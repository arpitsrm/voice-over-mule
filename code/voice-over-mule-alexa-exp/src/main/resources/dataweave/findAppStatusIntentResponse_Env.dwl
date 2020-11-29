%dw 2.0
output application/json skipNullOn="everywhere"
var aplData = readUrl("classpath://templates/app_list/data.json", "application/json")
var orgId = vars.vOrgId
var envId = vars.vEnvId
var orgName = vars.vOrgName
var envName = vars.vEnvName

var appList = (flatten(((flatten(vars.vMasterMap.idMapping..environments) default []) filter ((item, index) -> (item.orgId == orgId and item.envId == envId))).apps default [])..appName default [])
//var appList = (flatten(vars.vMasterMap.idMapping..environments) default [] filter ((item, index) -> 
//
//item.orgId == (orgId and item.envId == (flatten(payload.request.intent.slots.environment.resolutions.resolutionsPerAuthority..values)..value..id default [])[0] default ""
//
//)).apps..appName
var appsExists = (sizeOf(appList) default 0) > 0
var speakText = (appList map ((item, index) -> (index + 1) ++ ". " ++ "<say-as interpret-as='spell-out'>" ++ item ++ "</say-as>") joinBy  ", ")


---
{
	"version": payload.version,
	"sessionAttributes": payload.session.attributes default {} ++ {
		"envName": envName,
		"envId": envId,
		"orgName": orgName,
		"orgId": orgId,
		"fromIntent": "FindAppStatusIntent",
		"toIntent": "FindAppStatusIntent"
	},
	"response": {
		"outputSpeech": {
			"type": "SSML",
			"ssml": 
						if(vars.vTokenPayload.display == "true") 
							if(appsExists) 
								("<speak>Ok. There are total of " ++ sizeOf(appList) default "0" ++ " applications in " ++ orgName ++ "organization under " ++ envName ++ "environment. Why dont you select it from the displayed list on your screen? You can also help me find your app by saying, search for, followed by the app keyword.</speak>") 
							else ("<speak>There are no applications in " ++ (orgName default "") ++ "organization under " ++ (envName default "") ++ "environment. Would you like to retry by changing the business organization?</speak>")						
						else 
							if(appsExists) 
								("<speak>Ok. There are total of " ++ sizeOf(appList) default "0" ++ " applications in " ++ payload.request.intent.slots.organization.value default "" ++ "organization under " ++ payload.request.intent.slots.environment.value default "" ++ "environment. You can help me find your app by saying, search for, followed by the app keyword.</speak>") 
								else ("<speak>There are no applications in " ++ (orgName default "") ++ "organization under " ++ (envName default "") ++ "environment. Would you like to retry by changing the business organization?</speak>")
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
									"intentName": "FindAppStatusIntent",
									"orgName": payload.session.attributes.orgName,
									"orgId": payload.session.attributes.orgId,
									"envName": payload.request.intent.slots.environment.value,
									"envId": envId 	
								}],
								"components": ["FindAppStatusIntent"]
							}]
						})
					}
				}
			}).datasources
		}) if(vars.vTokenPayload.display == "true" and appsExists),
		
		({
			"type": "Dialog.ElicitSlot",
			"slotToElicit": "appName",
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
						"confirmationStatus": "NONE"
					},
					"appIdentifier": {
						"name": "appIdentifier",
						"confirmationStatus": "NONE"
					}
				}
			}
		}) if(appsExists),
		
		(
			{
			"type": "Dialog.ElicitSlot",
			"slotToElicit": "yes_no",
			"updatedIntent": {
				"name": "YesNoIntent",
				"confirmationStatus": "NONE",
				"slots": {
					"yes_no": {
						"name": "yes_no",
						"confirmationStatus": "NONE"
					}
				}
			}
		}
		) if(!appsExists)
		
		],
		"shouldEndSession": false
	}
}