public type Item record {
    int invId;
    int quantity;
};

public type Order record {
    int accountId;
    Item[] items;
};

public type Payment record {
    string orderId;
};

public type Delivery record {
    string orderId;
};