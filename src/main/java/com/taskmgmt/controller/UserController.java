package com.taskmgmt.controller;

import java.security.Principal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.taskmgmt.entity.GenericResponse;
import com.taskmgmt.model.User;
import com.taskmgmt.security.CustomUserDetails;
import com.taskmgmt.security.JwtUtil;
import com.taskmgmt.service.UserService;

@RestController
@RequestMapping("users")
public class UserController {

	@Autowired
	private BCryptPasswordEncoder bCryptPasswordEncoder;

	@Autowired
	private UserService service;

	@Autowired
	private AuthenticationManager authenticationManager;

	org.slf4j.Logger logger = LoggerFactory.getLogger(UserController.class);

	@Autowired
	private JwtUtil jwtUtil;

	@GetMapping("/all")
	public GenericResponse<List<String>> getUsers(Principal principal) {
		System.out.println(principal.getName());
		System.out.println(principal);
		return new GenericResponse<List<String>>("User saved sucessfuly", true, service.findAll(principal));
	}

	@GetMapping("")
	public GenericResponse<List<User>> getUsersForApproval(Principal principal) {
		System.out.println(principal.getName());
		System.out.println(principal);
		return new GenericResponse<List<User>>("User saved sucessfuly", true,
				service.getAllUserForApproval(principal));
	}

	@PostMapping("/register")
	public GenericResponse<User> save(@RequestBody User user) {
		String encodedPassword = bCryptPasswordEncoder.encode(user.getPassword());
		user.setPassword(encodedPassword);
		user.setEnabled(false);
		user.setRole("USER");
		try {
			User saveUser = service.save(user);
			return new GenericResponse<User>("User saved sucessfuly", true, null);
		} catch (Exception e) {
			logger.error("Exception occured", e);
			return new GenericResponse<User>(e.getMessage(), false, null);
		}

	}

	@PutMapping()
	public GenericResponse<User> updateUser(@RequestBody User user) {
		try {
			service.updatedUser(user);
			return new GenericResponse<User>("User saved sucessfuly", true, null);
		} catch (Exception e) {
			logger.error("Exception occured", e);
			return new GenericResponse<User>(e.getMessage(), false, null);
		}

	}

	@PostMapping("/login")
	public GenericResponse<String> login(@RequestBody User user) {
		try {
			Authentication authentication = authenticationManager
					.authenticate(new UsernamePasswordAuthenticationToken(user.getUserName(), user.getPassword()));
			CustomUserDetails customUserDetails = (CustomUserDetails) authentication.getPrincipal();
			User user1 = customUserDetails.getUser();
			Map<String, Object> claims = new HashMap<>();
			user1.setPassword(null);
			claims.put("user", user1);
			GenericResponse<String> genericResponse = new GenericResponse<String>();
			String token = jwtUtil.generateToken(user1.getUserName(), claims);
			genericResponse.setPayload(token);
			genericResponse.setMessage("Token Fetched Successfully");
			genericResponse.setStatus(true);
			return genericResponse;
		} catch (Exception e) {
			System.out.println(e);
			GenericResponse<String> genericResponse = new GenericResponse<String>();
			genericResponse.setPayload(null);
			genericResponse.setMessage(e.getMessage());
			genericResponse.setStatus(false);
			return genericResponse;
		}

	}
}
