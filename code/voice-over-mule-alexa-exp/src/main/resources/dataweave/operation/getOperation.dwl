%dw 2.0
output application/json

var aplData = readUrl("classpath://templates/operation_list/data.json", "application/json")
var orgList = vars.vMasterMap.idMapping map ((item, index) -> 
	{
	"name":item.name,
	"id": item.id	
}
)
---
{
	"version": payload.version,
	"sessionAttributes": {
	},
	"response": {
		"outputSpeech": {
			"type": "PlainText",
			"text": if(vars.vTokenPayload.display == "true") ("Please state the required operation. You can say, start, stop, or, restart, or You can select it from the list.") else ("Please state the required operation. You can say, start, stop, or, restart.")
		},
		"directives": [({
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
				"slots":(payload.request.intent.slots) default {}
			}
		}],
		"shouldEndSession": false
	}
}