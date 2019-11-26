package org.demo;

import java.util.HashMap;
import java.util.Map;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class StudentRegistryController {

    private Map<Integer, Student> registry = new HashMap<Integer, Student>();
    
    @GetMapping("/registry/{id}")
    public Student lookupStudent(@PathVariable("id") int id) {
        return this.registry.get(id);
    }

    @PostMapping("/registry/")
    public void addStudent(@RequestBody Student student) {
        if (registry.containsKey(student.getId())) {
            throw new RuntimeException("Student already exists: " + student.getId());
        }
        this.registry.put(student.getId(), student);
    }
    
    @PutMapping("/registry/")
    public void updateStudent(@RequestBody Student student) {
        this.registry.put(student.getId(), student);
    }
    
    @DeleteMapping("/registry/{id}")
    public void deleteStudent(@PathVariable("id") int id) {
        this.registry.remove(id);
    }
    
}
