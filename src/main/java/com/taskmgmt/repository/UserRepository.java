package com.taskmgmt.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.taskmgmt.model.User;

public interface UserRepository extends JpaRepository<User, String> {

	Optional<User> findByUserName(String userName);

	Boolean existsByUserName(String userName);

	Boolean existsByEmailAddress(String email);

	List<User> findByRole(String role);
	
	List<User> findByUserNameNot(String userName);
	

}
