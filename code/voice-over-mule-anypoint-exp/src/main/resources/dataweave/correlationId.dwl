%dw 2.0
output application/java
---
if(attributes.headers['xh-transaction-id'] != null)(
    attributes.headers['xh-transaction-id']
)
else (correlationId)