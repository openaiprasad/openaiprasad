package com.taskmgmt;

import java.util.Date;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import com.taskmgmt.model.Task;
import com.taskmgmt.model.User;
import com.taskmgmt.service.TaskService;
import com.taskmgmt.service.UserService;

@SpringBootApplication
@EnableWebSecurity
public class TaskMgmtApplication {

	public static void main(String[] args) {
		SpringApplication.run(TaskMgmtApplication.class, args);
	}

	@Bean
	CommandLineRunner getCommandLine(final TaskService service, final UserService userService,
			final BCryptPasswordEncoder bCryptPasswordEncoder) {
		return (args) -> {

			service.saveTask(new Task("ramesh", "Report Generation", "Open", null, new Date(), null));
			User user = new User();
			user.setEmailAddress("email@email.com");
			user.setEnabled(true);
			user.setPassword(bCryptPasswordEncoder.encode("user"));
			user.setRole("ADMIN");
			user.setUserName("user");
			user.setFullName("Ramesh Kumar");
			userService.save(user);
			userService.save(
					new User("admin", "ramesh1@ramesh.com", bCryptPasswordEncoder.encode("ramesh"), "ADMIN", true,"Admin Ramesh"));
			userService.save(
					new User("ramesh", "ramesh2@ramesh.com", bCryptPasswordEncoder.encode("ramesh"), "USER", true,"M RAMESH"));
			userService.save(
					new User("roja", "roja@ramesh.com", bCryptPasswordEncoder.encode("roja"), "USER", false,"M ROJA"));
			userService.save(
					new User("jatin", "jatin@ramesh.com", bCryptPasswordEncoder.encode("jatin"), "USER", false,"Jatin Trivedi"));
		};
	}
}
