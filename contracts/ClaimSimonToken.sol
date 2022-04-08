//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.3;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract ClaimSimonToken is Ownable, Pausable {

    using SafeERC20 for IERC20;
    IERC20 public immutable simonToken;

    event ClaimStart(uint256 _claimDuration, uint256 _claimStartTime);
    event ClaimEnd(uint256 _claimDuration, uint256 _claimEndtime);

    event TokenClaimed(address indexed claimer, uint256 amount, uint256 timestamp);
    event TokenBurned(address indexed claimer, uint256 amount, uint256 timestamp);
    event TokenStaked(address indexed staker, uint256 amount, uint256 timestamp);
    event TokenUnstaked(address indexed staker, uint256 amount, uint256 timestamp);


    uint256 totalClaimed; 
    uint256 claimDuration; 
    uint256 claimStartTime; 

    constructor(address _simonTokenAddress) {
        simonToken = IERC20(_simonTokenAddress);
    }


    mapping(address => uint256) amountClaimed;

    function buyTokens(uint256 _amount) external {
        transfer(msg.sender, _amount);
    }

    // TODO
    function stakeTokens(uint256 _amount, address _staker) external {}

    /// TODO
    function getStakedRewards(address _staker) public view returns (uint256) {}

    /// TODO
    function withdrawStake(uint256 _amountToWithdraw, address _staker)
        external
    {}
}
