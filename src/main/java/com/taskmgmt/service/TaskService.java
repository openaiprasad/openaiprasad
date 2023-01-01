package com.taskmgmt.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.taskmgmt.model.Task;
import com.taskmgmt.repository.TaskRepository;

import javax.transaction.Transactional;
import javax.transaction.Transactional.TxType;

@Service
public class TaskService {

	@Autowired
	private TaskRepository repository;

	@Transactional(value = TxType.REQUIRES_NEW)
	public Task saveTask(final Task task) {
		return repository.save(task);
	}

	@Transactional(value = TxType.NOT_SUPPORTED)
	public List<Task> getTasks() {
		return repository.findAll();
	}
	
	@Transactional(value = TxType.NOT_SUPPORTED)
	public List<Task> getTasksByUserId(final String userId) {
		return repository.findAllByUserId(userId);
	}
}
