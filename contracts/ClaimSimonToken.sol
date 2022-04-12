//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.5;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract ClaimSimonToken is Ownable, Pausable {
    using SafeERC20 for IERC20;
    IERC20 public immutable simonToken;

    event ClaimStart(uint256 claimStartTime, uint256 claimDuration);
    event TokensClaimed(
        address indexed claimer,
        uint256 amount,
        uint256 timestamp
    );
    event TokensBurned(
        address indexed burner,
        uint256 amount,
        uint256 timestamp
    );
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

    ///@notice gets updated by a set amount whenever someone claims.
    ///@dev always divisible by 10,000 (decimal)
    uint256 totalClaimed;

    ///@notice indicates the claim start time and claim duration
    ///@dev assigned values in the startClaim() function
    uint256 claimDuration;
    uint256 claimStartTime;

    ///@notice constant amount that all addresses will be able to claim once
    uint256 immutable amountToClaim;

    ///@notice mapping from addresses to amountClaimed
    ///@dev all users who claimed will have a non-zero value associated with their address (obviously)
    mapping(address => uint256) amountClaimed;

    constructor(address _simonTokenAddress, uint256 _amountToClaim) internal {
        require(
            _simonTokenAddress != address(0),
            "ClaimSimonToken: $IMON Token address cannot be the zero adddress."
        );
        require(
            _amountToClaim > 0,
            "ClaimSimonToken: Amount to claim must be greater than 0."
        );
        simonToken = IERC20(_simonTokenAddress);
        amountToClaim = _amountToClaim;

        _pause();
    }

    function startClaim(uint256 _claimDuration) external onlyOwner whenPaused {
        require(_claimDuration > 0, "Claim duration has to be longer than 0.");
        claimDuration = _claimDuration;
        claimStartTime = block.timestamp;

        _unpause();

        emit ClaimStart(claimStartTime, claimDuration);
    }

    function pauseClaim() external onlyOwner {
        _pause();
    }

    function claimTokens() external whenNotPaused {
        require(
            block.timestamp >= claimStartTime &&
                block.timeStamp < claimStartTime + claimDuration,
            "ClaimSimonToken: Claimable period finished."
        );
        require(
            amountClaimed[msg.sender] == 0,
            "ClaimSimonToken: You've already claimed your tokens."
        );

        simonToken.safeTransfer(msg.sender, amountToClaim);
        amountClaimed[msg.sender] += amountToClaim;

        totalClaimed += amountToClaim;

        emit TokensClaimed(msg.sender, amountToClaim, block.timestamp);
    }

    // TODO
    function stakeTokens(uint256 _amount, address _staker) external {}

    /// TODO
    function calculateStakedRewards(address _staker)
        public
        view
        returns (uint256)
    {}

    /// TODO
    function withdrawStake(uint256 _amountToWithdraw, address _staker)
        external
    {}

    function burnTokens(uint256 _amount) external {
        require(
            _amount > 0,
            "ClaimSimonToken: You must burn at least one token."
        );
        simonToken._burn(msg.sender, _amount);
        emit TokensBurned(msg.sender, _amount, block.timestamp);
    }

    function claimUnclaimedTokens() external onlyOwner {
        require(
            block.timestamp > claimStartTime + claimDuration,
            "ClaimSimonToken: Claimable period not done yet."
        );

        simonToken.safeTransfer(owner(), simonToken.balanceOf(address(this)));

        uint256 balance = address(this).balance;
        if (balance > 0) {
            Address.sendValue(payable(owner()), balance);
        }
    }
}
