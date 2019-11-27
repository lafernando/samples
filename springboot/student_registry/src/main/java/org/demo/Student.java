package org.demo;

public class Student {

    private String id;
    
    private String name;
    
    private Major major = Major.CS;
    
    public String getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public Major getMajor() {
        return major;
    }

    public void setId(String id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setMajor(Major major) {
        this.major = major;
    }
    
}

enum Major {
    CS,
    Physics,
    Chemistry
}
