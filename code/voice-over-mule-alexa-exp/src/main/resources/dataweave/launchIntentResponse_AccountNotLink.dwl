%dw 2.0
output application/json
---
{
    "version": "1.0",
    "response": {
      "outputSpeech": {
        "type": "PlainText",
        "text": "Welcome to Voice Over Mule. You must have a Anypoint Platform account to use Voice over mule. Please use the Alexa app to link your Amazon account with your Anypoint Platform Account."
      },
      "card": {
        "type": "LinkAccount"
      }
    }
}