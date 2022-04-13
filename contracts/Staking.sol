//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.5;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract Staking {
    using SafeERC20 for IERC20;
    IERC20 public immutable simonToken;
    IERC20 public immutable shampooToken;

    event TokenStaked(
        address indexed staker,
        uint256 amount,
        uint256 timestamp
    );
    event TokenUnstaked(
        address indexed staker,
        uint256 amount,
        uint256 timestamp
    );

    // ==== STAKERS ==== //
    mapping(address => uint256) rewardsOf;
    mapping(address => uint256) private balances;
    uint256 internal numStakers;

    constructor(
        address memory _simonTokenAddress,
        address_ memory _shampooTokenAddress
    ) public {
        simonToken = IERC20(_simonTokenAddress);
        shampooToken = IERC20(_shampooTokenAddress);
    }

    // TODO
    function stakeTokens(uint256 _amount) external {
        require(
            _amount > 0,
            "ClaimSimonToken: You must stake at least one token."
        );
        require(
            msg.sender != address(0),
            "ClaimSimonToken: Claimer cannot be the zero address."
        );
        require(
            simonToken.balanceOf(msg.sender) > 0,
            "ClaimSimonToken: You have no tokens to stake."
        );
        Staker staker = Staker(_amount, block.timestamp);
        simonToken.transferFrom(msg.sender, address(this), _amount);
        ++numStakers;
        emit TokensStaked(_staker, _amount, block.timestamp);
    }

    /// TODO
    function calculateStakedRewards() public view returns (uint256) {
        Staker staker = stakesOf[msg.sender];
        uint256 time = staker.beganStake;
        uint256 rewards = rewards = amountStaked * 10;
    }

    /// TODO
    function withdrawStake(uint256 _amountToWithdraw, address _staker)
        external
    {
        emit TokensUnstaked(_staker, _amount, block.timestamp);
    }
}
