// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Siphon} from "../src/Siphon.sol";
import {IERC20} from "../src/IERC20.sol";

contract SiphonTest is Test {
    Siphon public siphon;
    address beefy = address(0xD7803d3Bf95517D204CFc6211678cAb223aC4c48);
    IERC20 usdc = IERC20(0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA);
    address recipient = makeAddr("recipient");

    function setUp() public {
        siphon = new Siphon(address(usdc), beefy, recipient);
    }

    function test_setup() public {
        assertEq(address(siphon.token()),  address(usdc));
        assertEq(address(siphon.beefy()), address(beefy));
        console.log(10**18, " base to shares: ", siphon.baseToShares(1*10**18));
        console.log("last share price: ", siphon.lastPricePerShare());
    }

    function test_desposit(uint96 amnt) public {
        vm.assume(amnt > 1 ether);
        address alice = makeAddr("alice");
        deal(address(usdc), alice, amnt );
        assertEq(usdc.balanceOf(alice),  amnt);
        hoax(alice);
        usdc.approve(address(siphon), amnt);
        assertEq(usdc.allowance(address(alice), address(siphon)),  amnt);
        assertEq(usdc.allowance(address(siphon), beefy),  uint((2**256)-1) );
        vm.prank(alice);
        siphon.deposit(amnt);
    }

    // function test_desposit_and_withdraw(uint96 amnt) public {
    //     vm.assume(amnt > 1 ether);
    //     address alice = makeAddr("alice");
    //     deal(address(usdc), alice, amnt );
    //     assertEq(usdc.balanceOf(alice),  amnt);
    //     hoax(alice);
    //     usdc.approve(address(siphon), amnt);
    //     assertEq(usdc.allowance(address(alice), address(siphon)),  amnt);
    //     assertEq(usdc.allowance(address(siphon), beefy),  uint((2**256)-1) );
    //     vm.prank(alice);
    //     siphon.deposit(amnt);

    //     uint timestamp = block.timestamp;
    //     skip(36000);
    //     assertEq(block.timestamp, timestamp+36000);
    //     vm.prank(alice);
    //     siphon.withdraw(amnt);
    //     assertEq(usdc.balanceOf(alice),  amnt);
    // }

    function test_desposit_and_withdraw_fixed() public {
        uint96 amnt = 5 * 10**7;
        vm.assume(amnt > 10*10**6);
        address alice = makeAddr("alice");
        deal(address(usdc), alice, amnt );
        assertEq(usdc.balanceOf(alice),  amnt);
        startHoax(alice);
        usdc.approve(address(siphon), amnt);
        assertEq(usdc.allowance(address(alice), address(siphon)),  amnt);
        assertEq(usdc.allowance(address(siphon), beefy),  uint((2**256)-1) );
        siphon.deposit(amnt);
        
        uint timestamp = block.timestamp;
        skip(36000);
        assertEq(block.timestamp, timestamp+36000);

        siphon.withdraw(amnt);
        assertApproxEqAbs(usdc.balanceOf(alice),  amnt, 10**7);
        console.log("alice beg balance: ", amnt);
        console.log("alice end balance: ", usdc.balanceOf(address(alice)));
    }

    function test_desposit_and_withdraw(uint96 amnt) public {
        vm.assume(amnt > 10*10**6);
        address alice = makeAddr("alice");
        deal(address(usdc), alice, amnt );
        assertEq(usdc.balanceOf(alice),  amnt);
        startHoax(alice);
        usdc.approve(address(siphon), amnt);
        assertEq(usdc.allowance(address(alice), address(siphon)),  amnt);
        assertEq(usdc.allowance(address(siphon), beefy),  uint((2**256)-1) );
        siphon.deposit(amnt);
        
        uint timestamp = block.timestamp;
        skip(36000);
        assertEq(block.timestamp, timestamp+36000);

        siphon.withdraw(amnt);
        assertApproxEqAbs(usdc.balanceOf(alice),  amnt, 10**7);
        console.log("alice beg balance: ", amnt);
        console.log("alice end balance: ", usdc.balanceOf(address(alice)));
    }

    function test_desposit_and_harvest_fixed() public {
        uint96 amnt = 1000000 * 10**7;
        vm.assume(amnt > 10*10**6);
        address alice = makeAddr("alice");
        deal(address(usdc), alice, amnt );
        assertEq(usdc.balanceOf(alice),  amnt);
        startHoax(alice);
        usdc.approve(address(siphon), amnt);
        assertEq(usdc.allowance(address(alice), address(siphon)),  amnt);
        assertEq(usdc.allowance(address(siphon), beefy),  uint((2**256)-1) );
        siphon.deposit(amnt);
        assertApproxEqAbs(siphon.vaultBalance(), amnt, 10000);
        console.log("vault balance after deposit: ", siphon.vaultBalance());
        
        uint timestamp = block.timestamp;
        skip(36000);
        assertEq(block.timestamp, timestamp+36000);
        console.log("vault balance after time skip: ", siphon.vaultBalance());

        siphon.harvest();
        console.log("vault balance after harvest: ", siphon.vaultBalance());
        console.log("recipient balance after harvest: ", usdc.balanceOf(recipient));

        siphon.withdraw(amnt);
        assertApproxEqAbs(usdc.balanceOf(alice),  amnt, 10**7);
        console.log("harvest+withraw beg balance: ", amnt);
        console.log("harvest+withdraw end balance: ", usdc.balanceOf(address(alice)));
    }
    function test_desposit_and_harvest(uint96 amnt) public {
        vm.assume(amnt > 10*10**6);
        address alice = makeAddr("alice");
        deal(address(usdc), alice, amnt );
        assertEq(usdc.balanceOf(alice),  amnt);
        startHoax(alice);
        usdc.approve(address(siphon), amnt);
        assertEq(usdc.allowance(address(alice), address(siphon)),  amnt);
        assertEq(usdc.allowance(address(siphon), beefy),  uint((2**256)-1) );
        siphon.deposit(amnt);
        uint portion = 5*(amnt / 10000000);
        assertApproxEqAbs(siphon.vaultBalance(), amnt, portion);
        console.log("vault balance after deposit: ", siphon.vaultBalance());
        
        uint timestamp = block.timestamp;
        uint jump = 60 * 60 * 24;
        skip(jump);
        assertEq(block.timestamp, timestamp+jump);
        console.log("vault balance after time skip: ", siphon.vaultBalance());

        siphon.harvest();
        console.log("vault balance after harvest: ", siphon.vaultBalance());
        console.log("recipient balance after harvest: ", usdc.balanceOf(recipient));

        siphon.withdraw(amnt);
        assertApproxEqAbs(usdc.balanceOf(alice),  amnt, portion);
        console.log("harvest+withraw beg balance: ", amnt);
        console.log("harvest+withdraw end balance: ", usdc.balanceOf(address(alice)));
    }

    function test_multiple_desposit_and_harvest(uint96 amnt) public {
        vm.assume(amnt > 10*10**6);
        vm.assume(amnt < 10*10**22);
        address alice = makeAddr("alice");
        address bob = makeAddr("bob");
        address cat = makeAddr("cat");
        deal(address(usdc), alice, amnt );
        deal(address(usdc), bob, amnt );
        deal(address(usdc), cat, amnt );
        assertEq(usdc.balanceOf(alice),  amnt);
        assertEq(usdc.balanceOf(bob),  amnt);
        assertEq(usdc.balanceOf(cat),  amnt);

        startHoax(alice);
        usdc.approve(address(siphon), amnt);
        assertEq(usdc.allowance(address(alice), address(siphon)),  amnt);
        assertEq(usdc.allowance(address(siphon), beefy),  uint((2**256)-1) );
        siphon.deposit(amnt);

        startHoax(bob);
        usdc.approve(address(siphon), amnt);
        assertEq(usdc.allowance(address(bob), address(siphon)),  amnt);
        assertEq(usdc.allowance(address(siphon), beefy),  uint((2**256)-1) );
        siphon.deposit(amnt);

        startHoax(cat);
        usdc.approve(address(siphon), amnt);
        assertEq(usdc.allowance(address(cat), address(siphon)),  amnt);
        assertEq(usdc.allowance(address(siphon), beefy),  uint((2**256)-1) );
        siphon.deposit(amnt);
        
        
        uint portion = 5*((amnt*3) / 10000);
        // uint portion = 10000000000000000;
        assertApproxEqAbs(siphon.vaultBalance(), (amnt*3), portion);
        console.log("vault balance after deposit: ", siphon.vaultBalance());
        
        uint timestamp = block.timestamp;
        uint jump = 60 * 60 * 24;
        skip(jump);
        assertEq(block.timestamp, timestamp+jump);
        console.log("vault balance after time skip: ", siphon.vaultBalance());

        siphon.harvest();
        console.log("vault balance after harvest: ", siphon.vaultBalance());
        console.log("recipient balance after harvest: ", usdc.balanceOf(recipient));

        startHoax(alice);
        // We want to test if alice can withdraw too much
        vm.expectRevert();
        siphon.withdraw(amnt*2);
        // Okay just withdraw what alice is due
        siphon.withdraw(amnt);
        assertApproxEqAbs(usdc.balanceOf(alice),  amnt, portion);
        console.log("alice beg balance: ", amnt);
        console.log("alice end balance: ", usdc.balanceOf(address(alice)));

        startHoax(bob);
        siphon.withdraw(amnt);
        assertApproxEqAbs(usdc.balanceOf(bob),  amnt, portion);
        console.log("bob beg balance: ", amnt);
        console.log("bob end balance: ", usdc.balanceOf(address(alice)));

        startHoax(cat);
        siphon.withdraw(amnt);
        assertApproxEqAbs(usdc.balanceOf(cat),  amnt, portion);
        console.log("cat beg balance: ", amnt);
        console.log("cat end balance: ", usdc.balanceOf(address(alice)));
    }

}
