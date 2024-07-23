// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "src/IBeefy.sol";
import "src/IERC20.sol";

contract Siphon {
    IERC20 public immutable token;

    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    IBeefy public beefy;
    uint public lastPricePerShare;
    address recipient;

    constructor(address _token, address _beefy, address _recipient) {
        token = IERC20(_token);
        beefy = IBeefy(_beefy);
        recipient = _recipient;
        token.approve(_beefy, uint256(2**256 - 1));
        lastPricePerShare = 0;
    }

    function _mint(address _to, uint _shares) private {
        totalSupply += _shares;
        balanceOf[_to] += _shares;
    }

    function _burn(address _from, uint _shares) private {
        totalSupply -= _shares;
        balanceOf[_from] -= _shares;
    }

    // function harvest() external {
    //     uint newPps = beefy.getPricePerFullShare();
    //     if(lastPricePerShare > 0){
    //         uint diff = newPps - lastPricePerShare;
    //         uint profit = (totalSupply * (diff*10**18))/10**18;
    //         if(profit > 0){
    //             _withdraw(profit);
    //             token.transfer(recipient, profit);
    //         }
    //     }

    //     lastPricePerShare = newPps;
    // }

    function vaultBalance() public view returns (uint){
        uint bal = beefy.balanceOf(address(this));
        uint pps = beefy.getPricePerFullShare();
        return ((bal * pps) / 10**18) + token.balanceOf(address(this));
    }

    function harvest() external {
        if(totalSupply > 0) {
            _withdrawAll();
            if(token.balanceOf(address(this)) > totalSupply){
                uint profit = token.balanceOf(address(this)) - totalSupply;
                if(profit > 0) token.transfer(recipient, profit);
            }
            _depositAll();
        }
    }

    function deposit(uint _amount) external {
        
        _mint(msg.sender, _amount);
        token.transferFrom(msg.sender, address(this), _amount);
        beefy.deposit(_amount);
        this.harvest();
    }

    function baseToShares(uint _shares) public view returns(uint){
        uint pps = beefy.getPricePerFullShare();
        uint shares = (_shares * (10**18)) / pps;
        return shares - 100000;
    }

    function _withdraw(uint _baseAmount) private {
        beefy.withdraw(baseToShares(_baseAmount));
    }

    function _withdrawAll() private {
        beefy.withdrawAll();
    }

    function _depositAll() private {
        beefy.depositAll();
    }

    function withdraw(uint _shares) external {
        _burn(msg.sender, _shares);
        _withdrawAll();
        if(token.balanceOf(address(this)) > _shares){
            token.transfer(msg.sender, _shares);
        } else {
            token.transfer(msg.sender, token.balanceOf(address(this)));
        }
        
        _depositAll();
    }
}