package com.taskmgmt.controller;

import java.net.http.HttpHeaders;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.ResourceUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.taskmgmt.entity.GenericResponse;
import com.taskmgmt.model.Task;
import com.taskmgmt.service.TaskService;

import net.sf.jasperreports.engine.JREmptyDataSource;
import net.sf.jasperreports.engine.JasperCompileManager;
import net.sf.jasperreports.engine.JasperExportManager;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrint;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;

@RestController
@RequestMapping("/tasks")
public class TaskController {

	@Autowired
	private TaskService service;

	@GetMapping("")
	public GenericResponse<List<Task>> getTasks() {
		return new GenericResponse<List<Task>>("sucess", true, service.getTasks());
	}

	@PutMapping("")
	public GenericResponse<Task> updateTask(@RequestBody Task task) {
		if (task.getTaskStatus().equals("Closed")) {
			task.setTaskCloseDate(new Date());
		}
		System.out.println(task);
		return new GenericResponse<Task>("sucess", true, service.saveTask(task));
	}

	@PostMapping("")
	public GenericResponse<Task> saveTask(@RequestBody Task task) {
		task.setTaskStatus("Open");
		return new GenericResponse<Task>("sucess", true, service.saveTask(task));
	}

	@PostMapping(value = "/export", produces = MediaType.APPLICATION_PDF_VALUE, consumes = MediaType.APPLICATION_JSON_VALUE)
	public ResponseEntity export(@RequestBody Task task) {

		try {
			// create employee data
			List<Task> tasks = service.getTasks();

			// dynamic parameters required for report
			Map<String, Object> empParams = new HashMap<String, Object>();
			empParams.put("CompanyName", "Task Managment Report");
			empParams.put("employeeData", new JRBeanCollectionDataSource(tasks));

			JasperPrint empReport = JasperFillManager.fillReport(
					JasperCompileManager.compileReport(ResourceUtils.getFile("classpath:tasks.jrxml").getAbsolutePath()) // path
																															// of
																															// the
																															// jasper
																															// report
					, empParams // dynamic parameters
					, new JREmptyDataSource());

			org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
			// set the PDF format
			headers.setContentType(MediaType.APPLICATION_PDF);
			headers.setContentDispositionFormData("filename", "task-details.pdf");
			// create the report in PDF format
			return new ResponseEntity<byte[]>(JasperExportManager.exportReportToPdf(empReport), headers, HttpStatus.OK);

		} catch (Exception e) {
			System.out.println(e);
			return new ResponseEntity<byte[]>(HttpStatus.INTERNAL_SERVER_ERROR);
		}
	}

	@GetMapping("/export")
	public ResponseEntity d() {

		try {
			// create employee data
			List<Task> tasks = service.getTasks();

			// dynamic parameters required for report
			Map<String, Object> empParams = new HashMap<String, Object>();
			empParams.put("CompanyName", "Task Managment Report");
			empParams.put("employeeData", new JRBeanCollectionDataSource(tasks));

			JasperPrint empReport = JasperFillManager.fillReport(
					JasperCompileManager.compileReport(ResourceUtils.getFile("classpath:tasks.jrxml").getAbsolutePath()) // path
																															// of
																															// the
																															// jasper
																															// report
					, empParams // dynamic parameters
					, new JREmptyDataSource());

			org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
			// set the PDF format
			headers.setContentType(MediaType.APPLICATION_PDF);
			headers.setContentDispositionFormData("filename", "task-details.pdf");
			// create the report in PDF format
			return new ResponseEntity<byte[]>(JasperExportManager.exportReportToPdf(empReport), headers, HttpStatus.OK);

		} catch (Exception e) {
			System.out.println(e);
			return new ResponseEntity<byte[]>(HttpStatus.INTERNAL_SERVER_ERROR);
		}
	}
}
