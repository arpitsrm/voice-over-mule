%dw 2.0
output application/json skipNullOn="everywhere"
var aplData = readUrl("classpath://templates/operation_list/data.json", "application/json")

//var orgId1 = if(payload.session.attributes.orgId?) (payload.session.attributes.orgId) else ((flatten(payload.request.intent.slots.organization.resolutions.resolutionsPerAuthority..values)..value..id default [])[0] default "")
//var envId1 = if(payload.session.attributes.envId?) (payload.session.attributes.envId) else ((flatten(payload.request.intent.slots.environment.resolutions.resolutionsPerAuthority..values)..value..id default [])[0] default "")
//var searchTerm = if((payload.request.intent.slots.appName.value default "") contains "search for" ) trim((payload.request.intent.slots.appName.value splitBy "search for")[1] default "") else (payload.request.intent.slots.appName.value replace " " with "")
//
//
//var appList = (flatten(((flatten(vars.vMasterMap.idMapping..environments) default []) filter ((item, index) -> (item.orgId == orgId1 and item.envId == envId1))).apps default [])..appName default []) filter((item1, index1) -> upper(item1) contains upper(searchTerm))
//

var envName = if((payload.request.arguments[0] default {}).envName != null) (payload.request.arguments[0].envName) else (payload.session.attributes.envName)
var orgName = if((payload.request.arguments[0] default {}).orgName != null) (payload.request.arguments[0].orgName) else (payload.session.attributes.orgName)
var orgId = vars.vOrgId
var envId = vars.vEnvId
---
{
	"version": payload.version,
	"sessionAttributes": {
		"orgId":orgId,
		"orgName": orgName,
		"envName": envName,
		"envId": envId,
		"appName": vars.vAppName
	},
	"response": {
		"outputSpeech": {
			"type": "SSML",
			"ssml": "<speak>Please select the operation to be performed on " ++ vars.vAppName ++ ". You can say, start, stop, or, restart</speak>"
		},
		"directives": [
			({
			"type": "Alexa.Presentation.APL.RenderDocument",
			"token": "AppOperationsIntent",
			"document": {
				"src": "doc://alexa/apl/documents/list_operation",
				"type": "Link"
			},
			"datasources": aplData.datasources
		}) if(vars.vTokenPayload.display == "true"),
		
		{
			"type": "Dialog.ElicitSlot",
			"slotToElicit": "operation",
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
						"value": vars.vAppName,
						"confirmationStatus": "NONE"
					},
					"appIdentifier": {
						"name": "appIdentifier",
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