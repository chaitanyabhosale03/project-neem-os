// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NeemOSCapital is ERC20, Ownable {
    uint256 public constant SHARE_PRICE = 0.001 ether; // Price per share
    string public assetName;

    constructor(string memory _name, string memory _symbol) 
        ERC20(_name, _symbol) 
        Ownable(msg.sender) 
    {
        assetName = _name;
    }

    // Function to "Invest" and receive shares
    function invest() public payable {
        require(msg.value >= SHARE_PRICE, "Minimum investment not met");
        uint256 sharesToMint = (msg.value / SHARE_PRICE) * 10**decimals();
        _mint(msg.sender, sharesToMint);
    }

    // Allow owner to withdraw the capital for the real-world purchase
    function withdrawFunds() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}