package com.taskmgmt.service;

import java.security.Principal;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import javax.transaction.Transactional;
import javax.transaction.Transactional.TxType;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Service;

import com.taskmgmt.model.User;
import com.taskmgmt.repository.UserRepository;
import com.taskmgmt.security.CustomUserDetails;

@Service
public class UserService {

	@Autowired
	private UserRepository repository;

	@Transactional(value = TxType.REQUIRES_NEW)
	public User save(final User user) {
		return repository.save(user);
	}

	@Transactional(value = TxType.SUPPORTS)
	public Optional<User> findUser(final String userId) {
		return repository.findByUserName(userId);
	}

	@Transactional(value = TxType.SUPPORTS)
	public List<String> findAll(Principal principal) {

		List<User> users = "ADMIN".equalsIgnoreCase(getRole(principal)) ? repository.findAll()
				: repository.findByRole(getRole(principal));
		return users.stream().map(User::getUserName).collect(Collectors.toList());
	}

	@Transactional(value = TxType.SUPPORTS)
	public List<User> getAllUserForApproval(Principal principal) {

		String role = getRole(principal);
		if (!"ADMIN".equalsIgnoreCase(role)) {
			throw new RuntimeException("Un Authorized for this operation");
		}
		return repository.findByUserNameNot(getName(principal)).stream().map(user -> {
			user.setPassword(null);
			return user;
		}).toList();
	}

	@Transactional(value = TxType.REQUIRES_NEW)
	public void updatedUser(final User user) {
		Optional<User> dbUser = repository.findByUserName(user.getUserName());
		if (dbUser.isPresent()) {
			dbUser.get().setEnabled(user.isEnabled());
			dbUser.get().setRole(user.getRole());
			repository.save(dbUser.get());
		}
	}

	private String getRole(Principal principal) {
		UsernamePasswordAuthenticationToken token = (UsernamePasswordAuthenticationToken) principal;
		CustomUserDetails customUserDetails = (CustomUserDetails) token.getPrincipal();
		System.out.println(customUserDetails.getUser().getRole());
		return customUserDetails.getUser().getRole();
	}

	private String getName(Principal principal) {
		UsernamePasswordAuthenticationToken token = (UsernamePasswordAuthenticationToken) principal;
		CustomUserDetails customUserDetails = (CustomUserDetails) token.getPrincipal();
		System.out.println(customUserDetails.getUser().getRole());
		return customUserDetails.getUser().getUserName();
	}
}
