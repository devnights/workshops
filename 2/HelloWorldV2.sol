pragma solidity ^0.4.22;

contract HelloWorld { 

  string helloMessage;

    constructor () public {
        helloMessage = "Hello world";
    }

  function updateMessage (string _new_msg) public {
        helloMessage = _new_msg;
    }
    
  function sayHello() public returns (string) {
    return helloMessage;
  }

}