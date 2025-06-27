//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 1000 ether; // 100 tokens with 18 decimals

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public view {
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE);
    }

    function testTotalSupply() public view {
        assertEq(ourToken.totalSupply(), STARTING_BALANCE);
    }

    function testTransfer() public {
        uint256 transferAmount = 20 ether;

        vm.prank(bob);
        ourToken.transfer(alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransferFailInsufficientBalance() public {
        uint256 tooMuch = 999 ether;

        vm.expectRevert(); // No error message because it's a plain revert from OZ
        vm.prank(alice); // alice has 0
        ourToken.transfer(bob, tooMuch);
    }

    function testApprove() public {
        uint256 allowance = 50 ether;

        vm.prank(bob);
        ourToken.approve(alice, allowance);

        assertEq(ourToken.allowance(bob, alice), allowance);
    }

    //  function testIncreaseDecreaseAllowance() public {
    //     uint256 amount = 10 ether;

    //     vm.startPrank(bob);
    //     ourToken.approve(alice, amount);
    //     ourToken.increaseAllowance(alice, amount); // now 20
    //     ourToken.decreaseAllowance(alice, 5 ether); // now 15
    //     vm.stopPrank();

    //     assertEq(ourToken.allowance(bob, alice), 15 ether);
    // }

    function testTransferFromWithoutApproval() public {
        uint256 amount = 10 ether;

        vm.expectRevert();
        vm.prank(alice); // alice has no approval from bob
        ourToken.transferFrom(bob, alice, amount);
    }

    function testTransferToZeroAddressShouldFail() public {
        vm.expectRevert();
        vm.prank(bob);
        ourToken.transfer(address(0), 1 ether);
    }

    function testAllowancesWorks() public {
        uint256 initiaAllowance = 1000;
        vm.prank(bob);
        ourToken.approve(alice, initiaAllowance);

        uint256 transferAmount = 500;
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }
}
