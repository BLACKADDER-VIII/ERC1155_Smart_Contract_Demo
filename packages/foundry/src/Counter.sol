// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "forge-std/console2.sol";

contract Counter {
    uint256 public number = 5;
    string[] my_array = ["Lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit", "sed", "do"];

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
        number = number % my_array.length;
    }

    function getArray() public view returns(string[] memory) {
        string[] memory arr = new string[](number);
        for(uint i = 0; i < number; i++) {
            arr[i] = my_array[i];
        }
        for(uint i = 0; i < number; i++) {
            console2.log(arr[i]);
        }
        return arr;
    }
}
