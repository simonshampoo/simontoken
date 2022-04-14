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
    event RewardsClaimed(
        address indexed claimer,
        uint256 amount,
        uint256 timestamp
    );

    uint256 totalSupply;
    uint256 public numStakers;

    uint256 rewardPerTokenStored;
    uint256 lastUpdateTime;
    uint256 private constant REWARD_RATE = 100;

    mapping(address => uint256) rewardsOf;
    mapping(address => uint256) private stakeOf;

    constructor(
        address memory _simonTokenAddress,
        address_ memory _shampooTokenAddress
    ) public {
        simonToken = IERC20(_simonTokenAddress);
        shampooToken = IERC20(_shampooTokenAddress);
    }

    //==================================================================================================
    //==================================================================================================
    //==================================================================================================

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;

        rewards[account] = earned(account);
        userRewardPerTokenPaid[account] = rewardPerTokenStored;
        _;
    }

    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            (((block.timestamp - lastUpdateTime) * rewardRate * 1e18) /
                _totalSupply);
    }

    function earned(address account) public view returns (uint256) {
        return
            ((_balances[account] *
                (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) +
            rewards[account];
    }

    //==================================================================================================
    //==================================================================================================
    //==================================================================================================
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
        totalSupply += amount;
        stakeOf[msg.sender] += _amount;

        ++numStakers;

        simonToken.transferFrom(msg.sender, address(this), _amount);
        emit TokensStaked(_staker, _amount, block.timestamp);
    }

    /// TODO
    function withdrawStake(uint256 _amountToWithdraw) external {
        require(
            _amountToWithdraw <= stakeOf[msg.sender],
            "Staking: You cannot withdraw more tokens than you have staked."
        );
        require(
            msg.sender != address(0),
            "Staking: Cannot withdraw from the zero address."
        );
        simonToken.transferFrom(address(this), msg.sender, _amountToWithdraw);
        emit TokensUnstaked(_staker, _amount, block.timestamp);
    }

    function getRewards() external updateReward(msg.sender) {
        uint256 reward = rewardsOf[msg.sender];
        rewardsOf[msg.sender] = 0;
        shampooToken.transferFrom(address(this), msg.sender, reward);
        emit RewardsClaimed(msg.sender, reward, block.timestamp);
    }

    /// TODO
    function calculateStakedRewards() public view returns (uint256) {
        uint256 rewards = rewards = amountStaked * 10;
    }
}
