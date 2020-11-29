%dw 2.0
output application/json
var aplData = readUrl("classpath://templates/app_list/data.json", "application/json")

var orgName = if(payload.session.attributes.orgName?) (payload.session.attributes.orgName) else payload.request.arguments[0].orgName
var orgId = if(payload.session.attributes.orgId?) (payload.session.attributes.orgId) else payload.request.arguments[0].orgId
var envName = if(payload.session.attributes.envName?) (payload.session.attributes.envName) else payload.request.arguments[0].envName
var envId = if(payload.session.attributes.envId?) (payload.session.attributes.envId) else payload.request.arguments[0].envId
		
var appList = (flatten(((flatten(vars.vMasterMap.idMapping..environments) default []) filter ((item, index) -> (item.orgId == orgId and item.envId == envId))).apps default [])..appName default [])

var appsExists = (sizeOf(appList) default 0) > 0



---
{
	"version": payload.version,
	"sessionAttributes": {
		"orgName": orgName,
		"orgId": orgId,
		"envName": envName,
		"envId": envId,
		"fromIntent": "FindAppStatusIntent",
		"toIntent": "FindAppStatusIntent"
		
	},
	"response": {
		"outputSpeech": {
			"type":"PlainText",
			"text": 
						if(vars.vTokenPayload.display == "true")
							if(!appsExists) 
								("There are no applications in " ++ orgName default "" ++ "organization under " ++ envName default "" ++ "environment. Would you like to retry by changing the business organization?") 
							else
								("Ok. There are total of " ++ sizeOf(appList) default "0" ++ " applications in " ++ orgName default "" ++ "organization under " ++ envName default "" ++ "environment. Why dont you select it from the displayed list on your screen? You can also help me find your app by saying, search for, followed by the app keyword.") 
						else 
							if(appsExists) 
							("Ok. There are total of " ++ sizeOf(appList) default "0" ++ " applications in " ++ orgName default "" ++ "organization under " ++ envName default "" ++ "environment. You can help me find your app by saying, search for, followed by the app keyword.") 
							else 
							("There are no applications in " ++ orgName default "" ++ "organization under " ++ envName default "" ++ "environment. Would you like to retry by changing the business organization?") 
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
									"orgName": orgName,
									"orgId": orgId,
									"envName": envName,
									"envId": envId,
									"appName": item
								}],
								"components": ["FindAppStatusIntent"]
							}]
						})
					}
				}
			}).datasources
		}) if(vars.vTokenPayload.display == "true"),
		
		(
			{
			"type": "Dialog.ElicitSlot",
			"slotToElicit": "appName",
			"updatedIntent": {
				"name": "FindAppStatusIntent",
				"confirmationStatus": "NONE",
				"slots": {
					"environment": {
						"name": "environment",
						"confirmationStatus": "NONE",
						"value": envName
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
		}
		) if(appsExists),
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