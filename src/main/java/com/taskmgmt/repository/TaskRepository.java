package com.taskmgmt.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.taskmgmt.model.Task;

public interface TaskRepository extends JpaRepository<Task, Integer> {

	List<Task> findAllByUserId(String userId);
}
