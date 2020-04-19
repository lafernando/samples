public type Item record {
    string itemId;
    int quantity;
};

public type Order record {
    string accountId;
    Item[] items;
};

public type Payment record {
    string orderId;
};

public type Delivery record {
    string orderId;
};