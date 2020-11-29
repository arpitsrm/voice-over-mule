%dw 2.0
output application/json
---
{
	"version": payload.version,
	"sessionAttributes": {
	},
	"response": {
		"directives": [{
			"type": "Dialog.Delegate",
			"updatedIntent": {
				"name": payload.request.intent.name,
				"confirmationStatus": payload.request.intent.confirmationStatus,
				"slots": {
					environment: {
						name: payload.request.intent.slots.environment.name,
						confirmationStatus: payload.request.intent.slots.environment.confirmationStatus
					},
					appNumber: {
						name: payload.request.intent.slots.appNumber.name,
						confirmationStatus: payload.request.intent.slots.appNumber.confirmationStatus
					},
					appName: {
						name: payload.request.intent.slots.appName.name,
						confirmationStatus: payload.request.intent.slots.appName.confirmationStatus
					},
					organization: {
						name: payload.request.intent.slots.organization.name,
						confirmationStatus: payload.request.intent.slots.organization.confirmationStatus
					}
				}
			}
		}],
		"shouldEndSession": false
	}
}