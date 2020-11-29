%dw 2.0
output application/json skipNullOn="everywhere"

var aplData = readUrl("classpath://templates/org_list/data.json", "application/json")
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
			"text": if(vars.vTokenPayload.display == "true") ("That is an invalid Organization. Can you tell me the organization under which your app lies? You can select it from the list.") else ("You provided an invalid organization. Can you tell me the organization under which your app lies?")
		},
		"directives": [({
			"type": "Alexa.Presentation.APL.RenderDocument",
			"token": "FindAppStatusIntent",
			"document": {
				"src": "doc://alexa/apl/documents/list_org",
				"type": "Link"
			},
			"datasources": (aplData update {
				case data at .datasources -> data update {
					case dataList at .textListData -> dataList update {
						case .listItems -> orgList map ((item, index) -> {
							"primaryText": item.name,
							"primaryAction": [{
								"type": "SendEvent",
								"arguments": [{
									"intentName": "FindAppStatusIntent",
									"orgName": item.name,
									"orgId": item.id 	
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
			"slotToElicit": "organization",
			"updatedIntent": {
				"name": payload.request.intent.name,
				"confirmationStatus": payload.request.intent.confirmationStatus,
				"slots":(payload.request.intent.slots)
			}
		}],
		"shouldEndSession": false
	}
}