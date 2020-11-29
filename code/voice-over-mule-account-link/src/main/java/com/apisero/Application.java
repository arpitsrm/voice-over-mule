package com.apisero;

import java.security.InvalidKeyException;
import java.security.SignatureException;
import java.util.Calendar;
import java.util.List;

import com.google.common.collect.Lists;
import com.google.gson.JsonObject;

import net.oauth.jsontoken.JsonToken;
import net.oauth.jsontoken.JsonTokenParser;
import net.oauth.jsontoken.crypto.HmacSHA256Signer;
import net.oauth.jsontoken.crypto.HmacSHA256Verifier;
import net.oauth.jsontoken.crypto.SignatureAlgorithm;
import net.oauth.jsontoken.crypto.Verifier;
import net.oauth.jsontoken.discovery.VerifierProvider;
import net.oauth.jsontoken.discovery.VerifierProviders;

public class Application {
	private static final String AUDIENCE = "Mulesoft";
	 
    private static final String ISSUER = "ISN";
 
    private static final String SIGNING_KEY = "Arpit@6030m";
 
    /**
     * Creates a json web token which is a digitally signed token that contains a payload (e.g. userId to identify 
     * the user). The signing key is secret. That ensures that the token is authentic and has not been modified.
     * Using a jwt eliminates the need to store authentication session information in a database.
     * @param userId
     * @param durationDays
     * @return
     */
    public static String createCode(String apAccessToken, String username, String password, String email, String userId)    {
        //Current time and signing algorithm
        Calendar cal = Calendar.getInstance();
        HmacSHA256Signer signer;
        try {
            signer = new HmacSHA256Signer(ISSUER, null, SIGNING_KEY.getBytes());
        } catch (InvalidKeyException e) {
            throw new RuntimeException(e);
        }
 
        //Configure JSON token
        JsonToken token = new net.oauth.jsontoken.JsonToken(signer);
        token.setAudience(AUDIENCE);
        token.setIssuedAt(new org.joda.time.Instant(cal.getTimeInMillis()));
        token.setExpiration(new org.joda.time.Instant(cal.getTimeInMillis() + 1000L * 60L * 60L * 24L * 1));
 
        //Configure request object, which provides information of the item
        JsonObject request = new JsonObject();
        request.addProperty("apAccessToken", apAccessToken);
        request.addProperty("username", username);
        request.addProperty("password", password);
        request.addProperty("email", email);
        request.addProperty("userId", userId);
        
 
        JsonObject payload = token.getPayloadAsJsonObject();
        payload.add("info", request);
 
        try {
            return token.serializeAndSign();
        } catch (SignatureException e) {
            throw new RuntimeException(e);
        }
    }
 
    /**
     * Verifies a json web token's validity and extracts the user id and other information from it. 
     * @param token
     * @return
     * @throws SignatureException
     * @throws InvalidKeyException
     */
    public static CodeInfo verifyCode(String token)  
    {
        try {
            final Verifier hmacVerifier = new HmacSHA256Verifier(SIGNING_KEY.getBytes());
 
            VerifierProvider hmacLocator = new VerifierProvider() {
 
                @Override
                public List<Verifier> findVerifier(String id, String key){
                    return Lists.newArrayList(hmacVerifier);
                }
            };
            VerifierProviders locators = new VerifierProviders();
            locators.setVerifierProvider(SignatureAlgorithm.HS256, hmacLocator);
            net.oauth.jsontoken.Checker checker = new net.oauth.jsontoken.Checker(){
 
                @Override
                public void check(JsonObject payload) throws SignatureException {
                    // don't throw - allow anything
                }
 
            };
            //Ignore Audience does not mean that the Signature is ignored
            JsonTokenParser parser = new JsonTokenParser(locators,
                    checker);
            JsonToken jt;
            try {
                jt = parser.verifyAndDeserialize(token);
            } catch (SignatureException e) {
                throw new RuntimeException(e);
            }
            JsonObject payload = jt.getPayloadAsJsonObject();
            CodeInfo t = new CodeInfo();
            String issuer = payload.getAsJsonPrimitive("iss").getAsString();
            String apAccessToken =  payload.getAsJsonObject("info").getAsJsonPrimitive("apAccessToken").getAsString();
            String username =  payload.getAsJsonObject("info").getAsJsonPrimitive("username").getAsString();
            String password =  payload.getAsJsonObject("info").getAsJsonPrimitive("password").getAsString();
            String userId =  payload.getAsJsonObject("info").getAsJsonPrimitive("userId").getAsString();
            String email =  payload.getAsJsonObject("info").getAsJsonPrimitive("email").getAsString();
            if (issuer.equals(ISSUER) )
            {
                t.setApAccessToken(apAccessToken);
                t.setPassword(password);
                t.setUsername(username);
                t.setUserId(userId);
                t.setEmail(email);
              //  t.setIssued(new DateTime(payload.getAsJsonPrimitive("iat").getAsLong()));
             //   t.setExpires(new DateTime(payload.getAsJsonPrimitive("exp").getAsLong()));
                return t;
            }
            else
            {
                return null;
            }
        } catch (InvalidKeyException e1) {
            throw new RuntimeException(e1);
        }
    }
    
    
    /**
     * Creates a json web token which is a digitally signed token that contains a payload (e.g. userId to identify 
     * the user). The signing key is secret. That ensures that the token is authentic and has not been modified.
     * Using a jwt eliminates the need to store authentication session information in a database.
     * @param userId
     * @param durationDays
     * @return
     */
    public static String createToken(String apAccessToken)    {
        //Current time and signing algorithm
        Calendar cal = Calendar.getInstance();
        HmacSHA256Signer signer;
        try {
            signer = new HmacSHA256Signer(ISSUER, null, SIGNING_KEY.getBytes());
        } catch (InvalidKeyException e) {
            throw new RuntimeException(e);
        }
 
        //Configure JSON token
        JsonToken token = new net.oauth.jsontoken.JsonToken(signer);
        token.setAudience(AUDIENCE);
        token.setIssuedAt(new org.joda.time.Instant(cal.getTimeInMillis()));
        token.setExpiration(new org.joda.time.Instant(cal.getTimeInMillis() + 1000L * 60L * 60L * 24L * 1));
 
        //Configure request object, which provides information of the item
        JsonObject request = new JsonObject();
        request.addProperty("apAccessToken", apAccessToken);
        
 
        JsonObject payload = token.getPayloadAsJsonObject();
        payload.add("info", request);
 
        try {
            return token.serializeAndSign();
        } catch (SignatureException e) {
            throw new RuntimeException(e);
        }
    }
 
    /**
     * Verifies a json web token's validity and extracts the user id and other information from it. 
     * @param token
     * @return
     * @throws SignatureException
     * @throws InvalidKeyException
     */
    public static CodeInfo verifyToken(String token)  
    {
        try {
            final Verifier hmacVerifier = new HmacSHA256Verifier(SIGNING_KEY.getBytes());
 
            VerifierProvider hmacLocator = new VerifierProvider() {
 
                @Override
                public List<Verifier> findVerifier(String id, String key){
                    return Lists.newArrayList(hmacVerifier);
                }
            };
            VerifierProviders locators = new VerifierProviders();
            locators.setVerifierProvider(SignatureAlgorithm.HS256, hmacLocator);
            net.oauth.jsontoken.Checker checker = new net.oauth.jsontoken.Checker(){
 
                @Override
                public void check(JsonObject payload) throws SignatureException {
                    // don't throw - allow anything
                }
 
            };
            //Ignore Audience does not mean that the Signature is ignored
            JsonTokenParser parser = new JsonTokenParser(locators,
                    checker);
            JsonToken jt;
            try {
                jt = parser.verifyAndDeserialize(token);
            } catch (SignatureException e) {
                throw new RuntimeException(e);
            }
            JsonObject payload = jt.getPayloadAsJsonObject();
            CodeInfo t = new CodeInfo();
            String issuer = payload.getAsJsonPrimitive("iss").getAsString();
            String apAccessToken =  payload.getAsJsonObject("info").getAsJsonPrimitive("apAccessToken").getAsString();
            if (issuer.equals(ISSUER) )
            {
                t.setApAccessToken(apAccessToken);
              //  t.setIssued(new DateTime(payload.getAsJsonPrimitive("iat").getAsLong()));
            //    t.setExpires(new DateTime(payload.getAsJsonPrimitive("exp").getAsLong()));
                return t;
            }
            else
            {
                return null;
            }
        } catch (InvalidKeyException e1) {
            throw new RuntimeException(e1);
        }
    }
    

	/*
	 * public static String createJWTToken(String accessToken) {
	 * 
	 * }
	 */
}
