package com.taskmgmt.model;

import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

@Entity
public class Task {

	@Id
	@GeneratedValue(strategy = GenerationType.AUTO)
	private Integer taskId;

	private String taskName;

	private String userId;

	private String taskStatus;

	private String comments;

	private Date taskStartDate;

	private Date taskCloseDate;

	public Task() {

	}

	public Task(String userId, String taskName, String taskStatus, String comments, Date taskStartDate,
			Date taskCloseDate) {
		super();
		this.taskName = taskName;
		this.taskStatus = taskStatus;
		this.comments = comments;
		this.taskStartDate = taskStartDate;
		this.taskCloseDate = taskCloseDate;
		this.userId = userId;
	}

	public Integer getTaskId() {
		return taskId;
	}

	public void setTaskId(Integer taskId) {
		this.taskId = taskId;
	}

	public String getTaskName() {
		return taskName;
	}

	public void setTaskName(String taskName) {
		this.taskName = taskName;
	}

	public String getTaskStatus() {
		return taskStatus;
	}

	public void setTaskStatus(String taskStatus) {
		this.taskStatus = taskStatus;
	}

	public String getComments() {
		return comments;
	}

	public void setComments(String comments) {
		this.comments = comments;
	}

	public Date getTaskStartDate() {
		return taskStartDate;
	}

	public void setTaskStartDate(Date taskStartDate) {
		this.taskStartDate = taskStartDate;
	}

	public Date getTaskCloseDate() {
		return taskCloseDate;
	}

	public void setTaskCloseDate(Date taskCloseDate) {
		this.taskCloseDate = taskCloseDate;
	}

	public String getUserId() {
		return userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Override
	public String toString() {
		return "Task [taskId=" + taskId + ", taskName=" + taskName + ", userId=" + userId + ", taskStatus=" + taskStatus
				+ ", comments=" + comments + ", taskStartDate=" + taskStartDate + ", taskCloseDate=" + taskCloseDate
				+ "]";
	}

}
