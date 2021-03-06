%dw 2.0
output application/json

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
			"text": if(vars.vTokenPayload.display == "true") ("Let's choose an app first. Can you tell me the organization under which your app lies? You can select it from the list.") else ("Let's choose an app first. Can you tell me the organization under which your app lies?")
		},
		"directives": [({
			"type": "Alexa.Presentation.APL.RenderDocument",
			"token": "AppOperationsIntent",
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
									"intentName": "AppOperationsIntent",
									"orgName": item.name,
									"orgId": item.id 	
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
			"slotToElicit": "organization",
			"updatedIntent": {
				"name": "AppOperationsIntent",
				"confirmationStatus": "NONE",
				"slots":(payload.request.intent.slots) default {}
			}
		}],
		"shouldEndSession": false
	}
}