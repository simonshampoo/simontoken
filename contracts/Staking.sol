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

    event TokensStaked(
        address indexed staker,
        uint256 amount,
        uint256 timestamp
    );
    event TokensUnstaked(
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
    mapping(address => uint256) public userRewardPerTokenPaid;

    constructor(
        address _simonTokenAddress,
        address _shampooTokenAddress
    ) {
        simonToken = IERC20(_simonTokenAddress);
        shampooToken = IERC20(_shampooTokenAddress);
    }

    //==================================================================================================
    //==================================================================================================
    //==================================================================================================

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;

        rewardsOf[account] = earned(account);
        userRewardPerTokenPaid[account] = rewardPerTokenStored;
        _;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            (((block.timestamp - lastUpdateTime) * REWARD_RATE * 1e18) /
                totalSupply);
    }

    function earned(address account) public view returns (uint256) {
        return
            ((stakeOf[account] *
                (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) +
            rewardsOf[account];
    }

    //==================================================================================================
    //==================================================================================================
    //==================================================================================================
    // TODO
    function stakeTokens(uint256 _amount) external updateReward(msg.sender) {
        require(_amount > 0, "Staking: You must stake at least one token.");
        require(
            msg.sender != address(0),
            "Staking: Claimer cannot be the zero address."
        );
        require(
            simonToken.balanceOf(msg.sender) > 0,
            "Staking: You have no tokens to stake."
        );
        totalSupply += _amount;
        stakeOf[msg.sender] += _amount;

        ++numStakers;

        simonToken.transferFrom(msg.sender, address(this), _amount);
        emit TokensStaked(msg.sender, _amount, block.timestamp);
    }

    /// TODO
    function withdrawStake(uint256 _amountToWithdraw)
        external
        updateReward(msg.sender)
    {
        require(
            _amountToWithdraw <= stakeOf[msg.sender],
            "Staking: You cannot withdraw more tokens than you have staked."
        );
        require(
            msg.sender != address(0),
            "Staking: Cannot withdraw from the zero address."
        );
        simonToken.transferFrom(address(this), msg.sender, _amountToWithdraw);
        emit TokensUnstaked(msg.sender, _amountToWithdraw, block.timestamp);
    }

    function claimRewards() external updateReward(msg.sender) {
        uint256 reward = rewardsOf[msg.sender];
        rewardsOf[msg.sender] = 0;
        shampooToken.transferFrom(address(this), msg.sender, reward);
        emit RewardsClaimed(msg.sender, reward, block.timestamp);
    }
}
