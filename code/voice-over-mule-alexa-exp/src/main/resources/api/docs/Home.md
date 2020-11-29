# **MRC Global PoC Template**

## **Overview**
 - Replace this with Overview of the API
 
## **Prerequisites**
- For version v1.0 :
  - Use **HTTP Basic authentication** to verify authorization.
    - Note: **Please contact the Integration Team for user login credentials**
  - Communicate using **HTTPS**
  - TLS v1.1 or latest
  - Must use **`application/json`** for all the payload content-type
  

## **Payload requirements**
- All Field names specified in JSON requests and responses
- Pricing information is not allowed to be sent to *MRC Global*
- All APIs will use the REST architecture style
- All APIs must be able to accept at least 200 records per transaction, but must be - run in real time..
- Daily limits must be set to control the load on the API server

## **Data Verification/Validation**
- The API validates the data in real time and returns a "human readable" error message to easily resolve the error.
- The following validation rules should be implemented in the MRC Global
  - Date/times must be received according to ISO8601 standards for example, **`10/20/2018`** at **`2:30pm CST`** would be represented as **`2018-10-20T02:30:00-06:00`**
    - *Example:*
      - **From:**
        ```
        10/20/2018 at 2:30pm CST    
        ```
      - **To:**
        ```
        2018-10-20T02:30:00-06:00    
        ```
  - Currency data should not be transmitted or sent.
  - Must receive numbers in Western characters, for example **`1,2,3,4,5,6,7,8,9,0`**
  - The number must be received in standard decimal format, for example **`NNNNNN.NN`**. 

## **Header Requirements**
- The following headers must be defined on each request:
  - `x-client-id`
  - `x-client-secret`
  - `x-transaction-id`
  - `Content-Type`
  
## **Security & Authentication**
- All MRC Global APIs will use **TLS 1.1** or higher.
- API authentication requires mutual authentication** (two-way SSL)**.


  