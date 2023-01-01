package com.taskmgmt.entity;

public class GenericResponse<T>{

	
	private String message;
	
	private boolean status = true;
	
	private T payload;

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public boolean isStatus() {
		return status;
	}

	public void setStatus(boolean status) {
		this.status = status;
	}

	public T getPayload() {
		return payload;
	}

	public void setPayload(T payload) {
		this.payload = payload;
	}

	public GenericResponse() {
		
	}
	public GenericResponse(String message, boolean status, T payload) {
		super();
		this.message = message;
		this.status = status;
		this.payload = payload;
	}

	
	@Override
	public String toString() {
		return "GenericResponse [message=" + message + ", status=" + status + ", payload=" + payload + "]";
	}
	
	
}
