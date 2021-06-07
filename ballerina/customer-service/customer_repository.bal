public type Customer record {
    int customer_id;
    string first_name;
    string middle_name;
    string last_name;
    string suffix;
    string email;
    string phone;
};

public function findAllCustomers() returns Customer[]|error {
    Customer[] customers = [];
    return customers;
}

public function findCustomeById(int customerId) returns Customer?|error {
    return ();
}

public function saveCustomer(Customer customer) returns error? {

}

public function update(Customer customer) returns error? {

}

