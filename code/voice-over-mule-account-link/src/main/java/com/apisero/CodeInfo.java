package com.apisero;

import org.joda.time.DateTime;

public class CodeInfo {
	private String username;
	private String userId;
	private String email;
	private String password;
	private String apAccessToken;
	private DateTime issued;
	private DateTime expires;

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getApAccessToken() {
		return apAccessToken;
	}

	public void setApAccessToken(String apAccessToken) {
		this.apAccessToken = apAccessToken;
	}

	public DateTime getIssued() {
		return issued;
	}

	public void setIssued(DateTime issued) {
		this.issued = issued;
	}

	public DateTime getExpires() {
		return expires;
	}

	public void setExpires(DateTime expires) {
		this.expires = expires;
	}

	public String getUserId() {
		return userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

}