package com.taskmgmt.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

@Entity
@Table(name = "users")
public class User {

	@NotBlank
	@Size(max = 20)
	@Id
	@Column(unique = true)
	private String userName;

	@NotBlank
	@Size(max = 50)
	@Email
	@Column(unique = true)
	private String emailAddress;

	@NotBlank
	@Size(max = 120)
	private String password;

	private String role;

	private boolean enabled;
	
	@NotBlank
	@Size(max = 50,min =5)
	@Column(unique = true)
	private String fullName;


	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public String getEmailAddress() {
		return emailAddress;
	}

	public void setEmailAddress(String emailAddress) {
		this.emailAddress = emailAddress;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getRole() {
		return role;
	}

	public void setRole(String role) {
		this.role = role;
	}

	public boolean isEnabled() {
		return enabled;
	}

	public void setEnabled(boolean enabled) {
		this.enabled = enabled;
	}
	
	

	public String getFullName() {
		return fullName;
	}

	public void setFullName(String fullName) {
		this.fullName = fullName;
	}

	public User() {

	}

	public User(@NotBlank @Size(max = 20) String userName, @NotBlank @Size(max = 50) @Email String emailAddress,
			@NotBlank @Size(max = 120) String password, String role, boolean enabled,
			@NotBlank @Size(max = 50, min = 5)  String fullName) {
		super();
		this.userName = userName;
		this.emailAddress = emailAddress;
		this.password = password;
		this.role = role;
		this.enabled = enabled;
		this.fullName = fullName;
	}



}
