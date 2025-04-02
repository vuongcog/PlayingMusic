class Parents {
  int? parentParam1;
  int? parentParam2;
  int? parentParam3;
  Parents({param1, param2, param3});
}

class Child1 extends Parents {
  int? childParam1;
  Child1({parentParam1, parentParam2, parentParam3, this.childParam1})
    : super(param1: parentParam1, param2: parentParam2, param3: parentParam3);
}

void main() {
  Child1 child1 = Child1(
    childParam1: 4,
    parentParam1: 1,
    parentParam2: 2,
    parentParam3: 3,
  );
  Child1(childParam1: 1);
}
