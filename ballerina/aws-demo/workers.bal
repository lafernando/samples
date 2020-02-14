import ballerina/io;

public function main() {
    worker w1 returns int {
        int j = 10;
        j -> w2;
        int b;
        b = <- w2;
        return b * b;
    }
    worker w2 returns int {
        int a;
        a = <- w1;
        a * 2 -> w1;
        return a + 2;
    }
    record {int w1; int w2;} x = wait {w1, w2};
    io:println(x);
}

