package org.demo;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
public class StudentRegistryController {

    private Map<String, Student> registry = new HashMap<>();
    
    @GetMapping("/registry/{id}")
    public Student lookupStudent(@PathVariable("id") String id) {
        Student student = this.registry.get(id);
        if (student == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Student with the given id does not exist");
        }
        return student;
    }

    @PostMapping("/registry/")
    public void addStudent(@RequestBody Student student) {
        if (this.registry.containsKey(student.getId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Student with the given id already exists");
        }
        this.registry.put(student.getId(), student);
    }
    
    @PutMapping("/registry/")
    public void updateStudent(@RequestBody Student student) {
        if (!this.registry.containsKey(student.getId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Student with the given id does not exist");
        }
        this.registry.put(student.getId(), student);
    }
    
    @DeleteMapping("/registry/{id}")
    public void deleteStudent(@PathVariable("id") String id) {
        this.registry.remove(id);
    }
    
}
